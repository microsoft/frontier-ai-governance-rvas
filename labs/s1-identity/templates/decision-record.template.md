# S1 Identity & Access Decision Record

Copy this template into the customer's approved records system. Use it to record
the required customer decision for S1 Identity & Access.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, telemetry exports, live
> configuration, access grants, or tenant changes in this repository.

## Scope

| Field | Record |
|---|---|
| Bounded agent / workload / portfolio scope reference | |
| Identity source coverage checked | Agent ID / Agent 365 / Entra app / service principal / managed identity / federated workload identity / host record / Conditional Access / RBAC / other |
| Identity type | Agent identity / app registration / service principal / managed identity / federated workload identity / delegated user context / not applicable / unknown |
| Agent / host mapping reference | |
| Runtime host / deployment environment reference | |
| Decision owner | |
| Identity administrator | |
| Human sponsor | |
| Technical / implementation owner | |
| Evidence owner | |
| Handoff owner | |
| Approved records location | |
| Stop condition | |
| Target date | |

## Microsoft control path

Default path: **Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available**

Inspect: inspect the Entra application or managed identity record, Agent
ID/Agent 365 record when available, Conditional Access assignment, Azure RBAC
scope, gateway or tool boundary, and identity owner record. Confirm the record
exists, has an accountable owner, names the environment/scope, and can be
referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available | | | | | |

## Identity path review

Record references only. Do not copy identifiers, configuration, token claims,
secrets, prompts, outputs, exports, or access assignments.

| Review field | Record |
|---|---|
| Agent or workload record result | Result / no-result / unsupported / blocked |
| Identity source coverage | Which approved records were checked and which were not applicable |
| Agent / host mapping | Which host can assert or obtain the runtime identity |
| Owner able to disable or rotate | |
| Human sponsor | |
| Lifecycle status | Requested / designed / approved for pilot / active / suspended / retiring / retired |
| Review cadence | |
| Emergency disable path reference | |
| Decommission condition | |
| Credential or federation owner | |
| Credential type or federation pattern | Secret avoided / certificate / managed identity / workload federation / other safe reference |
| Token issuer or trust boundary reference | |
| Rotation or expiration expectation | |
| Access boundary | Subscription / resource group / workspace / API / connector / gateway / tool boundary reference |
| Access scope assessment | Needed / excessive / unknown / unused / not applicable |
| Conditional Access reference | |
| RBAC / API permission / Graph scope reference | |
| Gateway or tool-control reference | |
| OBO / delegated authority route | Approved for bounded use / designed / accepted risk / not applicable / blocked |
| Consent or delegated permission owner | |
| Downstream API or tool boundary reference | |
| Revocation verification route | |
| OBO audit / investigation route | |
| Security reviewer | |
| Review date | |
| Next review trigger | Purpose change / scope change / credential change / owner change / CA/RBAC change / incident / scheduled review / decommission |

## Customer decision

| Decision field | Record |
|---|---|
| Result | Approve / defer / reject / route / blocked |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Review date | |
| Next review trigger | |

## Required considerations

Use the prompts below only to make the single decision complete. Do not create
separate customer records unless the receiving owner asks for them. Keep answers
short and references-only.

- Identity source coverage: Which Agent ID/Agent 365, Entra workload identity,
  host, Conditional Access, RBAC, gateway, and owner/lifecycle records were
  checked?
- Runtime mapping: Which identity does the agent use at runtime, and which host
  workload can assert or obtain it?
- Sponsorship and lifecycle: Which human sponsor is accountable, what lifecycle
  state is recorded, and what event forces re-approval?
- Credential/federation: Who owns the credential or federation path, what trust
  boundary can mint tokens, and what review or rotation trigger applies?
- Least privilege: Which access boundary is minimum for the bounded workload,
  and which assignments are needed, excessive, unknown, unused, or not
  applicable?
- Conditional Access, RBAC, and gateway controls: Which records show the
  applicable policy, role, scope, connector, API, gateway, or tool boundary?
