from __future__ import annotations

import base64
import binascii
import hashlib
import json
import os
import time
import uuid
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

import httpx
from fastapi import FastAPI, Header, Response, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

try:
    from azure.ai.agentserver.core.tasks import TaskContext, multi_turn_task
except ImportError as import_error:
    TaskContext = Any
    multi_turn_task = None
    AGENTSERVER_IMPORT_ERROR = import_error
else:
    AGENTSERVER_IMPORT_ERROR = None


APP = FastAPI(title="Responsible AI oversight approval gate", docs_url=None, redoc_url=None)
MODULE_MARKER = "optional-module-responsible-ai-impact-oversight"
PENDING_TASKS: dict[str, "PendingToolCall"] = {}


class ToolCallRequest(BaseModel):
    task_id: str = Field(alias="taskId", min_length=1)
    tool_name: str = Field(alias="toolName", min_length=1)
    arguments: dict[str, Any] = Field(default_factory=dict)
    reason: str = Field(default="")


class ApprovalDecision(BaseModel):
    task_id: str = Field(alias="taskId", min_length=1)
    decision: str = Field(pattern="^(approved|rejected)$")


@dataclass(frozen=True)
class AuthenticatedPrincipal:
    principal_id: str
    principal_name: str
    identity_provider: str
    claims: tuple[tuple[str, str], ...]


@dataclass
class PendingToolCall:
    task_id: str
    tool_name: str
    arguments: dict[str, Any]
    reason: str
    argument_hash: str
    created_at: int
    requester_id: str
    requester_name: str
    status: str = "pending"
    decision: str | None = None
    approver_id: str | None = None
    approver_name: str | None = None
    decided_at: int | None = None

    @classmethod
    def from_request(cls, request: ToolCallRequest, requester: AuthenticatedPrincipal) -> "PendingToolCall":
        return cls(
            task_id=request.task_id,
            tool_name=request.tool_name,
            arguments=request.arguments,
            reason=request.reason,
            argument_hash=_event_hash(request.arguments),
            created_at=int(time.time()),
            requester_id=requester.principal_id,
            requester_name=requester.principal_name,
        )

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "PendingToolCall":
        return cls(
            task_id=str(value["task_id"]),
            tool_name=str(value["tool_name"]),
            arguments=dict(value.get("arguments") or {}),
            reason=str(value.get("reason") or ""),
            argument_hash=str(value["argument_hash"]),
            created_at=int(value["created_at"]),
            requester_id=str(value["requester_id"]),
            requester_name=str(value["requester_name"]),
            status=str(value.get("status") or "pending"),
            decision=value.get("decision"),
            approver_id=value.get("approver_id"),
            approver_name=value.get("approver_name"),
            decided_at=value.get("decided_at"),
        )

    def to_request(self) -> ToolCallRequest:
        return ToolCallRequest(
            taskId=self.task_id,
            toolName=self.tool_name,
            arguments=self.arguments,
            reason=self.reason,
        )

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class OversightSettings:
    tool_name: str
    action_class: str
    approver_role: str
    record_store: str
    approval_sla: str
    execution_route_reference: str
    approved_decision: str
    rejected_decision: str
    approver_claim_type: str
    approver_claim_value: str

    @classmethod
    def load(cls) -> "OversightSettings":
        default_path = Path(__file__).resolve().parents[1] / "oversight" / "oversight-decision.json"
        settings_path = Path(os.environ.get("OVERSIGHT_DECISION_PATH", default_path))
        payload = json.loads(settings_path.read_text(encoding="utf-8"))
        if payload.get("implementationSession") != MODULE_MARKER:
            raise RuntimeError("Oversight decision record has the wrong implementationSession marker.")
        if _contains_required(payload):
            raise RuntimeError("Oversight decision record contains unresolved required values.")
        if payload.get("targetScope") != "one-approved-foundry-agent":
            raise RuntimeError("Oversight decision record has the wrong targetScope.")
        authentication = payload.get("authentication") or {}
        if authentication.get("principalSource") != "app-service-authentication-headers":
            raise RuntimeError("Approver identity must come from App Service authentication headers.")
        required_headers = set(authentication.get("requiredHeaders") or [])
        if required_headers != {
            "X-MS-CLIENT-PRINCIPAL",
            "X-MS-CLIENT-PRINCIPAL-ID",
            "X-MS-CLIENT-PRINCIPAL-NAME",
        }:
            raise RuntimeError("The approval gate must require App Service principal and claim headers.")
        approver_claim = authentication.get("approverClaim") or {}
        if approver_claim.get("claimType") not in {"roles", "groups"}:
            raise RuntimeError("approverClaim.claimType must be roles or groups.")
        if not str(approver_claim.get("claimValue") or "").strip():
            raise RuntimeError("approverClaim.claimValue must name the approved app role or group claim value.")
        tool = payload["gatedTool"]
        records = payload["records"]
        verification = payload["verification"]
        if tool.get("approvalMode") != "always_require":
            raise RuntimeError("The gated tool must require approval for every call.")
        if tool.get("actionClass") not in {"write", "irreversible"}:
            raise RuntimeError("The gated tool actionClass must be write or irreversible.")
        return cls(
            tool_name=tool["toolName"],
            action_class=tool["actionClass"],
            approver_role=tool["approverRole"],
            record_store=records["approvalRecordStore"],
            approval_sla=tool["approvalSla"],
            execution_route_reference=tool["executionRouteReference"],
            approved_decision=verification["approvedDecision"],
            rejected_decision=verification["rejectedDecision"],
            approver_claim_type=approver_claim["claimType"],
            approver_claim_value=approver_claim["claimValue"],
        )


