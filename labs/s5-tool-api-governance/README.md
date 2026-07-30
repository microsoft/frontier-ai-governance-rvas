# S5 · API and Tool Admission Workflow lab kit

Use this lab to inspect and test one bounded operation for one bounded consumer.
Complete the template in the customer's approved records system. This repository
keeps only blank templates and safe field shapes.

## Inputs

- Consumer agent/app/workflow alias, owner, environment, and lifecycle state.
- API/tool/connector/MCP route alias, version, owner, and operation ID/tool name.
- API Center or customer catalog entry where used.
- APIM/gateway API ID, operation ID, product/subscription, backend alias, and
  policy owner where used.
- Connector permission model, MCP publication state, or direct tool exception
  owner where relevant.
- Operation allow-list and denied-operation list.
- Auth mode: Entra app, managed identity, delegated/OBO, app role, RBAC, APIM
  subscription, connector consent, MCP auth, or approved equivalent.
- Schema/OpenAPI/tool contract version.
- Rate/quota/cost owner and logging workspace/query owner.
- Withdrawal owner and verification route.
- Synthetic non-customer payloads for one allowed operation and one denied
  out-of-scope operation, or approved existing non-production traces.

## Steps

1. Confirm no customer data, raw payload, token, endpoint, resource ID, log
   export, screenshot, secret, or tenant identifier will be stored in this repo.
2. Open API Center or the customer catalog. Verify API/tool, version,
   definition, environment, deployment, lifecycle, owner, and route link.
3. Open APIM/gateway. Verify API import, operation, product/subscription,
   backend, policy family, diagnostics, and direct-route bypasses.
4. Open connector/MCP/tool contract if used. Verify permission model, schema,
   auth scopes, publication state, consumer list, logging, rate/quota, and
   withdrawal path.
5. Fill operation allow-list: allowed operation, denied operations, parameters,
   data class, side effects, approval requirement, and over-scope behavior.
6. Verify auth mode, audience/scope/role, backend auth, and consent/RBAC owner.
7. Verify schema validation route and expected failure for mismatched payload.
8. Verify rate/quota/cost policy and logging/correlation fields.
9. Run the allowed synthetic operation or inspect approved trace. Check success,
   auth, schema, policy hit, backend match, quota/log event, and side effect.
10. Run the denied out-of-scope operation or inspect approved denial trace. Check
    fail-closed response, no backend side effect, and telemetry event.
11. Verify withdrawal route: disable, revoke, remove, unpublish, rotate, notify,
    preserve logs, and verify closed.
12. Mark result: admitted for change process, defer, reject, withdraw, block, or
    unsupported.

## Required technical fields

- Consumer and operation ID/tool name
- API Center/catalog entry and lifecycle state
- APIM/gateway route and backend ID
- Connector/MCP/tool contract route
- Operation allow-list and denied-operation list
- Auth mode, audience/scope/role/consent/RBAC result
- Schema validation result
- Rate/quota/cost policy result
- Logging workspace, correlation ID, and query reference
- Allowed synthetic test result
- Denied out-of-scope test result
- Withdrawal owner and verify-closed condition
- Result state, owner, fix route, and recheck condition

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short wrapper when
  the delivery workspace needs one.

## Output

A customer-owned admission result showing which route was opened, which allowed
operation succeeded, which denied operation failed closed, which telemetry
proved the result, and who can withdraw the route. The lab does not publish APIs,
configure APIM, grant permissions, approve connectors, register MCP servers, use
customer data, or approve release.
