# Controlled regional failover runbook

## Ownership and review

- Maintained by: Service continuity owner (`__REQUIRED_SERVICE_OWNER__`)
- Reviewed: Before every scheduled rehearsal and after a routing, topology, or restore-process change
- Used by: The service continuity and routing operators

## Purpose

Move the governed agent from the primary selector to the secondary selector listed in the regional
parameter contract during an approved maintenance window. The same identity, API Management policy
version, agent version, and trace path must survive the move.

## Authority and scope

- Approved Azure scope: `/subscriptions/__REQUIRED_SUBSCRIPTION_ID__/resourceGroups/__REQUIRED_RESOURCE_GROUP__`
- Service owner: `__REQUIRED_SERVICE_OWNER__`
- Platform owner: `__REQUIRED_PLATFORM_OWNER__`
- Security owner: `__REQUIRED_SECURITY_OWNER__`
- Delivery owner: `__REQUIRED_DELIVERY_OWNER__`

Stop if the scope, current release, maintenance window, or restore authority differs from the
approved change. Both selectors must be present. They must name different routes.

## Before routing changes

1. Freeze infrastructure and gateway policy changes for the rehearsal window.
2. Run `scripts/preflight.ps1 -Phase Ready` or `scripts/preflight.sh --phase ready` and inspect the
   live Azure checks plus what-if result. The failover wrapper repeats this ready check immediately
   before health and routing.
3. The service owner confirms both regional endpoints pass the customer health interface. The
   visible result must include `status`, `region`, `agentVersion`, `agentIdentityId`,
   `gatewayPolicyVersion`, `endpointStatus`, `identityStatus`, `policyStatus`, `traceStatus`, and
   `sensitiveInputPresent`.
4. Check that the primary selector still serves the agent version in
   `regional/region.parameters.json`.
5. Open the customer's normal change record. Keep runtime output there.

## Fail over

Run `scripts/rehearse-failover.ps1` with the exact approved scope. After the service owner confirms
secondary readiness, the delivery owner confirms the high-impact production traffic move from the
primary selector to the secondary selector listed in the topology. The script then invokes the customer
routing control.

Observe the normal service telemetry in Azure Monitor and the relevant service portals. Stop and
restore the primary selector if the secondary path does not report the expected identity, gateway
policy, agent version, and trace.

## Restore the primary selector

Use the same approved scope and customer routing control. The service owner confirms primary
readiness. Preview the selector restore, get delivery-owner confirmation for the second
high-impact production traffic move, and move only the selector listed in this runbook. Then check
the primary path.

Do not remove the secondary region after the rehearsal. Region removal is a separate capacity and
continuity decision.

## Known limit

For one Premium (classic) multi-region API Management instance, the secondary gateway can keep
serving its latest configuration when the primary region is unavailable. The management plane and
developer portal remain in the primary region. Internal mode needs the customer's own cross-region
routing, and rate or token counters are not globally aggregated.
