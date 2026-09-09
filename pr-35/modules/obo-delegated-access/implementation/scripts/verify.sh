#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/verify.sh --middle-tier-endpoint <https-url> --permitted-token-file <path> --denied-token-file <path>

Reads one permitted bearer token file and one denied bearer token file outside the repository,
executes one HTTPS request for each, and confirms a permitted 2xx path plus a denied 401/403 path
without printing tokens or response payloads.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command is unavailable: $1"
}

resolve_python() {
  if command -v python >/dev/null 2>&1; then
    printf '%s\n' 'python'
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' 'python3'
    return 0
  fi
  fail 'Python is required.'
}

canonical_path() {
  local input_path="$1"
  "$python_cmd" - "$input_path" <<'PY'
from pathlib import Path
import sys
print(Path(sys.argv[1]).expanduser().resolve())
PY
}

ensure_outside_repository() {
  local label="$1"
  local candidate="$2"
  case "$candidate" in
    "$repo_root"|"$repo_root"/*)
      fail "$label must be outside the repository: $candidate"
      ;;
  esac
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/../../../.." && pwd -P)"
python_cmd="$(resolve_python)"

middle_tier_endpoint=''
permitted_token_file=''
denied_token_file=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --middle-tier-endpoint)
      [[ $# -ge 2 ]] || fail 'Missing value for --middle-tier-endpoint'
      middle_tier_endpoint="$2"
      shift 2
      ;;
    --permitted-token-file)
      [[ $# -ge 2 ]] || fail 'Missing value for --permitted-token-file'
      permitted_token_file="$2"
      shift 2
      ;;
    --denied-token-file)
      [[ $# -ge 2 ]] || fail 'Missing value for --denied-token-file'
      denied_token_file="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown option: $1"
      ;;
  esac
done

[[ -n "$middle_tier_endpoint" ]] || { usage >&2; fail '--middle-tier-endpoint is required.'; }
[[ -n "$permitted_token_file" ]] || { usage >&2; fail '--permitted-token-file is required.'; }
[[ -n "$denied_token_file" ]] || { usage >&2; fail '--denied-token-file is required.'; }

require_command "$python_cmd"

permitted_token_path="$(canonical_path "$permitted_token_file")"
denied_token_path="$(canonical_path "$denied_token_file")"
ensure_outside_repository 'The permitted token file' "$permitted_token_path"
ensure_outside_repository 'The denied token file' "$denied_token_path"
[[ -f "$permitted_token_path" ]] || fail "Permitted token file was not found: $permitted_token_path"
[[ -f "$denied_token_path" ]] || fail "Denied token file was not found: $denied_token_path"

result_json="$(VERIFY_ENDPOINT="$middle_tier_endpoint" \
PERMITTED_TOKEN_PATH="$permitted_token_path" \
DENIED_TOKEN_PATH="$denied_token_path" \
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


def ensure_outside_repo(path_value: Path, repo_root: Path, label: str) -> None:
    try:
        path_value.relative_to(repo_root)
    except ValueError:
        return
    fail(f"{label} must be outside the repository: {path_value}")


def read_token(path_value: Path, label: str) -> str:
    if not path_value.is_file():
        fail(f"{label} was not found: {path_value}")
    token = path_value.read_text(encoding='utf-8').strip()
    if not token:
        fail(f"{label} is empty: {path_value}")
    return token


def invoke(endpoint: str, token: str) -> dict[str, str | int]:
    request = urllib.request.Request(
        endpoint,
        headers={"Authorization": f"Bearer {token}"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(request, context=ssl.create_default_context()) as response:
            return {
                "statusCode": int(response.getcode()),
                "correlationId": response.headers.get("x-correlation-id", ""),
                "authorizationDecision": response.headers.get(
                    "x-authorization-decision", ""
                ),
            }
    except urllib.error.HTTPError as error:
        return {
            "statusCode": int(error.code),
            "correlationId": error.headers.get("x-correlation-id", ""),
            "authorizationDecision": error.headers.get(
                "x-authorization-decision", ""
            ),
        }
    except urllib.error.URLError as error:
        fail(f"HTTPS request failed: {error.reason}")


endpoint = os.environ["VERIFY_ENDPOINT"]
parsed = urllib.parse.urlparse(endpoint)
if parsed.scheme != "https" or not parsed.netloc:
    fail("The middle-tier endpoint must be an absolute HTTPS URL.")

repo_root = Path(os.environ["REPO_ROOT"]).resolve()
permitted_path = Path(os.environ["PERMITTED_TOKEN_PATH"]).resolve()
denied_path = Path(os.environ["DENIED_TOKEN_PATH"]).resolve()
ensure_outside_repo(permitted_path, repo_root, "The permitted token file")
ensure_outside_repo(denied_path, repo_root, "The denied token file")

permitted_result = invoke(endpoint, read_token(permitted_path, "Permitted token file"))
denied_result = invoke(endpoint, read_token(denied_path, "Denied token file"))

if permitted_result["statusCode"] < 200 or permitted_result["statusCode"] > 299:
    fail(
        "Permitted-path verification failed. "
        f"Expected 2xx, received {permitted_result['statusCode']}."
    )
if denied_result["statusCode"] not in {401, 403}:
    fail(
        "Denied-path verification failed. "
        f"Expected 401 or 403, received {denied_result['statusCode']}."
    )
if not permitted_result["correlationId"]:
    fail("Permitted-path verification did not return an x-correlation-id header.")
if not denied_result["correlationId"]:
    fail("Denied-path verification did not return an x-correlation-id header.")
if permitted_result["authorizationDecision"] != "downstream-authorized":
    fail("Permitted-path verification did not reach downstream authorization.")
if denied_result["authorizationDecision"] != "downstream-denied":
    fail("Denied-path verification did not prove a downstream authorization denial.")

print(
    json.dumps(
        {
            "permitted": permitted_result,
            "denied": denied_result,
        }
    )
)
PY
)"

RESULT_JSON="$result_json" "$python_cmd" - <<'PY'
import json
import os

result = json.loads(os.environ['RESULT_JSON'])
print(
    f"Permitted path: HTTP {result['permitted']['statusCode']} "
    f"(x-correlation-id={result['permitted']['correlationId']})."
)
print(
    f"Denied path: HTTP {result['denied']['statusCode']} "
    f"(x-correlation-id={result['denied']['correlationId']})."
)
PY
