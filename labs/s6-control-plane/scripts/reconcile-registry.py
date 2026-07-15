#!/usr/bin/env python3
"""Reconcile explicit S6 registry records with the S1 Entra Agent ID inventory.

The S6 registry input must use ``rvas.s6.control-plane-registry.v1``. The S1
input is the customer-produced normalized ``agents`` inventory described by
the S1 kit. Matching uses
``entraObjectId`` and S1 ``objectId`` only; display names and alternate field
names are never inferred.
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
REGISTRY_SCHEMA = "rvas.s6.control-plane-registry.v1"
OBO_MODES = {"obo", "on_behalf_of", "on-behalf-of", "user_delegated", "user-delegated"}


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"input not found: {path}")
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise SystemExit(f"expected JSON object at top level: {path}")
    return data


def require_text(record: dict[str, Any], field: str, source: str) -> str:
    value = record.get(field)
    if not isinstance(value, str) or not value.strip():
        raise SystemExit(f"{source} requires a non-empty {field}")
    return value.strip()


def optional_text(record: dict[str, Any], field: str, source: str) -> str | None:
    value = record.get(field)
    if value is None:
        return None
    if not isinstance(value, str) or not value.strip():
        raise SystemExit(f"{source} {field} must be a non-empty string or null")
    return value.strip()


def load_lifecycle_states(path: Path) -> set[str]:
    data = load_json(path)
    states = data.get("states")
    if not isinstance(states, list):
        raise SystemExit(f"lifecycle policy must contain a states array: {path}")
    result = {
        item["name"].casefold()
        for item in states
        if isinstance(item, dict) and isinstance(item.get("name"), str)
    }
    if not result:
        raise SystemExit(f"lifecycle policy has no named states: {path}")
    return result


def normalize_registry(data: dict[str, Any]) -> list[dict[str, Any]]:
    if data.get("schema") != REGISTRY_SCHEMA:
        raise SystemExit(f"registry schema must be {REGISTRY_SCHEMA}")
    agents = data.get("agents")
    if not isinstance(agents, list):
        raise SystemExit("registry must contain an agents array")

    records: list[dict[str, Any]] = []
    for index, item in enumerate(agents, 1):
        if not isinstance(item, dict):
            raise SystemExit(f"registry agent {index} must be an object")
        source = f"registry agent {index}"
        managed = item.get("managed")
        if not isinstance(managed, bool):
            raise SystemExit(f"{source} requires boolean managed")
        records.append(
            {
                "registryId": require_text(item, "registryId", source),
                "displayName": require_text(item, "displayName", source),
                "entraObjectId": optional_text(item, "entraObjectId", source),
                "executionMode": require_text(item, "executionMode", source),
                "managed": managed,
                "lifecycleState": optional_text(item, "lifecycleState", source),
                "sponsor": optional_text(item, "sponsor", source),
            }
        )
    if len({record["registryId"] for record in records}) != len(records):
        raise SystemExit("registryId values must be unique")
    explicit_ids = [record["entraObjectId"] for record in records if record["entraObjectId"]]
    if len(set(explicit_ids)) != len(explicit_ids):
        raise SystemExit("registry entraObjectId values must be unique when supplied")
    return records


def normalize_s1_inventory(data: dict[str, Any]) -> list[dict[str, Any]]:
    agents = data.get("agents")
    if not isinstance(agents, list):
        raise SystemExit("S1 inventory must contain the normalized agents array")

    records: list[dict[str, Any]] = []
    for index, item in enumerate(agents, 1):
        if not isinstance(item, dict):
            raise SystemExit(f"S1 inventory agent {index} must be an object")
        source = f"S1 inventory agent {index}"
        sponsors = item.get("sponsors")
        has_sponsor = item.get("hasSponsor")
        if not isinstance(sponsors, list) or not all(isinstance(value, str) for value in sponsors):
            raise SystemExit(f"{source} requires a string-array sponsors field")
        if not isinstance(has_sponsor, bool):
            raise SystemExit(f"{source} requires boolean hasSponsor")
        if has_sponsor != bool([value for value in sponsors if value.strip()]):
            raise SystemExit(f"{source} hasSponsor must agree with sponsors")
        records.append(
            {
                "displayName": require_text(item, "displayName", source),
                "objectId": require_text(item, "objectId", source),
                "appId": require_text(item, "appId", source),
                "sponsors": [value.strip() for value in sponsors if value.strip()],
                "hasSponsor": has_sponsor,
            }
        )
    if len({record["objectId"] for record in records}) != len(records):
        raise SystemExit("S1 inventory objectId values must be unique")
    return records


def registry_finding(record: dict[str, Any], reason: str) -> dict[str, Any]:
    return {
        "registryId": record["registryId"],
        "displayName": record["displayName"],
        "entraObjectId": record["entraObjectId"],
        "reason": reason,
    }


def s1_finding(record: dict[str, Any], reason: str) -> dict[str, Any]:
    return {
        "displayName": record["displayName"],
        "entraObjectId": record["objectId"],
        "reason": reason,
    }


def reconcile(
    registry_data: dict[str, Any],
    inventory_data: dict[str, Any],
    lifecycle_states: set[str],
) -> dict[str, Any]:
    registry = normalize_registry(registry_data)
    inventory = normalize_s1_inventory(inventory_data)
    registry_ids = {record["entraObjectId"] for record in registry if record["entraObjectId"]}
    inventory_by_id = {record["objectId"]: record for record in inventory}
    matched_ids = registry_ids & set(inventory_by_id)

    shadow_agents = [
        s1_finding(record, "present in S1 inventory but absent from the control-plane registry")
        for record in inventory
        if record["objectId"] not in matched_ids
    ]
    registry_only = [
        registry_finding(record, "not matched to an S1 objectId")
        for record in registry
        if record["entraObjectId"] not in matched_ids
    ]
    unmanaged_or_obo = [
        registry_finding(
            record,
            "; ".join(
                reason
                for condition, reason in (
                    (record["executionMode"].casefold() in OBO_MODES, "executes on behalf of a user"),
                    (not record["managed"], "managed=false"),
                    (record["entraObjectId"] is None, "missing Entra object ID"),
                )
                if condition
            ),
        )
        for record in registry
        if (
            record["executionMode"].casefold() in OBO_MODES
            or not record["managed"]
            or record["entraObjectId"] is None
        )
    ]
    missing_sponsors = [
        registry_finding(record, "missing human sponsor")
        for record in registry
        if record["sponsor"] is None
    ] + [
        s1_finding(record, "missing human sponsor in S1 inventory")
        for record in inventory
        if not record["hasSponsor"]
    ]
    lifecycle_gaps = [
        registry_finding(record, "missing lifecycle state")
        for record in registry
        if record["lifecycleState"] is None
    ]
    invalid_lifecycle_states = [
        registry_finding(record, f"invalid lifecycle state: {record['lifecycleState']}")
        for record in registry
        if record["lifecycleState"] is not None
        and record["lifecycleState"].casefold() not in lifecycle_states
    ]

    return {
        "schema": "rvas.s6.reconciliation-report.v1",
        "summary": {
            "registryCount": len(registry),
            "inventoryCount": len(inventory),
            "matchedCount": len(matched_ids),
            "shadowAgentCount": len(shadow_agents),
            "registryOnlyCount": len(registry_only),
            "unmanagedOrOboCount": len(unmanaged_or_obo),
            "missingSponsorCount": len(missing_sponsors),
            "lifecycleGapCount": len(lifecycle_gaps),
            "invalidLifecycleStateCount": len(invalid_lifecycle_states),
        },
        "matchedEntraObjectIds": sorted(matched_ids),
        "shadowAgents": shadow_agents,
        "registryOnlyAgents": registry_only,
        "unmanagedOrOboAgents": unmanaged_or_obo,
        "missingSponsorFindings": missing_sponsors,
        "lifecycleGaps": lifecycle_gaps,
        "invalidLifecycleStateFindings": invalid_lifecycle_states,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY, help="normalized S6 registry JSON")
    parser.add_argument("--inventory", type=Path, default=DEFAULT_INVENTORY, help="S1 agent-inventory.json")
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
        load_lifecycle_states(args.lifecycle_states),
    )
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    summary = report["summary"]
    print("RVAS S6 registry reconciliation")
    print(f"  registry agents: {summary['registryCount']}")
    print(f"  S1 inventory agents: {summary['inventoryCount']}")
    print(f"  matched by Entra object ID: {summary['matchedCount']}")
    print(f"  shadow agents: {summary['shadowAgentCount']}")
    print(f"  unmanaged/OBO findings: {summary['unmanagedOrOboCount']}")
    print(f"  missing sponsors: {summary['missingSponsorCount']}")
    print(f"  report: {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
