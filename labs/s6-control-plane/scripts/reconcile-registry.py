#!/usr/bin/env python3
"""Reconcile an Agent 365 registry export with an S1 Entra Agent ID inventory.

The tool is offline-only: it reads JSON files, writes a reconciliation report,
and prints a concise summary. By default it uses the shipped sample data.

Usage:
    python scripts/reconcile-registry.py \
      --registry data/agent-registry.sample.json \
      --inventory data/s1-agent-inventory.sample.json \
      --out evidence/reconciliation-report.json
"""
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REGISTRY = ROOT / "data" / "agent-registry.sample.json"
DEFAULT_INVENTORY = ROOT / "data" / "s1-agent-inventory.sample.json"
DEFAULT_OUT = ROOT / "evidence" / "reconciliation-report.json"
DEFAULT_LIFECYCLE_STATES = ROOT / "policies" / "lifecycle-states.json"
OBO_MODES = {"obo", "on_behalf_of", "on-behalf-of", "user_delegated", "user-delegated"}


@dataclass(frozen=True)
class AgentRecord:
    """Normalized agent record from either source."""

    key: str
    display_name: str
    source: str
    entra_agent_id: str | None
    sponsor: str | None
    managed: bool
    execution_mode: str
    lifecycle_state: str | None
    raw: dict[str, Any]

    @property
    def is_obo(self) -> bool:
        return self.execution_mode.casefold() in OBO_MODES or self.raw.get("runsOnBehalfOfUser") is True

    @property
    def has_sponsor(self) -> bool:
        return bool(self.sponsor)


def text_or_none(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"input not found: {path}")
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise SystemExit(f"expected JSON object at top level: {path}")
    return data


def load_lifecycle_states(path: Path) -> set[str]:
    data = load_json(path)
    states = data.get("states")
    if not isinstance(states, list):
        raise SystemExit(f"lifecycle policy must contain a states array: {path}")
    return {
        str(item["name"]).casefold()
        for item in states
        if isinstance(item, dict) and isinstance(item.get("name"), str)
    }


def normalize_key(display_name: str | None, entra_agent_id: str | None) -> str:
    if entra_agent_id:
        return f"id:{entra_agent_id.casefold()}"
    if display_name:
        return f"name:{display_name.casefold()}"
    raise ValueError("agent record needs displayName or Entra Agent ID")


def first_sponsor(agent: dict[str, Any]) -> str | None:
    for field in ("sponsorEmail", "humanSponsor", "ownerEmail", "sponsor"):
        sponsor = text_or_none(agent.get(field))
        if sponsor:
            return sponsor
    sponsors = agent.get("sponsors")
    if isinstance(sponsors, list):
        for item in sponsors:
            sponsor = text_or_none(item)
            if sponsor:
                return sponsor
    owner = text_or_none(agent.get("owner"))
    return owner


def normalize_registry(data: dict[str, Any]) -> list[AgentRecord]:
    agents = data.get("agents") or data.get("registryAgents") or []
    if not isinstance(agents, list):
        raise SystemExit("registry export must contain an agents array")
    records: list[AgentRecord] = []
    for item in agents:
        if not isinstance(item, dict):
            raise SystemExit("registry agent entries must be objects")
        display_name = text_or_none(item.get("displayName") or item.get("name"))
        entra_id = text_or_none(item.get("entraAgentId") or item.get("objectId"))
        key = normalize_key(display_name, entra_id)
        execution_mode = text_or_none(item.get("executionMode")) or "agent_identity"
        managed = bool(item.get("managed", bool(entra_id)))
        records.append(
            AgentRecord(
                key=key,
                display_name=display_name or key,
                source="registry",
                entra_agent_id=entra_id,
                sponsor=first_sponsor(item),
                managed=managed,
                execution_mode=execution_mode,
                lifecycle_state=text_or_none(item.get("lifecycleState")),
                raw=item,
            )
        )
    return records


def normalize_inventory(data: dict[str, Any]) -> list[AgentRecord]:
    agents = data.get("agents") or data.get("agentIdentities") or []
    if not isinstance(agents, list):
        raise SystemExit("S1 inventory must contain an agents array")
    records: list[AgentRecord] = []
    for item in agents:
        if not isinstance(item, dict):
            raise SystemExit("inventory agent entries must be objects")
        display_name = text_or_none(item.get("displayName") or item.get("agent_display_name"))
        entra_id = text_or_none(item.get("objectId") or item.get("agent_object_id") or item.get("entraAgentId"))
        key = normalize_key(display_name, entra_id)
        execution_mode = "obo" if item.get("runsOnBehalfOfUser") is True else "agent_identity"
        records.append(
            AgentRecord(
                key=key,
                display_name=display_name or key,
                source="s1_inventory",
                entra_agent_id=entra_id,
                sponsor=first_sponsor(item),
                managed=bool(entra_id),
                execution_mode=execution_mode,
                lifecycle_state=text_or_none(item.get("lifecycleState") or item.get("lifecycle_state")),
                raw=item,
            )
        )
    return records


