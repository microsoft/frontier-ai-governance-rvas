# S2 · Foundry Purview Compliance Runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · This session is a Foundry-first, Microsoft Purview portal runbook. Confirm tenant licensing, roles, and current product coverage before delivery.

<span class="rvas-badge rvas-persona">Compliance / Data admin</span> <span class="rvas-badge rvas-persona">Foundry owner</span> <span class="rvas-badge rvas-persona">Governance lead</span>

!!! abstract "What this workshop does"
    S2 enables and verifies Microsoft Purview observation for a **non-production Microsoft Foundry path**, runs one synthetic non-customer interaction, inspects DSPM Activity explorer and Audit, checks retention and eDiscovery routes, classifies DLP and enforcement limits, and routes unsupported coverage gaps.

## 1. Use a non-production Foundry subscription

Use a dedicated **non-production Azure subscription** for the pilot. Enabling the
Purview integration for Foundry sends interaction data from all Foundry
applications in that subscription to the tenant's Microsoft Purview environment.
Do not enable the workshop path against a mixed production subscription unless
the customer has explicitly approved that tenant and subscription impact.

Preflight confirms:

- Microsoft Purview exists in the tenant and the required Purview licenses or
  pay-as-you-go billing path are approved.
- The subscription selected in Foundry is the intended test subscription.
- The facilitator has Foundry Account Owner / Azure AI Account Owner for
  enablement, and the customer has the needed Purview, audit, DLP, retention,
  and eDiscovery role owners.
- The pilot model, API, auth flow, app, and agent path are known. Do not assume
  agent coverage; verify the exact pilot path.
- The validation interaction uses only synthetic, non-customer content. Do not
  copy prompts, responses, tenant identifiers, policy exports, screenshots, or
  secrets into this repository.

## 2. Enable Foundry data security and governance

Preferred portal route:

1. Open `ai.azure.com`.
2. Go to **Operate** -> **Compliance** -> **Data security and governance**.
3. Select the test subscription.
4. Enable **Powered by Microsoft Purview**.
5. Record the subscription alias/reference, role owner, enablement timestamp,
   and any tenant prerequisite gaps in the customer record system.

Alternative Azure route when the customer starts from Defender for Cloud:

1. Open the Azure portal.
2. Go to **Microsoft Defender for Cloud** -> **Environment settings**.
3. Select the subscription.
4. Open **AI services** -> **Settings**.
5. Enable data security for AI interactions.

This alternative is a paid Purview data-security capability. It is not included
in Defender for AI Services.

## 3. Configure and verify Purview collection

In Microsoft Purview, verify the tenant can collect and inspect Foundry activity:

- Activate Microsoft Purview Audit.
- Verify Data Security Posture Management collection. Current portal language is
  **Data Security Posture Management**; some Foundry guidance may still say
  **Solutions** -> **DSPM for AI (classic)** -> **Recommendations**.
- Enable or verify the recommendation **Secure data in Azure AI apps and
  agents**.
- Enable or verify the policy **Secure interactions from enterprise apps** /
  **DSPM for AI - Capture interactions for enterprise AI apps**.
- For custom or Entra-registered apps, use the custom app integration path and a
  Know Your Data collection policy only when the customer deliberately accepts
  prompt and response storage.

## 4. Run the safe synthetic validation

Submit one synthetic non-customer test interaction through the non-production
Foundry app. The lab records the test user, time window, app/resource reference,
model/API path, auth context, and expected classifier trigger only as safe
references.

Then inspect:

- **Purview** -> **DSPM** -> **Activity explorer**. Filter **AI app category** =
  **Enterprise AI apps** and **App** = **Azure AI**. Expect an AI interaction
  event with test user, timestamp, app/access context, and sensitive information
  type or file-reference metadata if the synthetic test matched.
- **Purview** -> **Audit**. Search the test user and time window. Foundry and
  custom-app records use `ConnectedAIAppInteraction` / `ConnectedAIApp` identity
  such as `ConnectedAIApp.AzureAI.<resource>`.
