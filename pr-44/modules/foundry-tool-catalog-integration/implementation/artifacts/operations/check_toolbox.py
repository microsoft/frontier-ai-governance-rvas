#!/usr/bin/env python3
"""Check one version-specific Microsoft Foundry Toolbox MCP endpoint."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import urllib.error
import urllib.request
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--endpoint", required=True)
    parser.add_argument("--expected-tool", required=True)
    return parser.parse_args()


def get_access_token() -> str:
    result = subprocess.run(
        [
            "az",
            "account",
            "get-access-token",
            "--resource",
            "https://ai.azure.com",
            "--query",
            "accessToken",
            "--output",
            "tsv",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    token = result.stdout.strip()
    if not token:
        raise RuntimeError("Azure CLI returned an empty Microsoft Foundry access token.")
    return token


def decode_response(body: bytes, content_type: str) -> dict[str, Any]:
    text = body.decode("utf-8").strip()
    if not text:
        return {}
    if "text/event-stream" in content_type:
        data_lines = [
            line[5:].strip()
            for line in text.splitlines()
            if line.startswith("data:")
        ]
        if not data_lines:
            raise RuntimeError("The Toolbox endpoint returned an empty event stream.")
        text = data_lines[-1]
    value = json.loads(text)
    if not isinstance(value, dict):
        raise RuntimeError("The Toolbox endpoint returned an unexpected JSON value.")
    return value


def post_json(
    endpoint: str,
    token: str,
    payload: dict[str, Any],
    session_id: str | None = None,
) -> tuple[dict[str, Any], str | None]:
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
    }
    if session_id:
        headers["Mcp-Session-Id"] = session_id
    request = urllib.request.Request(
        endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            result = decode_response(
                response.read(),
                response.headers.get("Content-Type", ""),
            )
            return result, response.headers.get("Mcp-Session-Id") or session_id
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(
            f"Toolbox request failed with HTTP {error.code}: {detail[:500]}"
        ) from error


def main() -> int:
    args = parse_args()
    if not args.endpoint.startswith("https://"):
        raise RuntimeError("The Toolbox endpoint must use HTTPS.")
    if "/toolboxes/" not in args.endpoint or "/versions/" not in args.endpoint:
        raise RuntimeError("Use a version-specific Toolbox endpoint for this check.")
    if "api-version=v1" not in args.endpoint:
        raise RuntimeError("The Toolbox endpoint must use api-version=v1.")

    token = get_access_token()
    initialized, session_id = post_json(
        args.endpoint,
        token,
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2025-03-26",
                "capabilities": {},
                "clientInfo": {
                    "name": "foundry-tool-catalog-integration-check",
                    "version": "1.0",
                },
            },
        },
    )
    if initialized.get("error"):
        raise RuntimeError(f"Toolbox initialization failed: {initialized['error']}")

    post_json(
        args.endpoint,
        token,
        {
            "jsonrpc": "2.0",
            "method": "notifications/initialized",
        },
        session_id,
    )
    listed, _ = post_json(
        args.endpoint,
        token,
        {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list",
            "params": {},
        },
        session_id,
    )
    if listed.get("error"):
        raise RuntimeError(f"Toolbox tools/list failed: {listed['error']}")

    tools = listed.get("result", {}).get("tools", [])
    names = sorted(
        tool.get("name")
        for tool in tools
        if isinstance(tool, dict) and isinstance(tool.get("name"), str)
    )
    if names != [args.expected_tool]:
        raise RuntimeError(
            "Expected exactly one approved tool "
            f"'{args.expected_tool}', but received: {names}"
        )

    tool = next(item for item in tools if item.get("name") == args.expected_tool)
    approval = (
        tool.get("_meta", {})
        .get("tool_configuration", {})
        .get("require_approval")
    )
    if approval != "always":
        raise RuntimeError(
            "The approved tool is present, but require_approval is not 'always'."
        )

    print(
        "PASS: the version-specific Toolbox endpoint exposes exactly "
        f"'{args.expected_tool}' with approval required."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1) from error

