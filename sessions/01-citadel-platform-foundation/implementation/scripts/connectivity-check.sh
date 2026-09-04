#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
parameter_path="$script_dir/../artifacts/environments/sandbox.bicepparam"
timeout_seconds='8'

usage() {
  cat <<'USAGE'
Usage: ./scripts/connectivity-check.sh [--parameter-path <path>] [--timeout-seconds <seconds>]

Derive the seven current service FQDNs from approved resource IDs and validate that each resolves
only to RFC 1918 IPv4 addresses and accepts TCP 443 from the current private execution host.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --parameter-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      parameter_path="$2"
      shift 2
      ;;
    --timeout-seconds)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      timeout_seconds="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown option: $1"
      ;;
  esac
done

[[ -f "$parameter_path" ]] || die "Parameter file is missing: $parameter_path"
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

python3 - "$parameter_path" "$timeout_seconds" <<'PY'
import ipaddress
from pathlib import Path
import re
import socket
import sys

parameter_path = Path(sys.argv[1])
try:
    timeout_seconds = int(sys.argv[2])
except ValueError as exc:
    raise SystemExit("timeout-seconds must be an integer.") from exc
if timeout_seconds < 2 or timeout_seconds > 30:
    raise SystemExit("timeout-seconds must be between 2 and 30 seconds.")

text = parameter_path.read_text(encoding="utf-8")
fields = {
    "foundry": "foundryResourceId",
    "storage": "storageResourceId",
    "search": "searchResourceId",
    "cosmos": "cosmosResourceId",
    "key-vault": "keyVaultResourceId",
}
names = {}
for alias, field in fields.items():
    matches = re.findall(
        rf"^\s*param\s+{re.escape(field)}\s*=\s*'([^']+)'\s*$",
        text,
        flags=re.MULTILINE,
    )
    if len(matches) != 1 or not matches[0].strip().rstrip("/").split("/")[-1]:
        raise SystemExit(f"Parameter '{field}' must contain exactly one valid resource ID.")
    names[alias] = matches[0].strip().rstrip("/").split("/")[-1]

endpoints = [
    ("foundry-cognitive", f"{names['foundry']}.cognitiveservices.azure.com"),
    ("foundry-openai", f"{names['foundry']}.openai.azure.com"),
    ("foundry-services", f"{names['foundry']}.services.ai.azure.com"),
    ("storage-blob", f"{names['storage']}.blob.core.windows.net"),
    ("ai-search", f"{names['search']}.search.windows.net"),
    ("cosmos-sql", f"{names['cosmos']}.documents.azure.com"),
    ("key-vault", f"{names['key-vault']}.vault.azure.net"),
]
private_networks = [
    ipaddress.ip_network("10.0.0.0/8"),
    ipaddress.ip_network("172.16.0.0/12"),
    ipaddress.ip_network("192.168.0.0/16"),
]
for alias, fqdn in endpoints:
    try:
        resolved = sorted({
            result[4][0]
            for result in socket.getaddrinfo(fqdn, None, socket.AF_INET, socket.SOCK_STREAM)
        })
    except socket.gaierror as exc:
        raise SystemExit(f"Endpoint '{alias}' DNS lookup failed: {exc}") from exc
    if not resolved or any(
        not any(ipaddress.ip_address(address) in network for network in private_networks)
        for address in resolved
    ):
        raise SystemExit(f"Endpoint '{alias}' did not resolve only to RFC 1918 IPv4 addresses.")
    try:
        with socket.create_connection((fqdn, 443), timeout=timeout_seconds):
            pass
    except OSError as exc:
        raise SystemExit(f"Endpoint '{alias}' did not accept TCP 443.") from exc
    print(f"PASS: {alias} uses private DNS and accepts TCP 443.")
print("PASS: Current endpoint connectivity is available from this host.")
PY
