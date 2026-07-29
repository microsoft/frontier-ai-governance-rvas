# S0 · Governance Baseline & Operating Model

!!! info "Freshness"
    Last reviewed: 2026-07-29 · Verify current Microsoft service availability, customer authority, and evidence locations before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

S0 chooses the first practical AI-governance action. The customer leaves with a
short **technical baseline card** that names:

- the bounded pilot or capability;
- the sponsor and decision owner;
- the Microsoft service path likely involved;
- the customer evidence location;
- the first technical blocker to close;
- the next session or owner process needed to close it.

`labs/s0-foundations/` contains a blank offline template only. Keep names,
evidence, internal notes, and completed decisions in the customer's approved
records system.

### Plain decision

**Which technical blocker should the customer close first so the pilot can move
through identity, data, platform, build, runtime, evaluation, red-team,
control-plane, operations, LLMOps, or portfolio review without guessing?**

Default to the customer's existing authority and records system. If no owner,
record location, bounded pilot, or safe review target exists, stop and create a
readiness blocker instead of starting downstream work.

## 2. Baseline card fields

| Field | What to record |
|---|---|
| Pilot / capability | One bounded AI-agent or platform question. |
| Sponsor | Person or group that can decide whether governance work continues. |
| Decision owner | Owner of the first technical blocker. |
| Microsoft path | Entra, Purview, Foundry, APIM, Defender/Sentinel, Azure Monitor, API Center, Cost Management, or other concrete surface. |
| Evidence location | Customer-approved place for safe references and completed artifacts. |
| First blocker | Missing owner, unsupported service, unclear identity, data exposure, platform route, tool/API risk, runtime evidence, evaluation gap, or operating signal gap. |
| Next action | Proceed to the relevant session, defer, route, reject, or block. |

## 3. Hard stops

- No named decision owner.
- No approved evidence location.
- Pilot scope is too broad to inspect.
- The review would require exporting customer evidence into this repository.
- The first blocker is a legal/compliance/production decision outside the
  workshop boundary.

## 4. Change boundary

S0 makes no tenant, platform, policy, access, funding, production, or evidence
movement change. It selects the first technical action and records blockers.

Use [Technical decisions](technical.md) for baseline field detail and safe
handoff boundaries.
