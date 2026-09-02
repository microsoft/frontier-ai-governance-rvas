# Agent portfolio operating model

| Decision | Owner role | Authoritative system | Handoff |
|---|---|---|---|
| Business purpose, use cases, tools, and data | `__REQUIRED_BUSINESS_SPONSOR_ROLE__` | Microsoft Agent 365 and source platform | Portfolio owner |
| Agent classification | `__REQUIRED_PORTFOLIO_OWNER_ROLE__` | `portfolio-decision.json` | Release owner |
| Identity and access boundary | Identity owner | Microsoft Entra ID | Security owner |
| API publication | API platform owner | Azure API Management and Azure API Center | Release owner |
| Duplicate review | `__REQUIRED_PORTFOLIO_OWNER_ROLE__` | Agent 365 and API Center inventory | Business sponsor |
| Production release | `__REQUIRED_RELEASE_OWNER_ROLE__` | Approved release platform | Operations owner |
| Cross-platform retirement | `__REQUIRED_RETIREMENT_COORDINATOR_ROLE__` | Source platform and enterprise registry | Identity, API, and audit owners |

## Rules

- Microsoft Agent 365 remains the enterprise agent inventory when it supports the agent.
- Azure API Center remains the API, MCP, and A2A design-time catalog.
- The source platform remains authoritative for runtime versions and deployment state.
- Azure API Management remains authoritative for runtime API policy.
- The portfolio decision record links to live records and stores only decisions that no single
  service can reconstruct.
- Use role aliases, not personal names.
- A similarity score can flag a possible duplicate. The portfolio owner makes the decision.
- A team or division orchestrator follows the same portfolio decision process. This module does
  not build one.