- OBO/delegated authority: If the agent acts on behalf of a user, which consent,
  downstream API, revocation, and audit/investigation routes apply?
- Handoff: Which owner accepts backlog items, target dates, acceptance tests,
  exception state, and evidence locations?


## Session-specific review questions

Use this table to preserve the lesson-specific review questions or record
references that shaped the decision. Keep the entries short and references-only;
do not paste prompt text, outputs, or customer data.

| Review question or reference | Customer answer / reference | Decision impact |
|---|---|---|
| | | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Equivalent control | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create an identity backlog item for each gap that prevents an owned,
least-privilege, reviewable identity path. Use the customer-approved backlog and
records system.

| Backlog category | When to use | Required handoff fields |
|---|---|---|
| Missing sponsor | No accountable business sponsor, technical owner, identity owner, security reviewer, or operations handoff owner is recorded | Owner, dependency, impact, acceptance test, target date, approved records location |
| Agent ID coverage investigation | Agent ID/Agent 365 or agent identity record is unavailable, unsupported, or not checked for the bounded scope | Control path, investigation owner, product/support reference if applicable, acceptance test, target date |
| Credential hygiene | Credential/federation owner, trust boundary, rotation, expiration, or disable path is unknown or unreviewable | Credential/federation owner, hygiene expectation, evidence reference, acceptance test, target date |
| Least-privilege RBAC | RBAC, API permission, Graph scope, connector, or resource assignment is excessive, unknown, unused, or unowned | Scope owner, minimum-needed access statement, evidence reference, acceptance test, target date |
| Conditional Access scope | Conditional Access, workload identity policy, gateway, or tool-control coverage is missing, unclear, or out of scope | Policy/control owner, scope reference, exception state, acceptance test, target date |
| OBO audit route | Delegated authority, consent, revocation, downstream API, or investigation route is unclear or blocked | API/tool owner, audit route reference, revocation verification, acceptance test, target date |
| S9 reconciliation | Identity decision must be reconciled with S9 controls, residual-risk acceptance, or downstream security operations handoff | S9 owner, reconciliation question, evidence location, acceptance test, target date |

Handoff to identity platform owner, application/workload owner, and security
operations. The receiving owner accepts only backlog items with a clear
Microsoft control path, owner, evidence location, acceptance test, exception
state if any, target date, and customer handoff process. Keep final records in
the customer-approved system.

## Safe filled examples

These examples show the expected depth without storing customer identifiers,
secrets, prompts, outputs, telemetry exports, live configuration, access grants,
or tenant changes.

| Field | Safe example |
|---|---|
| Bounded scope reference | "Customer record CR-### for one pilot support-assist workload in the approved records system" |
| Identity source coverage checked | "Agent ID availability checked; Entra app/service principal and host workload records referenced; Conditional Access and RBAC records referenced; Graph/API permissions reviewed by customer owner" |
| Identity type | "Federated workload identity for host runtime; no delegated user context in this bounded path" |
| Agent / host mapping reference | "Customer architecture record links the agent runtime host to the workload identity; no IDs copied here" |
| Human sponsor | "Business sponsor role named in customer record; sponsor gap backlog not required" |
| Lifecycle status | "Approved for pilot, with decommission condition recorded before production expansion" |
| Credential or federation owner | "Identity platform owner owns workload federation trust; application owner owns host configuration reference" |
| Access boundary | "Minimum scope limited to the named workspace/API boundary in customer evidence record" |
| OBO / delegated authority route | "Not applicable for this decision; separate route required if user-delegated tools are added" |
| Conditional Access / RBAC / gateway references | "Customer evidence records for workload identity policy, least-privilege role assignment, and gateway/tool boundary review" |
| Review date and next trigger | "Reviewed on YYYY-MM-DD; re-review on purpose change, owner change, credential/federation change, RBAC/CA change, or scheduled cadence" |
| Backlog example | "Least-privilege RBAC: receiving owner validates one unknown assignment, records acceptance test, target date, and evidence location in the customer backlog" |