class GateFailure(Exception):
    def __init__(self, status_code: int, body: dict[str, Any], decision_header: str | None = None) -> None:
        super().__init__(str(body.get("detail") or body.get("status") or status_code))
        self.status_code = status_code
        self.body = body
        self.decision_header = decision_header


def _contains_required(value: Any) -> bool:
    if isinstance(value, str):
        return "__REQUIRED_" in value
    if isinstance(value, list):
        return any(_contains_required(item) for item in value)
    if isinstance(value, dict):
        return any(_contains_required(item) for item in value.values())
    return False


def _event_hash(arguments: dict[str, Any]) -> str:
    encoded = json.dumps(arguments, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _settings() -> OversightSettings:
    return OversightSettings.load()


def _append_decision_event(event: dict[str, Any]) -> None:
    log_path = os.environ.get("OVERSIGHT_DECISION_LOG_PATH")
    if not log_path:
        raise GateFailure(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            {
                "status": "decision_store_unavailable",
                "toolExecuted": False,
                "detail": "OVERSIGHT_DECISION_LOG_PATH must be configured before approval requests can be recorded.",
                "correlationId": str(event.get("correlationId") or ""),
            },
        )
    path = Path(log_path)
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(event, sort_keys=True) + "\n")
    except OSError as error:
        raise GateFailure(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            {
                "status": "decision_store_unavailable",
                "toolExecuted": False,
                "detail": f"Cannot write the approval decision record: {error}",
                "correlationId": str(event.get("correlationId") or ""),
            },
        ) from error


