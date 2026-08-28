# Agent inventory operator snapshot

This Session 15 record is a dated operator snapshot. It is not proof of current service state.

| Field | Observation |
|---|---|
| Snapshot date | `__REQUIRED_INVENTORY_SNAPSHOT_DATE__` |
| System of record | `__REQUIRED_OPERATIONAL_RECORD_STORE__` |
| Runtime output committed to this repository | No |

## Live resource routes

| Surface | Observation route |
|---|---|
| Foundry project resource | Queried by preflight |
| Application Insights resource | Queried by preflight |

The machine-owned resource IDs remain in `control-definition.json` and `region.parameters.json`.
They are not copied into this snapshot.

## Operator visibility observations

| Field | Observation |
|---|---|
| Foundry Control Plane agent visibility | `__REQUIRED_FOUNDRY_CONTROL_PLANE_VISIBILITY_STATUS__` |
| Microsoft Agent 365 registry visibility | `__REQUIRED_AGENT_365_VISIBILITY_STATUS__` |
| Microsoft Purview agent visibility | `__REQUIRED_PURVIEW_VISIBILITY_STATUS__` |
| Microsoft Defender agent visibility | `__REQUIRED_DEFENDER_VISIBILITY_STATUS__` |

## Governed agent

| Field | Observation |
|---|---|
| Name | `__REQUIRED_FOUNDRY_AGENT_NAME__` |
| Immutable version | `__REQUIRED_AGENT_VERSION__` |
| Owner | `__REQUIRED_AGENT_OWNER__` |
| Business service | `__REQUIRED_BUSINESS_SERVICE_NAME__` |
| Lifecycle state | Production |

## Microsoft Agent 365

| Field | Observation |
|---|---|
| Registry ID | `__REQUIRED_AGENT_365_REGISTRY_ID__` |
| Microsoft Entra agent identity ID | `__REQUIRED_AGENT_IDENTITY_ID__` |

## MCP server

| Field | Observation |
|---|---|
| Inventory ID | `__REQUIRED_MCP_SERVER_INVENTORY_ID__` |
| Owner | `__REQUIRED_MCP_OWNER__` |
| Lifecycle state | Production |
