---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Azure API Center registry discovery for approved MCP servers
description: Optional implementation module for Microsoft Entra-protected MCP registry discovery through Azure API Center.
---

<!-- _class: cover -->

![RVAP](assets/logos/logo-full.png)

# Azure API Center registry discovery

## Optional implementation module

Show developer clients the approved MCP servers.

<!-- Notes: This module stays outside the 14 sessions and follows Sessions 07 and 08. -->

---

## Control objective

Configure Microsoft Entra-protected Azure API Center MCP registry discovery for approved
Production-lifecycle MCP servers.

The check must return every approved name and zero unexpected names.

![Azure API Center](assets/icons/microsoft/azure-api-center.svg)

<!-- Notes: Discovery is a catalog decision. Runtime access remains separate. -->

---

## Why it matters

Session 07 records MCP servers. Session 08 secures their runtime path.

Developer clients still need a discovery view that excludes draft, retired, and unreviewed server
records.

<!-- Notes: The registry becomes useful when its visible set matches the release decision. -->

---

## Where the module fits

| Work | Owner |
|---|---|
| Session 07 | Register the MCP server and its inventory metadata |
| Session 08 | Set runtime authorization, tool boundaries, and telemetry |
| Optional module | Publish the approved discovery view to developer clients |

<!-- Notes: The module adds no session number and changes no session dependency. -->

---

## Control boundary

**In scope:** registry endpoint, Microsoft Entra access, Data API visibility, client handoff, and
the live allowlist check.

**Outside the module:** MCP server credentials, tool authorization, per-user visibility, and the
separate API Center MCP server at `/mcp`.

<!-- Notes: Discovery never grants runtime access to the server. -->

---

## Architecture overview

1. The MCP server passes the Session 08 decision.
2. Its API Center lifecycle moves to **Production**.
3. Data API visibility selects **MCP + Production**.
4. A Microsoft Entra-authenticated client reads the registry.
5. The operational check compares all returned names with the ownership record.

<!-- Notes: Azure API Center is authoritative for registry contents and visibility. -->

---

## Use the documented registry path

```text
https://<api-center-name>.data.<region>.azure-apicenter.ms/workspaces/default/v0.1/servers
```

Use the data-plane hostname, default workspace, and `v0.1`.

Do not substitute the portal URL or the separate `/mcp` catalog endpoint.

<!-- Notes: The Microsoft Learn page has a shortened example. The endpoint format includes /workspaces. -->

---

## Authentication and roles

- **Access method:** Microsoft Entra ID
- **Developer role:** Azure API Center Data Reader
- **Assignment scope:** the exact API Center resource
- **Delegated data-plane scope:** `https://azure-apicenter.net/Data.Read.All`
- **Anonymous access:** disabled

<!-- Notes: The role reads visible registry data. It does not authorize the discovered server. -->

---

<!-- _class: decision -->

## Visibility tradeoffs

| Choice | Route used here | Limit |
|---|---|---|
| Approval signal | `Lifecycle stage = Production` | Lifecycle must be governed as a release gate |
| Asset filter | `API type = MCP` | Conditions are global, not per user |
| Client settings | Adapter-neutral contract | Each client needs a current adapter |
| Restore | Portal-led prior-state restore | No documented management API is assumed |

<!-- Notes: Custom metadata can enrich _meta, but it is not the authorization boundary. -->

---

## Retained artifacts

**Client contract**

- registry endpoint;
- Microsoft Entra references;
- supported client handoffs; and
- approved server names.

**Ownership record**

- global visibility conditions;
- owner roles and review date; and
- restore reference.

<!-- Notes: Tokens, tenant IDs, application IDs, and server credentials stay outside the repository. -->

---

<!-- _class: implementation -->

## Implement the module

1. Complete both artifacts and run preflight.
2. Move approved MCP versions to **Production**.
3. Confirm Microsoft Entra access and Azure API Center Data Reader.
4. Configure and preview Data API visibility.
5. Map the registry endpoint into the supported client.
6. Run the live allowlist check.

<!-- Notes: Save the visibility change only when the preview matches the ownership record. -->

---

## Safety gates

- Stop on the portal hostname, `/mcp`, or an undocumented registry path.
- Stop if anonymous access is enabled.
- Stop if the visibility preview contains an unapproved MCP server.
- Stop if a client merges another registry without an owner decision.
- Stop if any token or server credential would enter source control.

<!-- Notes: A client fallback to a public registry changes the control boundary. -->

---

## Expected result

```text
PASS: Registry discovery returned <count> approved server name(s),
zero unapproved server names, across <pages> page(s).
```

The developer client can discover the approved record. Runtime authorization still decides
whether the client can connect to the MCP server and call a tool.

<!-- Notes: The script never prints unexpected server names. -->

---

## Operating state and restore

| Owner | Responsibility |
|---|---|
| API Center configuration owner | Visibility and registry metadata |
| MCP server owner | Lifecycle and review date |
| Client configuration owner | Current client adapter |
| Runtime and security owners | Session 08 access and tool controls |

Restore the prior portal visibility setting and remove the registry from managed clients. Keep the
inventory and runtime controls.

<!-- Notes: No removal script guesses an unsupported Data API settings interface. -->

---

<!-- _class: closing -->

# Thank you!
