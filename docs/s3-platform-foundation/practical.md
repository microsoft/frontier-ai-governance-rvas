# Practical activity: trace one non-production path

## What you will do

Customer platform owners trace one non-production request path through its
identity, gateway, model, tool, and telemetry boundaries.

## Before you start

- Confirm a bounded workload, platform and security owners, safe scope, and
  approved records location.
- Use architecture references or a non-production environment only. Do not
  connect to production or change configuration.
- Stop if the team cannot name the request path or its decision owner.

## Customer-operated activity

1. Use `labs/s3-platform-foundation/templates/platform-boundary-review.template.md`
   to map the request path and trust boundaries.
2. Identify who owns each boundary and what customer-held evidence would show
   that it is present.
3. Record one gap or dependency in the runtime-assurance handoff, including its
   owner and stop condition.

## What good looks like

The customer can follow one request across the intended boundaries and knows
what must be true before S6 can rely on that path.

## If the environment is not ready

Complete the same review from customer-held architecture references and state
which environment or telemetry detail remains unverified.

## Keep and hand over

Keep the boundary review and handoff in approved records. Send platform,
network, identity, gateway, and telemetry prerequisites to their customer
owners before runtime assurance proceeds.
