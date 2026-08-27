from __future__ import annotations

import json
import logging
import os
import uuid
from base64 import urlsafe_b64encode
from dataclasses import dataclass
from pathlib import Path
from typing import Annotated
from urllib.parse import urlparse

import httpx
import jwt
import msal
from fastapi import FastAPI, Header, HTTPException, Response, status
from jwt import PyJWKClient
from jwt.exceptions import PyJWKClientError, PyJWTError


LOGGER = logging.getLogger("obo_proxy")


@dataclass(frozen=True)
class Settings:
    tenant_id: str
    middle_tier_client_id: str
    middle_tier_audience: str
    inbound_scope: str
    allowed_caller_client_ids: frozenset[str]
    downstream_scope: str
    downstream_endpoint: str
    certificate_path: str
    request_timeout_seconds: float

    @classmethod
    def load(cls) -> "Settings":
        settings_path = Path(
            os.environ.get("OBO_SETTINGS_PATH", Path(__file__).with_name("settings.json"))
        )
        values = json.loads(settings_path.read_text(encoding="utf-8"))
        required_values = {
            "tenantId",
            "middleTierClientId",
            "middleTierAudience",
            "inboundScope",
            "allowedCallerClientIds",
            "downstreamScope",
            "downstreamEndpoint",
            "certificatePath",
        }
        missing = required_values.difference(values)
        if missing:
            raise ValueError(f"Missing OBO settings: {', '.join(sorted(missing))}")

        def contains_required(value: object) -> bool:
            if isinstance(value, str):
                return value.startswith("__REQUIRED_")
            if isinstance(value, list):
                return any(contains_required(item) for item in value)
            if isinstance(value, dict):
                return any(contains_required(item) for item in value.values())
            return False

        if contains_required(values):
            raise ValueError("OBO settings contain unresolved required values")
        endpoint = urlparse(values["downstreamEndpoint"])
        if endpoint.scheme != "https" or not endpoint.netloc:
            raise ValueError("downstreamEndpoint must be an absolute HTTPS URL")
        certificate_path = Path(values["certificatePath"])
        if (
            not certificate_path.is_file()
            or certificate_path.suffix.casefold() not in {".pfx", ".p12"}
        ):
            raise ValueError("certificatePath must identify a readable PFX or P12 file")
        allowed_callers = values["allowedCallerClientIds"]
        if not isinstance(allowed_callers, list) or not allowed_callers:
            raise ValueError("allowedCallerClientIds must contain at least one application ID")
        return cls(
            tenant_id=values["tenantId"],
            middle_tier_client_id=values["middleTierClientId"],
            middle_tier_audience=values["middleTierAudience"],
            inbound_scope=values["inboundScope"],
            allowed_caller_client_ids=frozenset(allowed_callers),
            downstream_scope=values["downstreamScope"],
            downstream_endpoint=values["downstreamEndpoint"],
            certificate_path=values["certificatePath"],
            request_timeout_seconds=float(values.get("requestTimeoutSeconds", 10)),
        )


SETTINGS = Settings.load()
ISSUER = f"https://login.microsoftonline.com/{SETTINGS.tenant_id}/v2.0"
JWKS_CLIENT = PyJWKClient(
    f"https://login.microsoftonline.com/{SETTINGS.tenant_id}/discovery/v2.0/keys"
)
APP = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)
MSAL_APP = msal.ConfidentialClientApplication(
    client_id=SETTINGS.middle_tier_client_id,
    authority=f"https://login.microsoftonline.com/{SETTINGS.tenant_id}",
    client_credential={"private_key_pfx_path": SETTINGS.certificate_path},
    client_capabilities=["CP1"],
)
AUTHORIZATION_URI = (
    f"https://login.microsoftonline.com/{SETTINGS.tenant_id}/oauth2/v2.0/authorize"
)