def finding(record: AgentRecord, reason: str) -> dict[str, Any]:
    return {
        "key": record.key,
        "displayName": record.display_name,
        "source": record.source,
        "entraAgentId": record.entra_agent_id,
        "reason": reason,
    }


def reconcile(
    registry_data: dict[str, Any],
    inventory_data: dict[str, Any],
    lifecycle_states: set[str] | None = None,
) -> dict[str, Any]:
    registry = normalize_registry(registry_data)
    inventory = normalize_inventory(inventory_data)
    registry_by_key = {agent.key: agent for agent in registry}
    inventory_by_key = {agent.key: agent for agent in inventory}
    registry_by_name = {agent.display_name.casefold(): agent for agent in registry}
    inventory_by_name = {agent.display_name.casefold(): agent for agent in inventory}

    matched_registry_keys: set[str] = set()
    matched_inventory_keys: set[str] = set()
    for key in set(registry_by_key) & set(inventory_by_key):
        matched_registry_keys.add(key)
        matched_inventory_keys.add(key)
    for name in set(registry_by_name) & set(inventory_by_name):
        matched_registry_keys.add(registry_by_name[name].key)
        matched_inventory_keys.add(inventory_by_name[name].key)

    shadow_agents = [
        finding(agent, "present in S1 inventory but absent from Agent 365 registry")
        for agent in sorted(inventory, key=lambda item: item.display_name.casefold())
        if agent.key not in matched_inventory_keys
    ]
    registry_only = [
        finding(agent, "present in registry but absent from S1 inventory")
        for agent in sorted(registry, key=lambda item: item.display_name.casefold())
        if agent.key not in matched_registry_keys
    ]

    unmanaged_or_obo: list[dict[str, Any]] = []
    missing_sponsors: list[dict[str, Any]] = []
    lifecycle_gaps: list[dict[str, Any]] = []
    invalid_lifecycle_states: list[dict[str, Any]] = []
    for record in [*registry, *inventory]:
        if record.is_obo or not record.managed or not record.entra_agent_id:
            reason_parts = []
            if record.is_obo:
                reason_parts.append("executes on behalf of a user")
            if not record.managed:
                reason_parts.append("managed=false")
            if not record.entra_agent_id:
                reason_parts.append("missing Entra Agent ID")
            unmanaged_or_obo.append(finding(record, "; ".join(reason_parts)))
        if not record.has_sponsor:
            missing_sponsors.append(finding(record, "missing human sponsor"))
        if record.source == "registry" and not record.lifecycle_state:
            lifecycle_gaps.append(finding(record, "missing lifecycle state"))
        elif (
            record.source == "registry"
            and lifecycle_states is not None
            and record.lifecycle_state
            and record.lifecycle_state.casefold() not in lifecycle_states
        ):
            invalid_lifecycle_states.append(
                finding(record, f"invalid lifecycle state: {record.lifecycle_state}")
            )

    return {
        "summary": {
            "registryCount": len(registry),
            "inventoryCount": len(inventory),
            "matchedCount": len(matched_inventory_keys),
            "shadowAgentCount": len(shadow_agents),
            "registryOnlyCount": len(registry_only),
            "unmanagedOrOboCount": len(unmanaged_or_obo),
            "missingSponsorCount": len(missing_sponsors),
            "lifecycleGapCount": len(lifecycle_gaps),
            "invalidLifecycleStateCount": len(invalid_lifecycle_states),
        },
        "matchedAgents": sorted(
            {registry_by_key[key].display_name for key in matched_registry_keys},
            key=str.casefold,
        ),
        "shadowAgents": shadow_agents,
        "registryOnlyAgents": registry_only,
        "unmanagedOrOboAgents": unmanaged_or_obo,
        "missingSponsorFindings": missing_sponsors,
        "lifecycleGaps": lifecycle_gaps,
        "invalidLifecycleStateFindings": invalid_lifecycle_states,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY, help="Agent 365 registry export JSON")
    parser.add_argument("--inventory", type=Path, default=DEFAULT_INVENTORY, help="S1 Entra Agent ID inventory JSON")
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
    print(f"  matched: {summary['matchedCount']}")
    print(f"  shadow agents: {summary['shadowAgentCount']}")
    print(f"  unmanaged/OBO findings: {summary['unmanagedOrOboCount']}")
    print(f"  missing sponsors: {summary['missingSponsorCount']}")
    print(f"  report: {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
