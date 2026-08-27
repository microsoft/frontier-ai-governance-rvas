#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
tmpdir="$(mktemp -d)"
cleanup() {
  [[ -d "$tmpdir" ]] && rm -rf -- "$tmpdir"
}
trap cleanup EXIT

usage() {
  cat <<'USAGE'
Usage: ./scripts/connectivity-check.sh [--endpoint-matrix-path <path>] [--timeout-seconds <seconds>]

Validate that each current endpoint resolves only to RFC 1918 IPv4 addresses and accepts TCP 443
from the current approved private execution host.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

endpoint_matrix_path="$script_dir/../artifacts/network/endpoint-matrix.json"
timeout_seconds='8'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --endpoint-matrix-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      endpoint_matrix_path="$2"
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

[[ -f "$endpoint_matrix_path" ]] || die "Endpoint matrix is missing: $endpoint_matrix_path"
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

python3 - "$endpoint_matrix_path" "$timeout_seconds" <<'PY'
import ipaddress
import json
import socket
import sys

matrix_path = sys.argv[1]
try:
    timeout_seconds = int(sys.argv[2])
except ValueError as exc:
    raise SystemExit('TimeoutSeconds must be an integer.') from exc
if timeout_seconds < 2 or timeout_seconds > 30:
    raise SystemExit('TimeoutSeconds must be between 2 and 30 seconds.')
with open(matrix_path, encoding='utf-8') as handle:
    matrix = json.load(handle)
if matrix.get('implementationSession') != '04-private-networking-dns':
    raise SystemExit('The endpoint matrix has the wrong implementation marker.')
expected = {'foundry', 'storage-blob', 'ai-search', 'cosmos-sql', 'key-vault'}
endpoints = matrix.get('endpoints') or []
aliases = [str(item.get('alias', '')).strip().lower() for item in endpoints]
fqdns = [str(item.get('fqdn', '')).strip().lower() for item in endpoints]
if len(aliases) != len(expected) or set(aliases) != expected:
    raise SystemExit('The endpoint matrix must contain the five unique aliases: foundry, storage-blob, ai-search, cosmos-sql, key-vault.')
if any(not fqdn for fqdn in fqdns) or len(set(fqdns)) != len(expected):
    raise SystemExit('The endpoint matrix must contain one distinct FQDN for each approved service.')
private_networks = [
    ipaddress.ip_network('10.0.0.0/8'),
    ipaddress.ip_network('172.16.0.0/12'),
    ipaddress.ip_network('192.168.0.0/16'),
]
for endpoint in endpoints:
    alias = str(endpoint.get('alias', '')).strip().lower()
    fqdn = str(endpoint.get('fqdn', '')).strip()
    try:
        resolved = sorted({
            result[4][0]
            for result in socket.getaddrinfo(fqdn, None, socket.AF_INET, socket.SOCK_STREAM)
        })
    except socket.gaierror as exc:
        raise SystemExit(f"Endpoint '{alias}' DNS lookup failed: {exc}") from exc
    if not resolved:
        raise SystemExit(f"Endpoint '{alias}' did not resolve to an IPv4 address.")
    for address in resolved:
        ip = ipaddress.ip_address(address)
        if not any(ip in network for network in private_networks):
            raise SystemExit(f"Endpoint '{alias}' did not resolve only to RFC 1918 IPv4 addresses.")
    try:
        with socket.create_connection((fqdn, 443), timeout=timeout_seconds):
            pass
    except OSError as exc:
        raise SystemExit(f"Endpoint '{alias}' did not accept TCP 443.") from exc
    print(f"PASS: {alias} uses private DNS and accepts TCP 443.")
print('PASS: Current endpoint connectivity is available from this host.')
PY
