# Enterprise agent portfolio standards

## Module scope

### What we will do

**Objective.** Define one enterprise standard for agent classification, ownership, architecture, API publication,
lifecycle, and retirement.

Apply the standard to one candidate agent before production. The module check confirms that the
candidate points to the right authoritative records, then checks the classification, framework
path, duplicate decision, lifecycle move, owner roles, and retirement coordination.

### Why it matters

**Problem.** Agent 365, Azure API Center, Azure API Management, and source platforms hold different
parts of the same agent. None of them holds the full business and operating decision.

**Solution.** A small cross-platform decision closes that gap. It links to live records instead of
copying them.

### Boundaries

This optional module sits outside the 13-session route. Use it with an existing Agent 365 or Azure
API Center inventory.

Microsoft Agent 365 remains authoritative for the enterprise agent inventory. Azure API Center
holds API, MCP, and A2A catalog records. Azure API Management holds runtime API policy. The source
platform holds agent versions and deployment state. The repository holds the standards and
cross-platform decisions that those systems cannot reconstruct.

The module does not build an enterprise router, a metadata application, or a new registry. A team
or division orchestrator is another governed agent and needs its own record.

A read-only deployment preview is unsupported because this module does not deploy or change live
resources. Preflight validates the retained decision contract before platform owners apply it
through their existing change processes.

## Architecture

### Architecture at a glance

The portfolio owner starts with one candidate from the live inventory. The team records stable
references to the inventory, API catalog, identity, gateway policy, and source platform. It then
makes the few decisions that those systems do not hold together.

An approved record then feeds the normal platform paths:

```text
Business and portfolio decision
        |
        v
portfolio-decision.json
        |
        +--> references Agent 365 inventory
        +--> references API Center metadata
        +--> references APIM policy and Entra identity
        +--> references the source-platform version
```

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Portfolio decision | References plus cross-platform decisions | Avoids another inventory | Source references must remain stable |
| Classification | Four small purpose classes | Gives the estate a common language | Some agents need an approved overlap |
| Framework choice | Microsoft Agent Framework or Semantic Kernel by default; exception for another framework | Makes the normal path clear | The exception owner must support the runtime |
| API publication | Azure API Management plus Azure API Center | Separates runtime policy from design-time discovery | Existing direct paths need migration |
| Duplicate detection | Inventory comparison with human decision | Finds reuse opportunities without automating approval | Similarity tooling can flag, not decide |

### Architecture guidance

- [Manage agents in the Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry)
- [Use metadata to organize and govern APIs in Azure API Center](https://learn.microsoft.com/en-us/azure/api-center/metadata)
- [What is Microsoft Foundry Agent Service?](https://learn.microsoft.com/en-us/azure/foundry/agents/overview)

## Before you start

Confirm these requirements:

- One candidate agent exists in an approved nonproduction source platform.
- The Agent 365 or API Center owner can find its current inventory record.
- The source-platform owner can provide a stable reference to the candidate version.
- The API platform owner can provide stable references to its API Center record and API Management
  policy.
- The identity owner can provide the Microsoft Entra ID reference.
- The business sponsor and portfolio owner can decide whether an existing agent should be reused.
- The release and retirement owners can state how to block, deprecate, and remove the agent.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Runtime | [`artifacts/portfolio-standard.json`](artifacts/portfolio-standard.json) | The portfolio governance process and module preflight scripts |
| Record | [`artifacts/portfolio-decision.json`](artifacts/portfolio-decision.json) | The portfolio owner and release process |
| Record | [`artifacts/governance/operating-model.md`](artifacts/governance/operating-model.md) | The AI portfolio, platform, security, data, release, and business owners |

## Decisions and stop conditions

### Set the portfolio boundary

Choose one business or platform scope. Use the same value in both JSON files and when running
preflight. Keep tenant IDs, subscription IDs, endpoints, credentials, prompts, responses, and
customer data out of these files.

### Classify the candidate

Choose the class that best describes the agent's main job:

| Class | Use when |
|---|---|
| `orchestrator` | The agent selects or coordinates other agents and tools |
| `business-process` | The agent completes a named business workflow |
| `specialist` | The agent supplies a bounded skill or domain service |
| `data` | The agent retrieves, transforms, or reasons over a governed data product |

Record one main class. Use `approved-overlap` in the duplicate decision when the portfolio owner
accepts a deliberate overlap with an existing agent.

### Choose the build and runtime path

Record `native-platform` when the candidate uses its source platform's supported path. For a hosted
agent or custom runtime, choose Microsoft Agent Framework or Semantic Kernel. Use
`other-by-exception` only with an approval reference.

### Set API publication conventions

Link to the approved API Center record and API Management policy. The live systems remain
authoritative for metadata, naming, and runtime policy. Stop when either reference is missing or
the candidate uses an unapproved direct path.

### Review duplicates and retirement

Compare business purpose, use cases, tools, data sources, and source platform with the live
inventory. A search or similarity tool may suggest matches. The portfolio owner decides whether to
reuse, accept overlap, or add a new capability.

Name one retirement coordinator and link to the approved cross-platform retirement plan. The plan
must cover user access, API publication, identity, runtime removal, and audit retention. Stop when
the coordinator or plan is missing.

## Implement

### 1. Complete the standard

Review `portfolio-standard.json` with the portfolio and platform owners. Change the approved
taxonomy, frameworks, lifecycle transitions, and retirement actions only through the customer
governance process.

### 2. Complete the operating model

Replace every role sentinel in `operating-model.md` with a stable team or role alias. Do not use
personal email addresses.

### 3. Complete the portfolio decision

Fill `portfolio-decision.json` with stable references from the live source systems. Record the
classification, framework path, duplicate decision, next lifecycle state, and retirement plan
reference. Do not copy the agent description, tools, data sources, or runtime configuration.

### 4. Run preflight

```powershell
$targetScope = "<approved portfolio scope>"
.\scripts\preflight.ps1 -TargetScope $targetScope
```

```bash
target_scope="<approved portfolio scope>"
./scripts/preflight.sh --target-scope "$target_scope"
```

Preflight checks the markers, exact scope, authoritative references, classification, framework
path, owner roles, lifecycle transition, duplicate decision, and retirement coordination.

### 5. Apply the platform handoffs

Use the decision in the normal release review. Update Agent 365, API Center, API Management, Entra
ID, or the source platform only when an owning team identifies a mismatch in its live record.

## Confirm the result

Run preflight against the completed portfolio decision. It must return:

```text
PASS: Portfolio decisions are complete for '<scope>'.
```

The portfolio owner then opens each referenced record and confirms that it identifies the same
candidate. The check validates the retained decisions. It does not replace any live inventory or
platform control.

## After implementation

The portfolio owner maintains the standard. Update the decision when its classification, framework
exception, lifecycle approval, duplicate decision, owners, or source references change. The release
owner uses it before production. The retirement coordinator uses the linked plan across the
registry, gateway, identity, and source platform.

To restore a rejected portfolio change, keep the agent in its prior lifecycle state and revert the
decision through source control. If the candidate was already published, use the owning
platform change paths to restore its prior API, catalog, availability, and runtime settings. Do not
delete audit records or a shared registry entry as a shortcut.
