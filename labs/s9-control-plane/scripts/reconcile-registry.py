#!/usr/bin/env python3
"""Reconcile an explicit S9 agent-and-tool catalog with an identity inventory.

The catalog uses ``rvas.s9.control-plane-registry.v1``. Identity matching uses
only catalog ``identityObjectId`` and inventory ``objectId``; names and
alternate fields are never inferred. This program is read-only with respect to
the supplied inputs and reports record-quality and accountability findings.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REGISTRY = ROOT / "data" / "agent-registry.sample.json"
DEFAULT_INVENTORY = ROOT / "data" / "s1-agent-inventory.sample.json"
DEFAULT_OUT = ROOT / "evidence" / "reconciliation-report.json"
DEFAULT_LIFECYCLE_STATES = ROOT / "policies" / "lifecycle-states.json"
REGISTRY_SCHEMA = "rvas.s9.control-plane-registry.v1"
USER_DELEGATED_MODES = {
    "obo",
    "on_behalf_of",
    "on-behalf-of",
    "user_delegated",
    "user-delegated",
}
MATERIAL_CHANGE_STATUSES = {"not_applicable", "reviewed", "pending_review", "not_reviewed"}
CLOSURE_STATES = {"suspended", "retired", "decommissioned"}


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"input not found: {path}")
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise SystemExit(f"expected JSON object at top level: {path}")
    return data


def require_text(record: dict[str, Any], field: str, context: str) -> str:
    value = record.get(field)
    if not isinstance(value, str) or not value.strip():
        raise SystemExit(f"{context} requires a non-empty {field}")
    return value.strip()


def optional_text(record: dict[str, Any], field: str, context: str) -> str | None:
    value = record.get(field)
    if value is None:
        return None
    if not isinstance(value, str) or not value.strip():
        raise SystemExit(f"{context} {field} must be a non-empty string or null")
    return value.strip()


def load_lifecycle_policy(path: Path) -> dict[str, set[str]]:
    states = load_json(path).get("states")
    if not isinstance(states, list):
        raise SystemExit(f"lifecycle policy must contain a states array: {path}")
    policy: dict[str, set[str]] = {}
    for item in states:
        if not isinstance(item, dict):
            raise SystemExit("lifecycle policy states must be objects")
        name = require_text(item, "name", "lifecycle state").casefold()
        transitions = item.get("permittedTransitions")
        if not isinstance(transitions, list) or not all(isinstance(value, str) for value in transitions):
            raise SystemExit(f"lifecycle state {name} requires a string-array permittedTransitions")
        policy[name] = {value.casefold() for value in transitions}
    if not policy:
        raise SystemExit(f"lifecycle policy has no named states: {path}")
    unknown_destinations = set().union(*policy.values()) - set(policy)
    if unknown_destinations:
        raise SystemExit(f"lifecycle policy has unknown transition destinations: {sorted(unknown_destinations)}")
    return policy


def normalize_transition(record: dict[str, Any], context: str) -> dict[str, str] | None:
    transition = record.get("lifecycleTransition")
    if transition is None:
        return None
    if not isinstance(transition, dict):
        raise SystemExit(f"{context} lifecycleTransition must be an object or null")
    return {
        "fromState": require_text(transition, "fromState", f"{context} lifecycleTransition"),
        "toState": require_text(transition, "toState", f"{context} lifecycleTransition"),
        "decisionOwner": require_text(transition, "decisionOwner", f"{context} lifecycleTransition"),
        "reviewRef": require_text(transition, "reviewRef", f"{context} lifecycleTransition"),
    }


def normalize_review_fields(record: dict[str, Any], context: str) -> dict[str, Any]:
    status = require_text(record, "materialChangeReviewStatus", context).casefold()
    if status not in MATERIAL_CHANGE_STATUSES:
        raise SystemExit(f"{context} has invalid materialChangeReviewStatus: {status}")
    return {
        "lifecycleState": optional_text(record, "lifecycleState", context),
        "lifecycleReviewRef": optional_text(record, "lifecycleReviewRef", context),
        "materialChangeReviewStatus": status,
        "materialChangeReviewRef": optional_text(record, "materialChangeReviewRef", context),
        "lifecycleTransition": normalize_transition(record, context),
        "closureOwner": optional_text(record, "closureOwner", context),
        "closureReviewRef": optional_text(record, "closureReviewRef", context),
    }


def normalize_registry(data: dict[str, Any]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    if data.get("schema") != REGISTRY_SCHEMA:
        raise SystemExit(f"registry schema must be {REGISTRY_SCHEMA}")
    agents = data.get("agents")
    tools = data.get("tools")
    if not isinstance(agents, list) or not isinstance(tools, list):
        raise SystemExit("registry must contain agents and tools arrays")

    agent_records: list[dict[str, Any]] = []
    for index, item in enumerate(agents, 1):
        if not isinstance(item, dict):
            raise SystemExit(f"registry agent {index} must be an object")
        context = f"registry agent {index}"
        managed = item.get("managed")
        if not isinstance(managed, bool):
            raise SystemExit(f"{context} requires boolean managed")
        record = {
            "entryType": "agent",
            "registryId": require_text(item, "registryId", context),
            "displayName": require_text(item, "displayName", context),
            "identityObjectId": optional_text(item, "identityObjectId", context),
            "executionMode": require_text(item, "executionMode", context),
            "managed": managed,
            "accountableOwner": optional_text(item, "accountableOwner", context),
            "technicalOwner": optional_text(item, "technicalOwner", context),
        }
        record.update(normalize_review_fields(item, context))
        agent_records.append(record)

    tool_records: list[dict[str, Any]] = []
    for index, item in enumerate(tools, 1):
        if not isinstance(item, dict):
            raise SystemExit(f"registry tool {index} must be an object")
        context = f"registry tool {index}"
        record = {
            "entryType": "tool",
            "toolId": require_text(item, "toolId", context),
            "displayName": require_text(item, "displayName", context),
            "parentRegistryId": optional_text(item, "parentRegistryId", context),
            "owner": optional_text(item, "owner", context),
        }
        record.update(normalize_review_fields(item, context))
        tool_records.append(record)

    if len({record["registryId"] for record in agent_records}) != len(agent_records):
        raise SystemExit("registryId values must be unique")
    if len({record["toolId"] for record in tool_records}) != len(tool_records):
        raise SystemExit("toolId values must be unique")
    identity_ids = [record["identityObjectId"] for record in agent_records if record["identityObjectId"]]
    if len(set(identity_ids)) != len(identity_ids):
        raise SystemExit("registry identityObjectId values must be unique when supplied")
    return agent_records, tool_records


def normalize_identity_inventory(data: dict[str, Any]) -> list[dict[str, Any]]:
    agents = data.get("agents")
    if not isinstance(agents, list):
        raise SystemExit("identity inventory must contain an agents array")
    records: list[dict[str, Any]] = []
    for index, item in enumerate(agents, 1):
        if not isinstance(item, dict):
            raise SystemExit(f"identity inventory agent {index} must be an object")
        context = f"identity inventory agent {index}"
        sponsors = item.get("sponsors")
        has_sponsor = item.get("hasSponsor")
        if not isinstance(sponsors, list) or not all(isinstance(value, str) for value in sponsors):
            raise SystemExit(f"{context} requires a string-array sponsors field")
        if not isinstance(has_sponsor, bool):
            raise SystemExit(f"{context} requires boolean hasSponsor")
        if has_sponsor != bool([value for value in sponsors if value.strip()]):
            raise SystemExit(f"{context} hasSponsor must agree with sponsors")
        records.append(
            {
                "displayName": require_text(item, "displayName", context),
                "objectId": require_text(item, "objectId", context),
                "hasSponsor": has_sponsor,
            }
        )
    if len({record["objectId"] for record in records}) != len(records):
        raise SystemExit("identity inventory objectId values must be unique")
    return records


def finding(record: dict[str, Any], reason: str) -> dict[str, Any]:
    identifier = record.get("registryId") or record.get("toolId") or record.get("objectId")
    return {
        "entryType": record.get("entryType", "identity"),
        "identifier": identifier,
        "displayName": record["displayName"],
        "identityObjectId": record.get("identityObjectId", record.get("objectId")),
        "reason": reason,
    }


def review_gaps(records: list[dict[str, Any]], lifecycle_policy: dict[str, set[str]]) -> dict[str, list[dict[str, Any]]]:
    ownership_gaps: list[dict[str, Any]] = []
    lifecycle_gaps: list[dict[str, Any]] = []
    invalid_lifecycle_states: list[dict[str, Any]] = []
    material_change_review_gaps: list[dict[str, Any]] = []
    transition_review_gaps: list[dict[str, Any]] = []
    closure_accountability_gaps: list[dict[str, Any]] = []

    for record in records:
        owners = (
            (record.get("accountableOwner"), record.get("technicalOwner"))
            if record["entryType"] == "agent"
            else (record.get("owner"),)
        )
        if not all(owners):
            ownership_gaps.append(finding(record, "missing accountable ownership or technical stewardship"))

        state = record["lifecycleState"]
        if state is None or record["lifecycleReviewRef"] is None:
            lifecycle_gaps.append(finding(record, "missing lifecycle state or lifecycle-review reference"))
        elif state.casefold() not in lifecycle_policy:
            invalid_lifecycle_states.append(finding(record, f"invalid lifecycle state: {state}"))

        status = record["materialChangeReviewStatus"]
        if status in {"pending_review", "not_reviewed"} or (
            status == "reviewed" and record["materialChangeReviewRef"] is None
        ):
            material_change_review_gaps.append(
                finding(record, "material change lacks a completed review reference")
            )

        transition = record["lifecycleTransition"]
        if transition:
            from_state = transition["fromState"].casefold()
            to_state = transition["toState"].casefold()
            valid = (
                state is not None
                and to_state == state.casefold()
                and from_state in lifecycle_policy
                and to_state in lifecycle_policy.get(from_state, set())
            )
            if not valid:
                transition_review_gaps.append(
                    finding(record, "lifecycle transition is inconsistent with the lifecycle policy or current state")
                )

        if state and state.casefold() in CLOSURE_STATES and (
            record["closureOwner"] is None or record["closureReviewRef"] is None
        ):
            closure_accountability_gaps.append(
                finding(record, "suspended, retired, or decommissioned entry lacks closure accountability")
            )

    return {
        "ownershipGaps": ownership_gaps,
        "lifecycleGaps": lifecycle_gaps,
        "invalidLifecycleStateFindings": invalid_lifecycle_states,
        "materialChangeReviewGaps": material_change_review_gaps,
        "transitionReviewGaps": transition_review_gaps,
        "closureAccountabilityGaps": closure_accountability_gaps,
    }


def reconcile(
    registry_data: dict[str, Any],
    inventory_data: dict[str, Any],
    lifecycle_policy: dict[str, set[str]],
) -> dict[str, Any]:
    agents, tools = normalize_registry(registry_data)
    inventory = normalize_identity_inventory(inventory_data)
    catalog_ids = {record["identityObjectId"] for record in agents if record["identityObjectId"]}
    inventory_by_id = {record["objectId"]: record for record in inventory}
    matched_ids = catalog_ids & set(inventory_by_id)
    findings = review_gaps(agents + tools, lifecycle_policy)
    agent_ids = {record["registryId"] for record in agents}

    shadow_agents = [
        finding(record, "present in the identity inventory but absent from the control-plane catalog")
        for record in inventory
        if record["objectId"] not in matched_ids
    ]
    catalog_only_agents = [
        finding(record, "not matched to an identity-inventory objectId")
        for record in agents
        if record["identityObjectId"] not in matched_ids
    ]
    unmanaged_or_delegated = [
        finding(
            record,
            "; ".join(
                reason
                for condition, reason in (
                    (record["executionMode"].casefold() in USER_DELEGATED_MODES, "user-delegated execution"),
                    (not record["managed"], "managed=false"),
                    (record["identityObjectId"] is None, "missing identity object ID"),
                )
                if condition
            ),
        )
        for record in agents
        if (
            record["executionMode"].casefold() in USER_DELEGATED_MODES
            or not record["managed"]
            or record["identityObjectId"] is None
        )
    ]
    tool_parent_gaps = [
        finding(record, "missing or unknown parent agent relationship")
        for record in tools
        if record["parentRegistryId"] is None or record["parentRegistryId"] not in agent_ids
    ]
    missing_sponsors = [
        finding(record, "missing human sponsor in identity inventory")
        for record in inventory
        if not record["hasSponsor"]
    ]

    report = {
        "schema": "rvas.s9.reconciliation-report.v1",
        "summary": {
            "catalogAgentCount": len(agents),
            "catalogToolCount": len(tools),
            "inventoryCount": len(inventory),
            "matchedCount": len(matched_ids),
            "shadowAgentCount": len(shadow_agents),
            "catalogOnlyAgentCount": len(catalog_only_agents),
            "unmanagedOrDelegatedCount": len(unmanaged_or_delegated),
            "missingSponsorCount": len(missing_sponsors),
            "toolParentGapCount": len(tool_parent_gaps),
            "ownershipGapCount": len(findings["ownershipGaps"]),
            "lifecycleGapCount": len(findings["lifecycleGaps"]),
            "invalidLifecycleStateCount": len(findings["invalidLifecycleStateFindings"]),
            "materialChangeReviewGapCount": len(findings["materialChangeReviewGaps"]),
            "transitionReviewGapCount": len(findings["transitionReviewGaps"]),
            "closureAccountabilityGapCount": len(findings["closureAccountabilityGaps"]),
        },
        "matchedIdentityObjectIds": sorted(matched_ids),
        "shadowAgents": shadow_agents,
        "catalogOnlyAgents": catalog_only_agents,
        "unmanagedOrDelegatedAgents": unmanaged_or_delegated,
        "missingSponsorFindings": missing_sponsors,
        "toolParentGaps": tool_parent_gaps,
        **findings,
    }
    return report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY, help="normalized S9 catalog JSON")
    parser.add_argument("--inventory", type=Path, default=DEFAULT_INVENTORY, help="normalized identity-inventory JSON")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help="reconciliation report JSON output")
    parser.add_argument(
        "--lifecycle-states",
        type=Path,
        default=DEFAULT_LIFECYCLE_STATES,
        help="lifecycle-state policy JSON",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    report = reconcile(
        load_json(args.registry),
        load_json(args.inventory),
        load_lifecycle_policy(args.lifecycle_states),
    )
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    summary = report["summary"]
    print("RVAS S9 catalog reconciliation")
    print(f"  catalog agents: {summary['catalogAgentCount']}")
    print(f"  catalog tools: {summary['catalogToolCount']}")
    print(f"  identity inventory agents: {summary['inventoryCount']}")
    print(f"  matched by object ID: {summary['matchedCount']}")
    print(f"  stewardship and closure gaps: {summary['ownershipGapCount'] + summary['closureAccountabilityGapCount']}")
    print(f"  report: {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
