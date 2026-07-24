# Practical workshop: platform readiness

**Customer owner:** Platform owner. **Timebox:** 45 minutes. Map one bounded
non-production path from records; do not test or configure it.

1. Trace identity, network, gateway, model, tool, and telemetry boundaries.
2. Default: use Microsoft Foundry, a customer-adopted Citadel/AI Hub Gateway
   accelerator where applicable, and Azure API Management for the AI gateway
   boundary. Citadel is an accelerator, not proof of a deployed configuration.
   Use another pattern only when the architecture owner documents why, the
   control equivalence sought, limits, owner, and review date.
3. Ask: **“Do we approve, defer, reject, or route this platform-readiness
   decision?”**
4. Record the result with evidence reference or gap, owner, acceptance
   criterion, and target date.
5. Hand runtime-security evidence requirements to S6, evaluation to S7,
   monitoring operation to S11, and catalog work to S9. No deployment, system
   change, or production approval occurs.
