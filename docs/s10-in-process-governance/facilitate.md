# Facilitate the decision

**Decision question:** For this bounded tool call, should the policy boundary be
**gateway-only, in-process, both, or not applicable**? Record an
**approve, defer, reject, or route** result.

| Phase | Time | Safe output |
|---|---:|---|
| Set scope | 15 min | Tool-call reference, delegated authority, owner, and evidence limit. |
| Compare boundaries | 25 min | Gateway-only / in-process / both / not-applicable rationale. |
| Run the illustration | 20 min | Offline policy and hash-consistency result only. |
| Decide and hand off | 30 min | Decision, target date, acceptance evidence, and S6/S9/S11 routes. |

**Azure/Microsoft default:** keep the existing Azure/API gateway control as the
platform boundary. Add an in-process AGT-style assessment only when a real
pre-tool decision carries delegated authority that the gateway cannot make.
Use both only when the authority and evidence need justify two owned controls.
Otherwise record gateway-only or not applicable. AGT is Preview; verify its
current status and fit before an assessment.

Copy the safe-reference templates to approved records. No result approves
installation, customer-code change, production policy, or production use.
