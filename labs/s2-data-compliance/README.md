# S2 · Foundry Purview Compliance lab kit

Use this lab to produce one customer-owned portal evidence record for a
non-production Microsoft Foundry path. This repository keeps only blank templates
and safe field shapes.

## Inputs

- Dedicated non-production Azure subscription.
- Tenant with Microsoft Purview available.
- Foundry app/resource alias, model, API path, auth flow, and agent path if any.
- Named owners for Foundry enablement, Purview/DSPM, Audit, DLP, retention,
  eDiscovery, and evidence storage.
- Approved synthetic non-customer test content and time window.
- Confirmed Purview licensing and billing/PAYG path.

## Steps

1. Complete preflight: subscription, tenant Purview, roles, licensing/billing,
   pilot path, and evidence handling.
2. Enable **Powered by Microsoft Purview** from `ai.azure.com` -> **Operate** ->
   **Compliance** -> **Data security and governance** for the test subscription.
   If using Azure portal, record the Defender for Cloud -> Environment settings
   -> subscription -> AI services -> Settings route.
3. In Purview, verify Audit, DSPM collection, **Secure data in Azure AI apps and
   agents**, and **Secure interactions from enterprise apps** / **DSPM for AI -
   Capture interactions for enterprise AI apps**.
4. Submit one synthetic non-customer interaction through the non-production
   Foundry app. Record only safe metadata.
5. Inspect **DSPM** -> **Activity explorer** with **AI app category** =
   **Enterprise AI apps** and **App** = **Azure AI**.
6. Search **Audit** for the test user/time and `ConnectedAIAppInteraction` /
   `ConnectedAIApp` activity.
7. Check **Reports** -> **Enterprise AI apps** immediately and assign a 24-hour
   recheck if needed.
8. Record DLP simulation status as policy tuning/observation only; do not claim
   end-to-end Foundry prompt blocking.
9. Verify retention policy scope includes **Enterprise AI apps** and the approved
   period.
10. Verify eDiscovery case/search route and Foundry item class. Do not use
    deletion as validation.
11. Record unsupported coverage, including managed-inference API/auth limits,
    network isolation, custom app storage consent, and agent-path caveats.

## Required technical fields

- Subscription / tenant readiness
- Foundry resource/app alias
- Model, API, auth, and agent path
- Purview licensing/billing state
- Role owners
- Purview enablement state
- Audit and DSPM collection state
- Enterprise app interaction policy state
- Synthetic test metadata
- Activity Explorer event reference or validated no-result
- Audit search reference or validated no-result
- DSPM report state and 24-hour recheck
- Retention policy route
- eDiscovery route and item class
- DLP simulation boundary
- Unsupported coverage and handoff owner

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision wrapper when needed.

## Output

A customer-owned decision record that shows what Purview observed for the exact
non-production Foundry path, names retention/eDiscovery routes, and routes limits
or blockers. The lab does not deploy production policy, export customer data,
store prompts or responses, claim blanket runtime enforcement, or approve release.
