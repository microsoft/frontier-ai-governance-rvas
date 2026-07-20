# S1 · Identity & Ownership — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Availability of Entra Agent ID, workload identity
    federation, and Conditional Access for workload identities varies by tenant
    and licensing. Confirm current status in the [Governance capability guide](../reference/governance-capability-guide.md)
    before delivery.

S1 decides how each agent gets a governable identity and how runtime access is
controlled. These menus record the next adoption step; they do not change the
tenant. The customer's identity-change process owns implementation.

![S1 illustrative identity pattern: a human sponsor governs agent identity and lifecycle; host workload identity, agent identity, delegated OBO, gateway access, and resource authorization remain separate decisions.](../assets/diagrams/s1-agent-identity-model.svg)

## Decision 1 — How does each in-scope agent get a governable identity?

The governing test is: can you name a **human sponsor**, prove the **identity
belongs to the workload**, and manage its **lifecycle**? Options differ mostly in
how agent-native and lifecycle-aware they are.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Microsoft Entra Agent ID** (blueprint → blueprint principal → agent identity → agent user) | Agents built in supported first-party tools where an agent-native identity with sponsor and lifecycle is available | Availability and coverage vary by tool and tenant; not every agent surfaces here yet | Strongest fit: sponsor and lifecycle are first-class. Record coverage and what it excludes |
| **Managed identity** (system- or user-assigned) | Agent runs as an Azure workload calling Azure/Foundry resources | Not agent-native — identifies the compute, not the agent's purpose or sponsor | Acceptable for resource access; still needs a separate sponsor/lifecycle record |
| **App registration + service principal** | Custom app/service acting as the agent, needing OAuth scopes | Broad, generic; easy to sprawl and lose ownership; secret/credential hygiene required | Governable only if sponsor, scope, and lifecycle are recorded; prefer federated credentials over secrets |
| **Workload identity federation** | CI/CD or external-workload agents that should avoid stored secrets | Requires a supported issuer/trust setup | Reduces secret risk; record the trust relationship and its owner |
| **On-behalf-of (delegated) identity** | Agent acts *as a signed-in user*, not on its own authority | The agent may have no governable identity of its own — visibility only | Record as user-delegated activity; it is **not** its own inventory entry unless a supported source says so |

Selection criteria to record for each: agent-native vs infrastructure identity;
sponsor and lifecycle ownership; tenant/licensing availability; whether it uses
stored secrets or federated credentials; and how it interacts with runtime access (Decision
2) and the gateway.

### Azure implementation track — identity is not one credential

**Control chain to decide.** Separate the host workload identity (managed
identity or federation), an agent-native identity where supported, delegated OBO
authority, gateway authentication, and target-resource RBAC. A human sponsor
owns the agent's purpose and lifecycle; the technical owner owns the selected
credential/federation path; the resource owner owns least-privilege access.

**Failure modes to test in the customer design.** A shared workload identity can
make actions indistinguishable; a host identity can be mistaken for an
agent-purpose identity; persistent application secrets can outlive the workload;
an OBO flow can be treated as autonomous authority; and broad target-resource
roles can escape the intended tool/action boundary.

**Evidence and record.** The customer-held inventory should state the source
coverage, sponsor, identity classification, autonomous or delegated mode,
credential/federation owner, authority scope, target-resource reference, access
review date, and audit route. Object IDs, tokens, role assignments, and exports
remain in customer systems.

**Backlog sequence.** Close sponsorship and lifecycle gaps, choose the identity
path, then route federation/RBAC/Conditional Access work. Hand gateway evidence
to S6 and catalog/lifecycle reconciliation to S9. An identity decision does not
prove enforcement by a gateway, target resource, or tool.

## Decision 2 — How is runtime access to the agent controlled?

Identity in the tenant and access enforcement at runtime are **different
controls**. You often need both; neither proves the other.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Conditional Access for workload identities** | Tenant/licensing supports it and the workload type is in scope | Depends on licensing, supported workloads, scope, and exclusions; a change the customer owns | Enforces access conditions on the identity plane; record owner, report-only trial, and exclusions |
| **Gateway authentication (Entra/JWT at API Management)** | Traffic routes through a Citadel-style governance-hub gateway | Guards the gateway boundary, not the tenant identity plane | Runtime access control at the platform edge; pairs with S6 runtime assurance |
| **Both (defense in depth)** | High-authority agents where identity-plane and gateway controls should reinforce each other | More moving parts and owners to coordinate | Strongest setup; record both owners and how they correlate |
| **Neither yet (gap)** | Early inventory where controls are not yet decided | Leaves runtime access ungoverned | Record explicitly as a coverage gap with an owner, not as "handled" |

## Decisions made & adoption progress

S1 should move the customer one concrete step along identity adoption. Tie the
decision back to the **S0 maturity baseline** (the identity and authority part) and
forward to the **S12 portfolio** view:

| Adoption stage | What "done" looks like at S1 |
|---|---|
| **Decided** | An identity path (Decision 1) and a runtime-access approach (Decision 2) are chosen per in-scope agent, with a named sponsor |
| **Backlogged** | Gaps, federation moves, or Conditional Access work are routed to the customer identity-change process with owners |
| **In adoption** | The chosen path is being implemented outside this session; S6/S9 will reconcile the evidence |

Record the choice, the alternatives considered, and the rationale in the
technical decision record (`labs/s1-identity/templates/technical-decision-record.template.md`).
S1 leaves a decision record as well as the inventory.

## Related references

- [S1 Concepts](concepts.md) — why sponsorship, OBO, and the gateway boundary fit together.
- [Governance capability guide](../reference/governance-capability-guide.md) — Agent ID and Conditional Access availability context.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) — Entra, RBAC, and Conditional Access sources.
