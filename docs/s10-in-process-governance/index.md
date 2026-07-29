# S10 · In-Process Tool-Call Controls

!!! info "Freshness"
    Last reviewed: 2026-07-15 · AGT claims in this session are pinned to [commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676). AGT is Public Preview; verify current status before customer delivery.

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer decides whether an in-process tool-call
policy check is applicable for one agent boundary. The in-process path is
optional: use it only when there is a real decision to make immediately before a
local tool call and gateway controls cannot make that decision.

**Plain decision question:** For this bounded tool call, use
**gateway-only, in-process, both, or not applicable**—then record
**approve, defer, reject, or route**. The Microsoft/Azure default is the
existing gateway boundary. An in-process exception needs a real pre-tool
decision with delegated authority that gateway controls cannot make; verify AGT
Preview status and fit before any assessment.

!!! success "Hard skip path"
    If no real in-process tool-call boundary exists, stop S10. Record **not
    applicable**, name the gateway or backlog path that remains in scope, and
    continue with operating review, portfolio governance, or the customer
    backlog. Do not create an AGT adoption action just to complete this session.

They leave with:

- either a **not applicable** record or a reviewed example tool-policy
  definition;
- if applicable, one offline allowed, denied, and approval-required decision
  record;
- if applicable, a hash-chain consistency result; and
- a named owner and backlog decision: keep gateway-only, investigate an
  in-process implementation such as AGT, use both, defer, reject, or mark it
  not applicable.

`labs/s10-in-process-governance/` holds a dependency-free policy simulator, a
sample policy, and a runbook. It does **not** hold customer code, production
policies, tenant data, credentials, or real tool arguments.

The local simulator record is not tamper evidence. Tamper evidence needs a
customer-managed signed record in immutable external storage.

### What happens next

**Next customer action:** send the applicability decision and any engineering
assessment to the policy owner and the customer's normal SDLC or change process.

S10 creates a backlog item only when the customer has a real in-process
decision to evaluate. The recommendation states whether to keep gateway-only,
investigate an in-process implementation such as AGT, use both, defer, reject,
or mark not applicable. It also names the policy owner, engineering assessment,
audit retention route, tool-call boundary, publication, runtime-assurance, and
catalog/lifecycle dependencies, plus the customer SDLC or change process that
owns next steps.

!!! warning "Illustrative only: no AGT deployment"
    The kit does not install or execute AGT, modify customer agent code, call a
    tenant or endpoint, or prove production suitability. It is not an AGT
    compatibility test or an official AGT–Citadel integration.

## 2. Prerequisites

- Prior governance findings and the control-plane backlog are ready to review.
- An AI developer or maker can explain the customer's agent tool-call path.
- A governance lead can make or defer the applicability decision.
- Python 3.11+ is available for the offline simulator.
- The team has reviewed the pinned AGT Public Preview notice and [known limitations](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md).

You do **not** need an Azure subscription, AGT installation, customer source
code, credentials, production endpoint, or tenant change.

### Applicability worksheet

Use the in-process path only when the customer can point to a real decision just
before an agent invokes a tool. Capture:

- the candidate tool action and delegated authority;
- the gateway, identity, data, evaluation, and runtime controls that still apply;
- the policy owner, approval route, audit-record owner, and retention need;
- the evidence a future engineering assessment needs before installation or code
  change; and
- the reason S10 is **not applicable** if no in-process boundary exists.

If the worksheet cannot identify both a local pre-tool decision and delegated
authority, select **not applicable**. Do not continue into policy simulation or
AGT assessment; route the finding to operating review, portfolio governance, or
the customer backlog.

## 3. Why this session matters

Gateway controls govern traffic at the platform boundary. An in-process policy
check can make a separate decision inside the agent before a tool call runs.

You may need both. Each control is accepted only with its own configuration and operating evidence.

Read the [S10 Concepts](concepts.md) for the offline Preview boundary,
hash-chain consistency, and what real tamper evidence requires.

## 4. Change boundary

S10 makes no tenant, endpoint, code, or policy change. Any AGT assessment or
customer policy implementation uses a separate engineering and change-review
path.
