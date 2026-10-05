#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/verify.sh --approval-gate-endpoint <https-url> --approved-payload-file <path> --rejected-payload-file <path>

Runs one approved and one rejected tool-call check against the deployed approval gate. Payloads and tokens are not printed.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

resolve_python() {
  if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "python3"
    return 0
  fi
  fail "python3 is required."
}

approval_gate_endpoint=""
approved_payload_file=""
rejected_payload_file=""
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/../../.." && pwd -P)"
python_cmd="$(resolve_python)"

while (($# > 0)); do
  case "$1" in
    --approval-gate-endpoint)
      (($# >= 2)) || fail "--approval-gate-endpoint requires a value."
      approval_gate_endpoint="$2"
      shift 2
      ;;
    --approved-payload-file)
      (($# >= 2)) || fail "--approved-payload-file requires a value."
      approved_payload_file="$2"
      shift 2
      ;;
    --rejected-payload-file)
      (($# >= 2)) || fail "--rejected-payload-file requires a value."
      rejected_payload_file="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown option: $1"
      ;;
  esac
done

[[ -n "$approval_gate_endpoint" ]] || fail "--approval-gate-endpoint is required."
[[ -n "$approved_payload_file" ]] || fail "--approved-payload-file is required."
[[ -n "$rejected_payload_file" ]] || fail "--rejected-payload-file is required."

VERIFY_ENDPOINT="$approval_gate_endpoint" \
APPROVED_PAYLOAD="$approved_payload_file" \
REJECTED_PAYLOAD="$rejected_payload_file" \
REPO_ROOT="$repo_root" \
"$python_cmd" - <<'PY'
from __future__ import annotations

import json
import os
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

def fail(message: str) -> None:
    raise SystemExit(message)

def resolve_outside_repo(path_text: str, label: str, repo_root: Path) -> Path:
    path = Path(path_text).expanduser().resolve()
    if not path.is_file():
        fail(f"{label} was not found: {path}")
    try:
        path.relative_to(repo_root)
        fail(f"{label} must be outside the repository: {path}")
    except ValueError:
        return path

def read_payload(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"Payload is not valid JSON: {path} ({error})")

def post_json(url: str, body: dict) -> tuple[int, dict[str, str], dict]:
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
    }
    token = os.environ["CURRENT_VERIFY_BEARER_TOKEN"]
    headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(body).encode("utf-8")
    request = urllib.request.Request(url, data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request, context=ssl.create_default_context()) as response:
            payload = response.read().decode("utf-8") or "{}"
            return int(response.getcode()), dict(response.headers.items()), json.loads(payload)
    except urllib.error.HTTPError as error:
        payload = error.read().decode("utf-8") or "{}"
        try:
            parsed = json.loads(payload)
        except json.JSONDecodeError:
            parsed = {}
        return int(error.code), dict(error.headers.items()), parsed
    except urllib.error.URLError as error:
        fail(f"HTTPS request failed: {error.reason}")

def decision(headers: dict[str, str], body: dict) -> str:
    for key, value in headers.items():
        if key.lower() == "x-oversight-decision":
            return value
    return str(body.get("oversightDecision", ""))

endpoint = os.environ["VERIFY_ENDPOINT"].rstrip("/")
parsed = urllib.parse.urlparse(endpoint)
if parsed.scheme != "https" or not parsed.netloc:
    fail("The approval gate endpoint must be an absolute HTTPS URL.")
repo_root = Path(os.environ["REPO_ROOT"]).resolve()
approved_path = resolve_outside_repo(os.environ["APPROVED_PAYLOAD"], "Approved payload file", repo_root)
rejected_path = resolve_outside_repo(os.environ["REJECTED_PAYLOAD"], "Rejected payload file", repo_root)
start_url = endpoint + "/approval/start"
resume_url = endpoint + "/approval/resume"
requester_token = os.environ.get("OVERSIGHT_VERIFY_REQUESTER_BEARER_TOKEN", "")
approver_token = os.environ.get("OVERSIGHT_VERIFY_APPROVER_BEARER_TOKEN", "")
if not requester_token:
    fail("Set OVERSIGHT_VERIFY_REQUESTER_BEARER_TOKEN for the authenticated requester.")
if not approver_token:
    fail("Set OVERSIGHT_VERIFY_APPROVER_BEARER_TOKEN for the authenticated approver.")
if requester_token == approver_token:
    fail("Requester and approver tokens must be distinct so the check cannot pass through self-approval.")

os.environ["CURRENT_VERIFY_BEARER_TOKEN"] = requester_token
approved_code, _, approved_start = post_json(start_url, read_payload(approved_path))
if approved_code not in {200, 202} or approved_start.get("status") != "awaiting_approval":
    fail("Approved-path start did not return awaiting_approval.")
approved_task = str(approved_start.get("taskId", ""))
os.environ["CURRENT_VERIFY_BEARER_TOKEN"] = approver_token
approved_code, approved_headers, approved_resume = post_json(
    resume_url,
    {"taskId": approved_task, "decision": "approved"},
)
if approved_code < 200 or approved_code > 299:
    fail(f"Approved-path resume failed with HTTP {approved_code}.")
if approved_resume.get("toolExecuted") is not True or decision(approved_headers, approved_resume) != "approved-executed":
    fail("Approved-path verification did not execute the tool.")
if not approved_resume.get("correlationId"):
    fail("Approved-path verification did not return a correlation ID.")

os.environ["CURRENT_VERIFY_BEARER_TOKEN"] = requester_token
rejected_code, _, rejected_start = post_json(start_url, read_payload(rejected_path))
if rejected_code not in {200, 202} or rejected_start.get("status") != "awaiting_approval":
    fail("Rejected-path start did not return awaiting_approval.")
rejected_task = str(rejected_start.get("taskId", ""))
os.environ["CURRENT_VERIFY_BEARER_TOKEN"] = approver_token
rejected_code, rejected_headers, rejected_resume = post_json(
    resume_url,
    {"taskId": rejected_task, "decision": "rejected"},
)
if rejected_code < 200 or rejected_code > 299:
    fail(f"Rejected-path resume failed with HTTP {rejected_code}.")
if rejected_resume.get("toolExecuted") is not False or decision(rejected_headers, rejected_resume) != "rejected-not-executed":
    fail("Rejected-path verification executed the tool or returned the wrong decision.")
if not rejected_resume.get("correlationId"):
    fail("Rejected-path verification did not return a correlation ID.")

print(f"Approved path: tool executed after approval (correlationId={approved_resume['correlationId']}).")
print(f"Rejected path: tool did not execute after rejection (correlationId={rejected_resume['correlationId']}).")
PY
