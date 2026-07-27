# Practical workshop: conditional in-process tool-call governance

**Microsoft default:** Gateway controls first. Consider an in-process tool-call
policy only when the customer can identify a real pre-tool decision with
delegated authority that gateway controls cannot make.

**Customer decision:** Gateway-only, in-process, both, or not applicable; then
approve, defer, reject, or route the resulting backlog item.

!!! success "Skip path"
    If there is no real in-process boundary, record **not applicable** and stop
    S10. Continue with S11/S13 or the customer backlog. Do not open an AGT
    adoption task just to complete this workshop.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the gateway control decision and ask whether a local tool call needs
   an allow, deny, approval, or route decision before execution.
3. If the gateway can make the decision, or if there is no delegated-authority
   boundary inside the process, record **not applicable** or gateway-only and
   skip the simulator.
4. If a real in-process boundary exists, record why gateway controls cannot
   decide it and identify the implementation candidates. AGT may be one
   candidate, subject to Public Preview caveats, limitations, code ownership,
   and a separate customer engineering assessment.
5. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Applicability decision | Gateway-only, in-process candidate, both, or not applicable | Runtime governance owner | Customer-approved record | Decision, rationale, acceptance test or skip reason, and handoff are complete | Customer date | S11/S13, customer backlog, or application engineering |

6. Use this decision tree: if gateway-only fits, approve and route evidence to
   the normal control path; if the in-process boundary is real but records are
   missing, defer with an acceptance test; if the path cannot meet the use case,
   reject or route to an exception owner; if the boundary does not exist, mark
   **not applicable**.
7. For any exception or future implementation assessment, record: reason,
   equivalent control, owner, evidence location, acceptance test, target date,
   review trigger, and AGT Public Preview caveat if AGT is considered.

**Boundary:** Keep customer data in customer-approved systems; production
changes require customer change approval. S10 does not deploy AGT, prove
production suitability, or add customer evidence to this repository.
