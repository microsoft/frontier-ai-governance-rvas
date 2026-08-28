#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
client_settings_path="$script_dir/../artifacts/registry-client-settings.json"
ownership_path="$script_dir/../artifacts/registry-ownership.json"
access_token_env="API_CENTER_ACCESS_TOKEN"
max_pages=50

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($# > 0)); do
  case "$1" in
    --client-settings)
      (($# >= 2)) || fail "--client-settings requires a value."
      client_settings_path=$2
      shift 2
      ;;
    --ownership)
      (($# >= 2)) || fail "--ownership requires a value."
      ownership_path=$2
      shift 2
      ;;
    --access-token-env)
      (($# >= 2)) || fail "--access-token-env requires a value."
      access_token_env=$2
      shift 2
      ;;
    --max-pages)
      (($# >= 2)) || fail "--max-pages requires a value."
      max_pages=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

command -v python3 >/dev/null 2>&1 || fail "python3 is required."
[[ -f "$client_settings_path" ]] || fail "Client settings file not found: $client_settings_path"
[[ -f "$ownership_path" ]] || fail "Ownership file not found: $ownership_path"
[[ "$max_pages" =~ ^[0-9]+$ ]] || fail "--max-pages must be an integer."
((max_pages >= 1 && max_pages <= 100)) || fail "--max-pages must be between 1 and 100."
[[ -n "${!access_token_env:-}" ]] || fail \
  "Set $access_token_env through the approved OAuth credential helper. Do not pass the token as an argument."

python3 - "$client_settings_path" "$ownership_path" "$access_token_env" "$max_pages" <<'PY'
import json
import os
import sys
import urllib.parse
import urllib.request

client_path, ownership_path, token_env, max_pages_text = sys.argv[1:]
max_pages = int(max_pages_text)

with open(client_path, encoding="utf-8") as handle:
    client_text = handle.read()
with open(ownership_path, encoding="utf-8") as handle:
    ownership_text = handle.read()
if "__REQUIRED_" in client_text or "__REQUIRED_" in ownership_text:
    raise SystemExit(
        "Run preflight and resolve every required decision before checking live discovery."
    )

client = json.loads(client_text)
ownership = json.loads(ownership_text)
token = os.environ[token_env]
endpoint = client["registry"]["endpoint"]
approved = sorted(
    {
        entry["name"]
        for entry in ownership.get("approvedServers", [])
        if entry.get("name")
    }
)
if not approved:
    raise SystemExit("The ownership record has no approved server names.")

headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/json",
}
discovered = set()
cursor = None
pages = 0

while True:
    pages += 1
    if pages > max_pages:
        raise SystemExit(f"Registry pagination exceeded max-pages={max_pages}.")

    url = endpoint
    if cursor:
        url = f"{endpoint}?{urllib.parse.urlencode({'cursor': cursor})}"
    request = urllib.request.Request(url, headers=headers, method="GET")
    with urllib.request.urlopen(request) as response:
        payload = json.load(response)

    servers = payload.get("servers")
    if not isinstance(servers, list):
        raise SystemExit(
            "The registry response does not contain the MCP Registry API v0.1 servers array."
        )
    for item in servers:
        name = item.get("server", {}).get("name")
        if not isinstance(name, str) or not name.strip():
            raise SystemExit("A registry entry does not contain server.name.")
        discovered.add(name)

    cursor = payload.get("metadata", {}).get("nextCursor")
    if not cursor:
        break

missing = set(approved) - discovered
unexpected = discovered - set(approved)
if missing:
    raise SystemExit(
        f"Registry discovery is missing {len(missing)} approved server name(s)."
    )
if unexpected:
    raise SystemExit(
        f"Registry discovery returned {len(unexpected)} unapproved server name(s). "
        "Names are not printed."
    )

print(
    f"PASS: Registry discovery returned {len(discovered)} approved server name(s), "
    f"zero unapproved server names, across {pages} page(s)."
)
PY
