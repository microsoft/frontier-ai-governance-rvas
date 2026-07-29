# S1 Identity Review Addendum

Use this addendum with the shared [`../../templates/decision-record.template.md`](../../templates/decision-record.template.md). Copy both into the customer's approved records system when the identity decision needs detailed identity-path review.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, token claims, or tenant changes in this repository.

## Identity scope

| Field | Record |
|---|---|
| Bounded agent / workload / portfolio scope reference | |
| Identity source coverage checked | Agent ID / Agent 365 / Entra app / service principal / managed identity / federated workload identity / host record / Conditional Access / RBAC / other |
| Identity type | Agent identity / app registration / service principal / managed identity / federated workload identity / delegated user context / not applicable / unknown |
| Agent / host mapping reference | |
| Runtime host / deployment environment reference | |
| Runtime authority mode | App-only / autonomous / OBO delegated / mixed / unknown |
| Identity administrator | |
| Human sponsor | |
| Handoff owner | |
| Stop condition | |

## Identity path review

Record references only. Do not copy identifiers, configuration, token claims, secrets, prompts, outputs, exports, or access assignments.

| Review field | Record |
|---|---|
| Agent or workload record result | Result / no-result / unsupported / blocked |
| Identity source coverage | Which approved records were checked and which were not applicable |
| Agent / host mapping | Which host can assert or obtain the runtime identity |
| Runtime mode separation | App-only path / OBO path / mixed with separated authority sections / unknown |
| Owner able to disable or rotate | |
| Human sponsor | |
| Lifecycle status | Requested / designed / approved for pilot / active / suspended / retiring / retired |
| Review cadence | |
| Emergency disable path reference | |
| Decommission condition | |
| Credential or federation owner | |
| Credential type or federation pattern | Secret avoided / certificate / managed identity / workload federation / other safe reference |
| Token issuer or trust boundary reference | |
| Token-flow evidence reference | Host token / blueprint or identity trust / agent token / resource token / authorization / audit references |
| Rotation or expiration expectation | |
| Access boundary | Subscription / resource group / workspace / API / connector / gateway / tool boundary reference |
| Access scope assessment | Needed / excessive / unknown / unused / not applicable |
| Denied actions | Production change / destructive action / tenant-wide action / data export / privilege elevation / other |
| Conditional Access reference | |
| RBAC / API permission / Graph scope reference | |
| Gateway or tool-control reference | |
| OBO / delegated authority route | Approved for bounded use / designed / accepted risk / not applicable / blocked |
| Consent or delegated permission owner | |
| Downstream API or tool boundary reference | |
| Revocation verification route | |
| OBO audit / investigation route | |
| Disable route | Agent identity disable / host credential or federation revocation / RBAC or API permission removal / gateway route suspension / backend block |
| Audit correlation route | Sign-in / audit / gateway / app trace / resource log / SIEM or log workspace reference |
| Provisioning automation backlog | Not needed / GitHub Actions OIDC / customer CI/CD / Graph permission review / blocked |
| Security reviewer | |
| Review date | |
| Next review trigger | Purpose change / scope change / credential change / owner change / CA/RBAC change / incident / scheduled review / decommission |

## Identity review questions

- Which Agent ID/Agent 365, Entra workload identity, host, Conditional Access, RBAC, gateway, and owner/lifecycle records were checked?
- Which identity does the agent use at runtime, and which host workload can assert or obtain it?
- Is the runtime path app-only, OBO, or mixed, and where are those authority decisions separated?
- Which human sponsor is accountable, what lifecycle state is recorded, and what event forces re-approval?
- Who owns the credential or federation path, what trust boundary can mint tokens, and what review or rotation trigger applies?
- Which access boundary is minimum for the bounded workload, and which assignments are needed, excessive, unknown, unused, or not applicable?
- Which actions are explicitly denied, and what fail-closed behavior applies when scope, identity, or consent is missing?
- Which records show the applicable Conditional Access policy, RBAC role, API scope, connector, gateway, or tool boundary?
- If the agent acts on behalf of a user, which consent, downstream API, revocation, and audit/investigation routes apply?
- If the agent must be stopped, which object or route is disabled first and which audit metadata must be preserved?

