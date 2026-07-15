# S5 · API, Tool & MCP Governance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm the customer's applicable policies,
    technical constraints, and approval authorities before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Platform owner</span> <span class="rvas-badge rvas-persona">Security reviewer</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & durable artifact

The customer leaves with a decision-ready, offline governance record for one
bounded set of APIs, tools, or model-context-protocol (MCP) services:

- a catalog record with an accountable owner, workspace decision, naming
  decision, classification, caller identity, authority scope, and version;
- a publication decision with explicit criteria, evidence references, residual
  gaps, and a named approver; and
- lifecycle dispositions for proposed, published, suspended, and withdrawn
  entries.

Durable artifact: `labs/s5-tool-api-governance/` contains offline templates and
a report-only runbook. Customer evidence remains in the approved customer
records system and is referenced, never copied into this repository.

## 2. Prerequisites

- A bounded candidate list and a customer-owned source record for each
  candidate.
- An accountable catalog owner, technical owner, evidence owner, and decision
  owner.
- The applicable classification method, workspace rules, naming conventions,
  identity requirements, and publication authority.
- An approved customer records location and a safe review scope.

## 3. Why this session

An API, tool, or MCP service is governable only when a reviewer can identify
what it is, who owns it, where it belongs, who may call it, what authority it
can exercise, and which version is being considered. A discoverable catalog
entry helps make those facts reviewable; it does not prove that the service is
safe to use, correctly configured, authorized for every caller, or operating
as intended.

S5 establishes the decision record before publication or lifecycle action.
It does not publish a service, grant a permission, create a caller identity,
configure an integration, or test a live connection. Read [S5 Concepts](concepts.md)
for the reasoning behind the record and its boundaries.

## 4. Co-delivery walkthrough

!!! warning "Evidence-first / report-only"
    This session reviews references and produces no live change. Do not publish
    catalog entries, grant permissions, create identities, connect to a live
    service, or use a catalog record as proof of safe use.

**Timebox:** 90 minutes. **Entry condition:** the bounded candidate list,
customer evidence location, required owners, and decision authority are
available. Stop the affected candidate if its owner, source, classification,
caller identity, authority scope, or decision authority is unknown.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set boundary and decision question | 10 min | Name the candidate set, intended decision, records location, and authorities. | “What is in scope, what is explicitly out of scope, and what would make us stop?” Record references and expected signals only. |
| Establish catalog ownership and identity | 15 min | Use the offline catalog template to name the accountable owner, technical owner, candidate identifier, version, intended consumers, and source reference. | “Who accepts lifecycle decisions?” “Is this the exact version under review?” Unknown ownership or version is a finding, not a field to infer. |
| Decide naming and workspace placement | 15 min | Record the proposed name, namespace or workspace, alternatives considered, collision or confusion risk, and accountable decision owner. | “Can a reviewer distinguish this entry from a similarly named service?” “Does the workspace match its classification and intended audience?” Do not create or move any workspace item. |
| Classify and bound authority | 20 min | Record classification, data-handling constraints, caller identity reference, authentication expectation, delegated or non-delegated authority, allowed actions, prohibited actions, and boundary conditions. | “Which authority is actually needed?” “Can the caller identity and authority scope be evidenced separately?” A broad or unknown scope is a finding, not an approval. |
| Apply publication and lifecycle criteria | 20 min | Compare the record with the publication criteria, record evidence references and gaps, then choose proposed, publish-ready, hold, suspended, or withdrawn as appropriate. | “Which criterion is supported by evidence?” “What event triggers suspension or withdrawal?” Publish-ready is a decision state, not an instruction to publish. |
| Decide and hand over | 10 min | The decision owner accepts, defers, rejects, suspends, or withdraws the stated disposition and assigns every gap. | “Who owns each next action and next review?” Read back only safe references, decision, owner, date, and residual risk. |

### Publication criteria

The decision owner may mark a candidate **publish-ready** only when all of the
following are recorded with customer-held evidence references:

1. A unique, understandable name and approved workspace or namespace decision.
2. Accountable catalog and technical owners, intended consumers, and a current
   version identifier.
3. A classification and handling constraints appropriate to the intended use.
4. An identified caller identity and a stated authentication expectation.
5. An explicit authority scope, including allowed and prohibited actions,
   boundaries, and escalation conditions.
6. A lifecycle owner, review date, suspension trigger, and withdrawal path.
7. A decision owner who accepts the residual gaps and disposition.

These criteria create a reviewable governance decision. They do not establish
runtime safety, security effectiveness, legal compliance, availability, or
authorization in a live environment.

### Results, evidence, and handoff

Reference—not copy—the candidate source, ownership record, classification
record, identity and authority references, workspace and naming decision,
version record, lifecycle decision, and approval or deferral. The customer
retains the completed offline templates in its approved records system.

The handoff states the candidate identifier and version, reviewed scope,
observed facts or no-result, evidence references, disposition, residual gaps,
owner, due date, next review, and any required customer change. A template,
facilitator note, or catalog entry is not proof that the candidate can be used
safely.

### Blocker pathways

| Blocker | Safe response and handoff |
|---|---|
| No accountable owner, decision authority, or records location | Stop the candidate review. Record the missing dependency, owner, target date, and reschedule. |
| Name, workspace, classification, version, caller identity, or authority scope is unknown | Record an evidence or design gap; retain a proposed or hold disposition. Do not infer, publish, or grant access. |
| The candidate needs a permission, identity, integration, workspace, or catalog change | Assign a customer-owned change through the applicable approval, rollback, and verification process. Do not make the change in S5. |
| A suspension or withdrawal is needed | Record the trigger, scope, customer owner, communication reference, and verification reference. The customer performs the action through its approved process. |
| No expected evidence exists or a criterion cannot be assessed | Record the no-result and checked scope. Defer, refine the question, use another customer control, or withdraw the candidate; never call absence a pass. |

## 5. Verification & evidence capture

- [ ] Each candidate has a customer-held catalog record with owners, version,
  naming/workspace decision, classification, caller identity, and authority
  scope.
- [ ] Publication criteria have evidence references or explicitly owned gaps.
- [ ] The lifecycle record identifies its state, review date, suspension
  triggers, withdrawal path, and decision owner.
- [ ] The customer records system contains the disposition, residual-risk
  decision, next action, and next review.

## 6. Change boundary and handoff

S5 changes no catalog, workspace, service, identity, permission, integration,
or lifecycle state. Any publication, permission grant, suspension, or
withdrawal is customer-owned and follows the customer's approved change,
rollback, communication, and verification process.

## 7. Facilitator notes

- Follow the 90-minute [co-delivery facilitation method](../delivery/facilitation-pattern.md):
  customers operate their records and make decisions; the facilitator preserves
  the boundary, timebox, and interpretation.
- **RACI:** catalog owner and technical owner = R for the record; governance
  lead or delegated decision owner = A for disposition; security and
  classification reviewers = C; evidence owner = R for approved references.
- **Close the loop:** a publish-ready decision is a handoff to the customer's
  separate publication process, not publication itself. Re-review at version,
  authority, ownership, classification, or lifecycle change.
