#!/usr/bin/env python3
"""Generate and verify offline S10 policy-decision hash-chain evidence.

This dependency-free simulator illustrates a deny-by-default tool policy and
hash-linked decision records. It does not import, invoke, or validate AGT.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

KIT_ROOT = Path(__file__).resolve().parents[1]
POLICY_PATH = KIT_ROOT / "policies" / "demo-policy.json"
EVIDENCE_PATH = KIT_ROOT / "evidence" / "policy-decision-audit.json"
GENESIS_HASH = "0" * 64
DEMONSTRATION_ATTEMPTS = (
    {"attempt_id": "attempt-001", "action": "record_governance_decision", "arguments": {"case_id": "demo-001"}},
    {"attempt_id": "attempt-002", "action": "send_external_email", "arguments": {"recipient": "external@example.invalid"}},
    {"attempt_id": "attempt-003", "action": "publish_policy_change", "arguments": {"change_id": "policy-042"}},
)


def canonical_json(value: Any) -> str:
    return json.dumps(value, separators=(",", ":"), sort_keys=True, ensure_ascii=True)


def digest(value: Any) -> str:
    return hashlib.sha256(canonical_json(value).encode("utf-8")).hexdigest()


def load_policy(path: Path) -> dict[str, Any]:
    policy = json.loads(path.read_text(encoding="utf-8"))
    if policy.get("default_decision") != "deny":
        raise SystemExit("illustrative policy must use deny-by-default")
    if not isinstance(policy.get("actions"), dict) or not policy.get("version"):
        raise SystemExit("policy must include version and actions")
    return policy


def evaluate(policy: dict[str, Any], action: str) -> str:
    decision = policy["actions"].get(action, policy["default_decision"])
    if decision not in {"allow", "deny", "approval_required"}:
        raise SystemExit(f"unsupported decision for {action}: {decision}")
    return decision


def create_records(policy: dict[str, Any]) -> list[dict[str, Any]]:
    previous_hash = GENESIS_HASH
    policy_hash = digest(policy)
    records: list[dict[str, Any]] = []
    for attempt in DEMONSTRATION_ATTEMPTS:
        record = {
            "attempt_id": attempt["attempt_id"],
            "action": attempt["action"],
            "arguments": attempt["arguments"],
            "decision": evaluate(policy, attempt["action"]),
            "policy_id": policy["policy_id"],
            "policy_version": policy["version"],
            "policy_hash": policy_hash,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "previous_hash": previous_hash,
        }
        entry_hash = digest(record)
        records.append({**record, "entry_hash": entry_hash})
        previous_hash = entry_hash
    return records


def verify_records(evidence: dict[str, Any]) -> list[str]:
    failures: list[str] = []
    records = evidence.get("records")
    if not isinstance(records, list) or not records:
        return ["evidence must include a non-empty records list"]
    previous_hash = GENESIS_HASH
    for index, record in enumerate(records, 1):
        if not isinstance(record, dict):
            failures.append(f"record {index} is not an object")
            continue
        entry_hash = record.get("entry_hash")
        payload = {key: value for key, value in record.items() if key != "entry_hash"}
        if record.get("previous_hash") != previous_hash:
            failures.append(f"record {index} previous_hash does not link to its predecessor")
        if entry_hash != digest(payload):
            failures.append(f"record {index} entry_hash does not match its contents")
        previous_hash = str(entry_hash)
    decisions = {record.get("decision") for record in records if isinstance(record, dict)}
    expected = {"allow", "deny", "approval_required"}
    if decisions != expected:
        failures.append(f"expected decisions {sorted(expected)}, found {sorted(str(item) for item in decisions)}")
    return failures


def write_evidence(path: Path, policy: dict[str, Any], records: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    evidence = {
        "schema": "rvas.s10.policy-decision-audit.v1",
        "simulator": "offline-illustration-not-agt-execution",
        "network_required": False,
        "outcome_attestation": "not_available",
        "policy": {
            "policy_id": policy["policy_id"],
            "version": policy["version"],
            "hash": digest(policy),
        },
        "records": records,
    }
    failures = verify_records(evidence)
    evidence["hash_chain_consistency"] = {
        "status": "pass" if not failures else "fail",
        "failures": failures,
    }
    path.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")


def verify_file(path: Path) -> int:
    if not path.exists():
        print(f"FAIL: evidence file not found: {path}")
        return 1
    evidence = json.loads(path.read_text(encoding="utf-8"))
    failures = verify_records(evidence)
    status = evidence.get("hash_chain_consistency", {}).get("status")
    if status != "pass":
        failures.append("stored hash_chain_consistency status is not pass")
    if failures:
        print("FAIL: " + "; ".join(failures))
        return 1
    print(f"PASS: hash-chain consistency verified for {path}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify", type=Path, help="verify an existing evidence file without generating a new one")
    args = parser.parse_args()
    if args.verify:
        return verify_file(args.verify)

    policy = load_policy(POLICY_PATH)
    records = create_records(policy)
    write_evidence(EVIDENCE_PATH, policy, records)
    print("AI Governance Platform S10 offline policy-decision illustration")
    for record in records:
        print(f"{record['attempt_id']}: {record['action']} -> {record['decision']}")
    return verify_file(EVIDENCE_PATH)


if __name__ == "__main__":
    raise SystemExit(main())
