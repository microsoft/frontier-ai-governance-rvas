# Regional failover rehearsal runbook

## Ownership

- Service continuity owner: `__REQUIRED_SERVICE_OWNER__`
- Delivery owner: `__REQUIRED_DELIVERY_OWNER__`
- Routing owner: `__REQUIRED_ROUTING_OWNER__`
- Review this runbook before every rehearsal and after a routing or restore-process change.

## Scope

Use the exact resource-group scope and selector pair in the approved change record. The regional
contract names the expected values for each path.

Session 12 promotes infrastructure and policy. This runbook moves one selector and restores it.

## Rehearsal

1. Freeze infrastructure and API Management policy changes.
2. Run ready preflight. Confirm the primary path is active.
3. Check secondary readiness. Preview the move to the secondary selector.
4. Get delivery-owner approval. Move the named selector. Check the secondary path.
5. Preview the return move. Get delivery-owner approval. Restore the primary selector.
6. Check the active primary path. Record the outcome in the customer change record.

Stop when a check differs from the regional contract. If traffic has moved, use the approved
customer routing control to restore the primary selector. Do not remove the secondary path.
