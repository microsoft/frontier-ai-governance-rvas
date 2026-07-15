# Platform-foundation RACI

Use named people, not team aliases. One person may hold several roles, but the
accountable role must be explicit.

| Activity | Platform owner | APIM/API Center owner | Network owner | Security-runtime owner | Backend/Foundry owner | Application owner | Governance lead | Facilitator |
|---|---|---|---|---|---|---|---|---|
| Select platform path and environment scope | A | R | C | C | C | C | C | C |
| Confirm accelerator version and deployment change | A | R | C | C | C | I | I | C |
| Configure gateway, contracts, and approved backends | A | R | C | C | C | C | I | I |
| Configure connectivity, DNS, and private access | A | C | R | I | C | I | I | I |
| Configure gateway authentication and caller access | A | R | C | C | C | C | I | I |
| Own Content Safety/runtime policy and alert routing | A | C | I | R | C | I | C | I |
| Provide telemetry, trace access, and retention | A | R | C | C | C | I | C | I |
| Run the non-production smoke test and approve evidence | A | R | C | C | C | R | C | I |
| Record governance use, residual gaps, and session gate | C | C | I | C | I | I | A/R | R |
| Operate, change, roll back, and support production | A | R | R | R | R | C | I | I |

**R** performs the work, **A** accepts the outcome, **C** is consulted, and
**I** is informed. The customer performs all privileged operations. The
facilitator never becomes the operational owner of the gateway.
