# S5 · API, Tool & MCP Governance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm the customer's applicable policies,
    technical constraints, and approval authorities before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Platform owner</span> <span class="rvas-badge rvas-persona">Security reviewer</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & what the customer keeps

For each in-scope tool, API, or MCP service, the customer can answer: **can we
publish it, hold it, suspend it, or withdraw it safely?**

They leave with:

- A catalog record with an accountable owner, workspace decision, naming
  decision, classification, caller identity, authority scope, and version.
- A publication decision with criteria, evidence references, remaining gaps, and
  a named approver.
- Lifecycle decisions for proposed, published, suspended, and withdrawn entries.

The customer keeps the completed record in its approved records system.
`labs/s5-tool-api-governance/` contains offline templates and a report-only
runbook. Customer evidence stays in the customer system and is referenced, not
copied into this repository.

### What happens next

**Next customer action:** give the publication or lifecycle decision to the
catalog, platform, identity, and release owners who can complete the required
work.

S5 produces a publication backlog and records whether the candidate is
publish-ready, on hold, rejected, suspended, or withdrawn.

It also names the execution path: API Center or catalog entry, [Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)
or AI Gateway route, caller identity, MCP or connector path, version boundary,
lifecycle owner, and customer change or release process.

## 2. Prerequisites

- A bounded candidate list and a customer-owned source record for each candidate.
- An accountable catalog owner, technical owner, evidence owner, and decision owner.
- The classification method, workspace rules, naming rules, identity requirements,
  and publication authority that apply.
- An approved customer records location and a safe review scope.

## 3. Why this session matters

A tool or API is governable when a reviewer can name its owner, placement,
caller, authority, and version. A catalog helps find those facts; it does not
prove safety, configuration, authorization, or live behavior.

S5 creates the decision record before publication or lifecycle action. It does
not publish a service, grant permission, create a caller identity, configure an
integration, or test a live connection. Read [S5 Concepts](concepts.md) for the
reasoning behind the record and its boundaries.

## 4. Co-delivery walkthrough

!!! warning "Evidence-first / report-only"
    This session reviews references and produces no live change. Do not publish
    catalog entries, grant permissions, create identities, connect to a live
    service, or use a catalog record as proof of safe use.

Read [Technical decisions](technical.md) first. It covers publication and
registry, MCP governance, and tool-authentication options and criteria.

**Timebox:** 90 minutes. **Entry condition:** the bounded candidate list,
customer evidence location, required owners, and decision authority are available.
Stop the affected candidate if its owner, source, classification, caller
identity, authority scope, or decision authority is unknown.

**What the customer actually does:** the customer reviews one bounded set of
APIs, tools, or MCP services and decides the publication or withdrawal state for
each entry.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set boundary and decision question | 10 min | Name the candidate set, intended decision, records location, and authorities. | **"What is in scope, what is out of scope, and what would make us stop?"** Record references and expected signals only. |
| Establish catalog ownership and identity | 15 min | Use the offline catalog template to name the accountable owner, technical owner, candidate identifier, version, intended consumers, and source reference. | **"Who owns the lifecycle decision, and is this the exact version under review?"** Unknown ownership or version is a finding. Do not infer it. |
| Decide naming and workspace placement | 15 min | Record the proposed name, namespace or workspace, alternatives considered, collision or confusion risk, and accountable decision owner. | **"Can a reviewer distinguish this entry from a similarly named service?"** **"Does the workspace match the classification and audience?"** Do not create or move any workspace item. |
| Classify and bound authority | 20 min | Record classification, data-handling limits, caller identity reference, authentication expectation, delegated or non-delegated authority, allowed actions, prohibited actions, and boundary conditions. | **"What is the minimum authority this caller needs for this exact version and use?"** **"Can we prove the caller identity separately from the authority scope?"** A broad or unknown scope is a finding, not an approval. |
| Apply publication and lifecycle criteria | 20 min | Compare the record with the publication criteria, record evidence references and gaps, then choose proposed, publish-ready, hold, suspended, or withdrawn. | **"Which criterion has evidence?"** **"What event triggers suspension or withdrawal?"** Publish-ready is a decision state, not an instruction to publish. |
| Decide and hand over | 10 min | The decision owner accepts, defers, rejects, suspends, or withdraws the stated disposition and assigns every gap. | **"Who owns each next action, and when is the next review?"** Read back only safe references, decision, owner, date, and remaining risk. |

### Publication criteria

The decision owner may mark a candidate **publish-ready** only when all of these
items have customer-held evidence references:

1. A unique, understandable name and approved workspace or namespace decision.
2. Accountable catalog and technical owners, intended consumers, and a current
   version identifier.
3. A classification and handling constraints that fit the intended use.
4. An identified caller identity and a stated authentication expectation.
5. A clear authority scope, including allowed and prohibited actions,
   boundaries, and escalation conditions.
6. A lifecycle owner, review date, suspension trigger, and withdrawal path.
7. A decision owner who accepts the remaining gaps and disposition.

These criteria create a reviewable governance decision. They do not prove runtime
safety, security effectiveness, legal compliance, availability, or live
authorization.

### Results, evidence, and handoff

Reference the candidate source, ownership record, classification record, identity
and authority references, workspace and naming decision, version record,
lifecycle decision, and approval or deferral. Do not copy the evidence. The
customer keeps the completed offline templates in its approved records system.

The handoff states the candidate identifier and version, reviewed scope, observed
facts or no result, evidence references, disposition, remaining gaps, owner, due
date, next review, required customer change, and any technical decision record
captured in `templates/technical-decision-record.template.md`. A template,
facilitator note, or catalog entry is not proof that the candidate can be used
safely.

### Blocker pathways

| Blocker | Safe response and handoff |
|---|---|
| No accountable owner, decision authority, or records location | Stop the candidate review. Record the missing dependency, owner, target date, and reschedule. |
| Name, workspace, classification, version, caller identity, or authority scope is unknown | Record an evidence or design gap; keep a proposed or hold disposition. Do not infer, publish, or grant access. |
| The candidate needs a permission, identity, integration, workspace, or catalog change | Assign a customer-owned change through the applicable approval, rollback, and verification process. Do not make the change in S5. |
| A suspension or withdrawal is needed | Record the trigger, scope, customer owner, communication reference, and verification reference. The customer performs the action through its approved process. |
| No expected evidence exists or a criterion cannot be assessed | Record what was checked and what was missing. Defer, refine the question, use another customer control, or withdraw the candidate. Do not treat absence as a pass. |

## 5. Verification & evidence capture

- [ ] Each candidate has a customer-held catalog record with owners, version,
  naming/workspace decision, classification, caller identity, and authority scope.
- [ ] Publication criteria have evidence references or explicitly owned gaps.
- [ ] The lifecycle record identifies its state, review date, suspension triggers,
  withdrawal path, and decision owner.
- [ ] The customer records system contains the disposition, remaining-risk
  decision, next action, and next review.

## 6. Change boundary and handoff

S5 changes no catalog, workspace, service, identity, permission, integration, or
lifecycle state. Any publication, permission grant, suspension, or withdrawal is
customer-owned and follows the customer's approved change, rollback,
communication, and verification process.