- **Reports** -> **Enterprise AI apps** after DSPM processing catches up. Reports
  can take about 24 hours and should show total interactions and sensitive
  interactions when the classifier matched.

Prompt and response text is not needed for workshop validation. Viewing content
requires Content Explorer Content Viewer or Purview Data Security AI Content
Viewer; do not request or store content unless the customer explicitly approves
that role and evidence handling.

## 5. Check retention, eDiscovery, and DLP boundaries

Retention:

- Go to **Purview** -> **Data Lifecycle Management** -> **Policies** ->
  **Retention policies**.
- Confirm or create a policy that includes **Enterprise AI apps** and the
  approved period.
- For non-Copilot generative apps, prompts and responses require content capture
  or collection before retention can apply to that content.

eDiscovery:

- Go to **Purview** -> **eDiscovery** -> **Cases** -> **Create case**.
- Create or plan a search against the relevant mailbox route.
- For Foundry, use item class
  `IPM.SkypeTeams.Message.ConnectedAIApp.AzureAI.<AzureResourceName>`. Copilot
  activity can search all AI activity.
- Do not use deletion as validation.

DLP simulation:

- Go to **Purview** -> **Data Loss Prevention** -> **Policies**.
- Create or edit the policy, choose **Simulate** or turn on policy, and run in
  simulation mode.
- Expected status is **In simulation**; **View simulation** should show matching
  items or alerts where supported. Activity Explorer policy mode can show
  `TestWithNotifyUser` or `TestWithoutNotifyUser`.
- Documented DLP simulation workload locations do not list Enterprise AI apps /
  Foundry as end-to-end prompt blocking evidence. Treat this as policy tuning
  and observation, not evidence that Foundry prompts are blocked at runtime.

## 6. Decide what is supported

S2 does not approve production, change compliance policy outside the customer
change process, or claim blanket agent coverage. It records one of these states:

| State | Meaning |
|---|---|
| Accepted | Foundry enablement, DSPM Activity explorer, Audit, retention/eDiscovery route, and DLP boundary are verified for the named non-production path. |
| Conditional | Evidence is present, but reports, retention, eDiscovery, or policy tuning needs a named follow-up. |
| Unsupported | The model, API, auth flow, agent path, workload, role, license, or network constraint is outside the documented Purview coverage. |
| Blocked | Subscription impact, Purview tenant setup, licensing/billing, roles, safe evidence handling, or customer approval is missing. |

Hard limits to record:

- Foundry data-security policies apply only to managed-inference
  `/chat/completions` calls that use an Entra user-context token or explicit user
  context.
- Other auth flows may appear in Audit or DSPM Activity Explorer but are not
  policy-enforced.
- Network isolation is not supported by this Purview integration.
- Foundry control-plane guidance says subscription app/agent interaction data
  flows to Purview, while Defender onboarding guidance says Foundry-agent data
  and context are not currently supported. Verify the exact pilot model, API, and
  agent path before making any coverage claim.

## 7. Lab output

`labs/s2-data-compliance/` contains the portal runbook lab kit and decision
record template. Store the completed review in the customer's approved records
system. This repository keeps only blank templates and safe field shapes.

## Related references

- [Use Microsoft Purview to manage data security and compliance for Microsoft Foundry](https://learn.microsoft.com/en-us/purview/ai-azure-foundry)
- [Manage compliance and security in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/control-plane/how-to-manage-compliance-security)
- [Configure DSPM for AI for custom AI apps](https://learn.microsoft.com/en-us/purview/developer/configurepurview)
- [Learn about DLP simulation mode](https://learn.microsoft.com/en-us/purview/dlp-simulation-mode-learn)
- [Retention for Copilot and AI apps](https://learn.microsoft.com/en-us/purview/retention-policies-copilot)
- [Search the audit log](https://learn.microsoft.com/en-us/purview/audit-search)
- [Search for and delete AI application data in eDiscovery](https://learn.microsoft.com/en-us/purview/edisc-search-copilot-data)
