# API Center catalog to Foundry Toolbox artifacts

These files keep one approved remote MCP server aligned from its Azure API Center record to one
dedicated Toolbox in Microsoft Foundry.

| Path | Operational purpose |
|---|---|
| `governance/catalog-toolbox-binding.json` | Records the approved catalog source, preview decision, Foundry project connection, expected tool, ownership, and restore route |
| `toolbox/toolbox-version.json` | Defines the one-tool immutable Toolbox version sent to the Microsoft Foundry data-plane API |
| `operations/check_toolbox.py` | Lists tools through the version-specific Toolbox MCP endpoint and checks the exact allow-listed result |

Resolve every `__REQUIRED_*__` value in an approved private working copy before running preflight.
Do not commit filled tenant IDs, subscription IDs, resource IDs, endpoints, credentials, tokens, or
tool results.