def bearer_token(authorization: str | None) -> str:
    if not authorization:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Bearer token is required")
    scheme, separator, token = authorization.partition(" ")
    if separator != " " or scheme.casefold() != "bearer" or not token:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Bearer token is malformed")
    return token


def validate_user_assertion(token: str) -> dict[str, object]:
    try:
        signing_key = JWKS_CLIENT.get_signing_key_from_jwt(token)
        claims = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=SETTINGS.middle_tier_audience,
            issuer=ISSUER,
            options={"require": ["exp", "iat", "nbf", "oid", "tid", "azp", "scp"]},
        )
    except (PyJWKClientError, PyJWTError) as error:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Bearer token validation failed",
        ) from error
    scopes = set(str(claims["scp"]).split())
    if SETTINGS.inbound_scope not in scopes:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Required delegated scope is absent")
    if str(claims["azp"]) not in SETTINGS.allowed_caller_client_ids:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Calling application is not approved")
    if claims.get("tid") != SETTINGS.tenant_id:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Token tenant is not approved")
    return claims


def claims_challenge_header(claims: str) -> str:
    encoded = urlsafe_b64encode(claims.encode("utf-8")).decode("ascii").rstrip("=")
    return (
        f'Bearer authorization_uri="{AUTHORIZATION_URI}", '
        f'error="insufficient_claims", claims="{encoded}"'
    )


@APP.get("/delegated-resource")
async def delegated_resource(
    response: Response,
    authorization: Annotated[str | None, Header()] = None,
) -> dict[str, object]:
    correlation_id = str(uuid.uuid4())
    response.headers["x-correlation-id"] = correlation_id
    assertion = bearer_token(authorization)
    validate_user_assertion(assertion)

    token_result = MSAL_APP.acquire_token_on_behalf_of(
        user_assertion=assertion,
        scopes=[SETTINGS.downstream_scope],
    )
    access_token = token_result.get("access_token")
    if not isinstance(access_token, str) or not access_token:
        error_code = str(token_result.get("error", "token_exchange_denied"))
        LOGGER.warning(
            "OBO token exchange denied",
            extra={
                "correlation_id": correlation_id,
                "operation": "delegated-resource",
                "error_code": error_code,
            },
        )
        headers = {"x-correlation-id": correlation_id}
        challenge = token_result.get("claims")
        if isinstance(challenge, str) and challenge:
            headers["WWW-Authenticate"] = claims_challenge_header(challenge)
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Delegated token exchange failed",
            headers=headers,
        )

    try:
        async with httpx.AsyncClient(timeout=SETTINGS.request_timeout_seconds) as client:
            downstream_response = await client.get(
                SETTINGS.downstream_endpoint,
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "x-correlation-id": correlation_id,
                },
            )
    except httpx.RequestError as error:
        LOGGER.error(
            "OBO downstream call failed",
            extra={
                "correlation_id": correlation_id,
                "operation": "delegated-resource",
                "error_code": "downstream_unavailable",
            },
        )
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            "Downstream API is unavailable",
            headers={"x-correlation-id": correlation_id},
        ) from error

    LOGGER.info(
        "OBO downstream call",
        extra={
            "correlation_id": correlation_id,
            "operation": "delegated-resource",
            "status_code": downstream_response.status_code,
        },
    )
    if downstream_response.status_code in {401, 403}:
        challenge = downstream_response.headers.get("WWW-Authenticate")
        headers = {
            "x-correlation-id": correlation_id,
            "x-authorization-decision": "downstream-denied",
        }
        if challenge:
            headers["WWW-Authenticate"] = challenge
        raise HTTPException(
            downstream_response.status_code,
            "Downstream authorization was denied",
            headers=headers,
        )
    if downstream_response.is_error:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            "Downstream API returned an unexpected error",
            headers={"x-correlation-id": correlation_id},
        )
    response.headers["x-authorization-decision"] = "downstream-authorized"
    return {
        "correlationId": correlation_id,
        "status": "authorized",
    }
