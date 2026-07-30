# S3 · Platform Plumbing Verification lab kit

Use this lab to verify one non-production platform route with a safe synthetic
request or read-only trace review. Complete the template in the customer's
approved records system. This repository keeps only blank templates and safe
field shapes.

## Inputs

- One caller-to-model/tool/API route and environment.
- Foundry project/resource alias and model deployment alias where used.
- APIM/gateway API ID, operation ID, backend alias, or direct-route exception.
- Private endpoint/private DNS expectation where relevant.
- API Center/catalog route alias and lifecycle owner.
- Application Insights / Log Analytics workspace alias and query owner.
- Defender/Sentinel handoff owner where used by the customer.
- Cost/quota owner for model capacity, token budget, APIM quota, and cost tags.
- Synthetic non-customer request or approved existing non-production trace.

## Steps

1. Confirm safe scope: no customer prompt, response, endpoint, resource ID,
   telemetry export, screenshot, secret, or tenant identifier is stored in this
   repo.
2. Open `ai.azure.com` -> project -> **Management center**. Inspect project,
   resource, region, deployments, connections/tools, network, identity,
   monitoring/tracing, and owner.
3. Open Azure portal -> Azure AI/Foundry/OpenAI resource. Inspect Networking,
   Identity, Model deployments, Metrics, Diagnostic settings, IAM, and quota.
4. Open APIM/gateway route: API, operation, product/subscription, inbound policy
   family, backend, diagnostics, correlation header, and bypasses.
5. If private routing is required, open private endpoint, private DNS zone/link,
   VNet/subnet, public-network setting, firewall/NSG/route table, and flow-log
   owner.
6. Open API Center or customer catalog. Verify route, version, deployment,
   lifecycle state, owner, and exception/deprecation route.
7. Run one safe synthetic request or inspect one read-only trace. Record only
   route ID, time window, trace/request ID, and expected policy/backend/private
   route.
8. Query Application Insights / Log Analytics for gateway, app, dependency, and
   backend/model/tool events.
9. Check Defender/Sentinel handoff and cost/quota owner.
10. Mark result state: verified, partial, bypass, public path, no telemetry,
    catalog gap, unsupported, or blocked.

## Required technical fields

- Route ID: APIM API/operation/backend or direct-route alias
- Portal links or customer safe references
- Foundry project/resource and model deployment aliases
- Gateway policy expected and backend route expected
- Private endpoint/DNS/public-network result where relevant
- API Center/catalog API/version/lifecycle owner
- Trace ID / request ID / time window
- Telemetry query reference and workspace alias
- Defender/Sentinel handoff result
- Cost/quota owner
- Result state, owner, fix route, and recheck condition

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short wrapper when
  the delivery workspace needs one.

## Output

A customer-owned platform-route verification showing which records were opened,
which trace/query matched, where the route bypassed controls or became
unobservable, and who owns the fix. The lab does not deploy resources, configure
APIM, change networking, enable diagnostics, export logs, register APIs, change
quota, or approve release.