def _authenticated_principal(
    principal_id: str | None,
    principal_name: str | None,
    identity_provider: str | None,
    principal_payload: str | None,
) -> AuthenticatedPrincipal:
    if not principal_id or not principal_name or not principal_payload:
        raise GateFailure(
            status.HTTP_401_UNAUTHORIZED,
            {
                "status": "unauthenticated",
                "toolExecuted": False,
                "detail": "The approval gate requires App Service authentication principal and claim headers.",
            },
        )
    try:
        padded_payload = principal_payload + "=" * (-len(principal_payload) % 4)
        decoded_payload = base64.b64decode(padded_payload).decode("utf-8")
        payload = json.loads(decoded_payload)
    except (binascii.Error, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise GateFailure(
            status.HTTP_401_UNAUTHORIZED,
            {
                "status": "unauthenticated",
                "toolExecuted": False,
                "detail": f"The X-MS-CLIENT-PRINCIPAL header is not valid base64 JSON: {error}",
            },
        ) from error
    claims: list[tuple[str, str]] = []
    for claim in payload.get("claims") or []:
        claim_type = claim.get("typ")
        claim_value = claim.get("val")
        if isinstance(claim_type, str) and isinstance(claim_value, str):
            claims.append((claim_type, claim_value))
    return AuthenticatedPrincipal(
        principal_id=principal_id,
        principal_name=principal_name,
        identity_provider=identity_provider or "unknown",
        claims=tuple(claims),
    )


def _principal_from_mapping(headers: dict[str, Any]) -> AuthenticatedPrincipal:
    normalized = {str(key).lower(): str(value) for key, value in headers.items() if value is not None}
    return _authenticated_principal(
        normalized.get("x-ms-client-principal-id"),
        normalized.get("x-ms-client-principal-name"),
        normalized.get("x-ms-client-principal-idp"),
        normalized.get("x-ms-client-principal"),
    )


def _claim_type_aliases(claim_type: str) -> set[str]:
    if claim_type == "roles":
        return {"roles", "role", "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"}
    if claim_type == "groups":
        return {"groups", "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"}
    return {claim_type}


def _principal_has_approver_claim(settings: OversightSettings, principal: AuthenticatedPrincipal) -> bool:
    aliases = _claim_type_aliases(settings.approver_claim_type)
    return any(
        claim_type in aliases and claim_value == settings.approver_claim_value
        for claim_type, claim_value in principal.claims
    )


def _start_pending(
    settings: OversightSettings,
    request: ToolCallRequest,
    requester: AuthenticatedPrincipal,
    correlation_id: str,
) -> PendingToolCall:
    if request.tool_name != settings.tool_name:
        raise GateFailure(
            status.HTTP_400_BAD_REQUEST,
            {
                "status": "wrong_tool",
                "toolExecuted": False,
                "detail": "This approval gate is bound to a different tool.",
                "correlationId": correlation_id,
            },
        )
    pending = PendingToolCall.from_request(request, requester)
    _append_decision_event(
        {
            "time": pending.created_at,
            "taskId": pending.task_id,
            "toolName": pending.tool_name,
            "actionClass": settings.action_class,
            "argumentHash": pending.argument_hash,
            "requesterId": requester.principal_id,
            "requesterName": requester.principal_name,
            "status": "awaiting_approval",
            "approverRole": settings.approver_role,
            "correlationId": correlation_id,
        }
    )
    return pending


def _start_response(settings: OversightSettings, pending: PendingToolCall, correlation_id: str) -> dict[str, Any]:
    return {
        "status": "awaiting_approval",
        "taskId": pending.task_id,
        "toolName": pending.tool_name,
        "actionClass": settings.action_class,
        "approverRole": settings.approver_role,
        "approvalSla": settings.approval_sla,
        "argumentHash": pending.argument_hash,
        "correlationId": correlation_id,
    }


async def _execute_tool(settings: OversightSettings, pending: PendingToolCall, correlation_id: str) -> int:
    execution_url = os.environ.get("OVERSIGHT_TOOL_EXECUTION_URL")
    if not execution_url:
        raise GateFailure(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            {
                "status": "approved_not_executed",
                "toolExecuted": False,
                "oversightDecision": "approved-not-executed",
                "detail": "The approved tool execution URL is not configured.",
                "correlationId": correlation_id,
            },
            "approved-not-executed",
        )
    headers = {
        "x-correlation-id": correlation_id,
        "x-oversight-tool": settings.tool_name,
    }
    bearer = os.environ.get("OVERSIGHT_TOOL_BEARER_TOKEN")
    if bearer:
        headers["Authorization"] = "Bearer " + bearer
    async with httpx.AsyncClient(timeout=15.0) as client:
        response = await client.post(
            execution_url,
            json={"toolName": pending.tool_name, "arguments": pending.arguments},
            headers=headers,
        )
    if response.status_code >= 400:
        raise GateFailure(
            status.HTTP_502_BAD_GATEWAY,
            {
                "status": "approved_not_executed",
                "toolExecuted": False,
                "oversightDecision": "approved-tool-failed",
                "detail": "Approved tool execution failed.",
                "correlationId": correlation_id,
            },
            "approved-tool-failed",
        )
    return response.status_code


async def _complete_pending(
    settings: OversightSettings,
    pending: PendingToolCall,
    decision: str,
    principal: AuthenticatedPrincipal,
    correlation_id: str,
) -> dict[str, Any]:
    if pending.status != "pending":
        raise GateFailure(
            status.HTTP_409_CONFLICT,
            {
                "status": "already_decided",
                "toolExecuted": False,
                "detail": "This task has already received a decision.",
                "correlationId": correlation_id,
            },
        )
    if principal.principal_id == pending.requester_id:
        raise GateFailure(
            status.HTTP_403_FORBIDDEN,
            {
                "status": "self_approval_rejected",
                "toolExecuted": False,
                "detail": "The approver principal must differ from the requester principal.",
                "correlationId": correlation_id,
            },
        )
    if not _principal_has_approver_claim(settings, principal):
        raise GateFailure(
            status.HTTP_403_FORBIDDEN,
            {
                "status": "approver_not_authorized",
                "toolExecuted": False,
                "detail": "The authenticated principal does not hold the configured approver app role or group claim.",
                "correlationId": correlation_id,
            },
        )

    pending.status = "decided"
    pending.decision = decision
    pending.approver_id = principal.principal_id
    pending.approver_name = principal.principal_name
    pending.decided_at = int(time.time())
    _append_decision_event(
        {
            "time": pending.decided_at,
            "taskId": pending.task_id,
            "approverId": principal.principal_id,
            "approverName": principal.principal_name,
            "identityProvider": principal.identity_provider,
            "decision": decision,
            "argumentHash": pending.argument_hash,
            "correlationId": correlation_id,
        }
    )

    if decision == "rejected":
        pending.status = "rejected"
        return {
            "status": "rejected",
            "toolExecuted": False,
            "oversightDecision": settings.rejected_decision,
            "correlationId": correlation_id,
        }

    try:
        status_code = await _execute_tool(settings, pending, correlation_id)
    except GateFailure:
        pending.status = "failed"
        raise

    pending.status = "executed"
    return {
        "status": "approved",
        "toolExecuted": True,
        "toolStatusCode": status_code,
        "oversightDecision": settings.approved_decision,
        "correlationId": correlation_id,
    }


def _error_response(error: GateFailure, correlation_id: str, response: Response) -> JSONResponse:
    response.headers["x-correlation-id"] = correlation_id
    if error.decision_header:
        response.headers["x-oversight-decision"] = error.decision_header
    return JSONResponse(
        status_code=error.status_code,
        content=error.body | {"correlationId": error.body.get("correlationId", correlation_id)},
        headers=dict(response.headers),
    )


def _decorate_task(function: Any) -> Any:
    if multi_turn_task is None:
        async def unavailable_hosted_entry_point(*_args: Any, **_kwargs: Any) -> dict[str, Any]:
            raise RuntimeError(
                "The hosted-agent entry point requires azure-ai-agentserver-core>=2.2.0. "
                "Use the authenticated HTTP gate or install the required package before invoking approve_tool_call."
            ) from AGENTSERVER_IMPORT_ERROR

        return unavailable_hosted_entry_point
    return multi_turn_task(name="responsible-ai-tool-approval")(function)


@_decorate_task
async def approve_tool_call(ctx: TaskContext[dict[str, Any]]) -> dict[str, Any]:
    settings = _settings()
    correlation_id = str(uuid.uuid4())
    if getattr(ctx, "entry_mode", "") == "resumed":
        decision = ApprovalDecision.model_validate(ctx.input)
        principal = _principal_from_mapping(dict(ctx.metadata.get("authenticatedPrincipalHeaders") or {}))
        pending_data = getattr(ctx, "metadata", {}).get("pendingToolCall")
        if not isinstance(pending_data, dict):
            raise ValueError("The resumed task does not contain a pending tool call.")
        pending = PendingToolCall.from_dict(pending_data)
        try:
            return await _complete_pending(settings, pending, decision.decision, principal, correlation_id)
        finally:
            ctx.metadata["pendingToolCall"] = pending.to_dict()

    request = ToolCallRequest.model_validate(ctx.input)
    requester = _principal_from_mapping(dict(ctx.metadata.get("authenticatedPrincipalHeaders") or {}))
    pending = _start_pending(settings, request, requester, correlation_id)
    if isinstance(getattr(ctx, "metadata", None), dict) and "pendingToolCall" in ctx.metadata:
        raise ValueError("This task already has a pending approval request.")
    ctx.metadata["pendingToolCall"] = pending.to_dict()
    return _start_response(settings, pending, correlation_id)


@APP.post("/approval/start", status_code=status.HTTP_202_ACCEPTED)
async def start_approval(
    request: ToolCallRequest,
    response: Response,
    x_ms_client_principal: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL"),
    x_ms_client_principal_id: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL-ID"),
    x_ms_client_principal_name: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL-NAME"),
    x_ms_client_principal_idp: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL-IDP"),
) -> dict[str, Any] | JSONResponse:
    settings = _settings()
    correlation_id = str(uuid.uuid4())
    response.headers["x-correlation-id"] = correlation_id
    response.headers["x-oversight-decision"] = "awaiting-approval"
    try:
        requester = _authenticated_principal(
            x_ms_client_principal_id,
            x_ms_client_principal_name,
            x_ms_client_principal_idp,
            x_ms_client_principal,
        )
        if request.task_id in PENDING_TASKS:
            raise GateFailure(
                status.HTTP_409_CONFLICT,
                {
                    "status": "already_pending",
                    "toolExecuted": False,
                    "detail": "This task already has a pending or decided approval request.",
                    "correlationId": correlation_id,
                },
            )
        pending = _start_pending(settings, request, requester, correlation_id)
    except GateFailure as error:
        return _error_response(error, correlation_id, response)
    PENDING_TASKS[pending.task_id] = pending
    return _start_response(settings, pending, correlation_id)


@APP.post("/approval/resume")
async def resume_approval(
    decision: ApprovalDecision,
    response: Response,
    x_ms_client_principal: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL"),
    x_ms_client_principal_id: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL-ID"),
    x_ms_client_principal_name: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL-NAME"),
    x_ms_client_principal_idp: str | None = Header(default=None, alias="X-MS-CLIENT-PRINCIPAL-IDP"),
) -> dict[str, Any] | JSONResponse:
    settings = _settings()
    correlation_id = str(uuid.uuid4())
    response.headers["x-correlation-id"] = correlation_id
    pending = PENDING_TASKS.get(decision.task_id)
    try:
        principal = _authenticated_principal(
            x_ms_client_principal_id,
            x_ms_client_principal_name,
            x_ms_client_principal_idp,
            x_ms_client_principal,
        )
        if pending is None:
            raise GateFailure(
                status.HTTP_404_NOT_FOUND,
                {
                    "status": "unknown_task",
                    "toolExecuted": False,
                    "detail": "No pending approval request exists for this taskId.",
                    "correlationId": correlation_id,
                },
            )
        result = await _complete_pending(settings, pending, decision.decision, principal, correlation_id)
    except GateFailure as error:
        return _error_response(error, correlation_id, response)
    response.headers["x-oversight-decision"] = str(result["oversightDecision"])
    return result