## Identity backlog categories

| Backlog category | When to use | Required handoff fields |
|---|---|---|
| Missing sponsor | No accountable business sponsor, technical owner, identity owner, security reviewer, or operations handoff owner is recorded | Owner, dependency, impact, acceptance test, target date, approved records location |
| Agent ID coverage investigation | Agent ID/Agent 365 or agent identity record is unavailable, unsupported, or not checked for the bounded scope | Control path, investigation owner, product/support reference if applicable, acceptance test, target date |
| Credential hygiene | Credential/federation owner, trust boundary, rotation, expiration, or disable path is unknown or unreviewable | Credential/federation owner, hygiene expectation, evidence reference, acceptance test, target date |
| Least-privilege RBAC | RBAC, API permission, Graph scope, connector, or resource assignment is excessive, unknown, unused, or unowned | Scope owner, minimum-needed access statement, evidence reference, acceptance test, target date |
| Conditional Access scope | Conditional Access, workload identity policy, gateway, or tool-control coverage is missing, unclear, or out of scope | Policy/control owner, scope reference, exception state, acceptance test, target date |
| OBO audit route | Delegated authority, consent, revocation, downstream API, or investigation route is unclear or blocked | API/tool owner, audit route reference, revocation verification, acceptance test, target date |
| Denied-action definition | The path does not state which privileged, destructive, tenant-wide, data-export, or out-of-purpose actions must fail closed | Application/security owner, denied-action statement, enforcement owner, acceptance test, target date |
| Disable and audit route | The customer cannot identify which object or route stops the agent, or which logs distinguish user, host, agent, gateway, and backend action | Identity/platform/security owner, disable route reference, audit route reference, impact owner, acceptance test, target date |
| Provisioning automation | Identity objects, federated credentials, or permissions depend on CI/CD or Graph automation not yet reviewed | Pipeline owner, issuer/subject constraint, permission owner, rollback route, audit reference, acceptance test, target date |
| Control-plane reconciliation | Identity decision must be reconciled with control-plane records, residual-risk acceptance, or downstream security operations handoff | Control-plane owner, reconciliation question, evidence location, acceptance test, target date |

## Safe filled examples

| Field | Safe example |
|---|---|
| Bounded scope reference | "Customer record CR-### for one pilot support-assist workload in the approved records system" |
| Identity source coverage checked | "Agent ID availability checked; Entra app/service principal and host workload records referenced; Conditional Access and RBAC records referenced; Graph/API permissions reviewed by customer owner" |
| Identity type | "Federated workload identity for host runtime; no delegated user context in this bounded path" |
| Agent / host mapping reference | "Customer architecture record links the agent runtime host to the workload identity; no IDs copied here" |
| Runtime authority mode | "App-only background path; OBO not approved for this bounded decision" |
| Human sponsor | "Business sponsor role named in customer record; sponsor gap backlog not required" |
| Lifecycle status | "Approved for pilot, with decommission condition recorded before production expansion" |
| Credential or federation owner | "Identity platform owner owns workload federation trust; application owner owns host configuration reference" |
| Token-flow evidence reference | "Customer records reference host token, identity trust, target resource authorization, and audit route; no token claims copied here" |
| Access boundary | "Minimum scope limited to the named workspace/API boundary in customer evidence record" |
| Denied actions | "No tenant-wide changes, destructive production changes, privilege elevation, or bulk data export in this bounded path" |
| OBO / delegated authority route | "Not applicable for this decision; separate route required if user-delegated tools are added" |
| Conditional Access / RBAC / gateway references | "Customer evidence records for workload identity policy, least-privilege role assignment, and gateway/tool boundary review" |
| Disable and audit route | "Identity owner can revoke the federation path; gateway owner can suspend the route; audit references remain in customer records" |
| Review date and next trigger | "Reviewed on YYYY-MM-DD; re-review on purpose change, owner change, credential/federation change, RBAC/CA change, or scheduled cadence" |
| Backlog example | "Least-privilege RBAC: receiving owner validates one unknown assignment, records acceptance test, target date, and evidence location in the customer backlog" |
