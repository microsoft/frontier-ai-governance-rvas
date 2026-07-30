# S2 · Foundry Purview Compliance: Technical runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · This runbook uses verified Microsoft Foundry and Microsoft Purview portal behavior. Validate tenant licensing, role assignments, and current workload support before delivery.

## Microsoft default

Default to Microsoft Foundry plus Microsoft Purview Data Security Posture
Management, Audit, retention, eDiscovery, and DLP simulation for observation and
compliance routing. S2 is not a generic data-governance workshop: it verifies what
Purview can observe for one non-production Foundry path and records the limits.

Use a dedicated non-production Azure subscription because enabling Purview in
Foundry sends interaction data from **all Foundry applications in that
subscription** to the tenant's Purview environment.

## 1. Preflight

| Check | Required decision / evidence | Blocker if missing |
|---|---|---|
| Subscription | Dedicated non-production subscription selected for the workshop. | Do not enable Purview against an unapproved or mixed production subscription. |
| Tenant Purview | Microsoft Purview exists in the tenant. | Foundry enablement cannot complete. |
| Licensing and billing | Purview license and any PAYG data-security processing path are confirmed. | Do not promise DSPM, policy management, content viewing, DLP, retention, or eDiscovery behavior. |
| Foundry role | Enablement owner has Foundry Account Owner / Azure AI Account Owner. | Cannot enable from Foundry. |
| Purview roles | Compliance Admin / Compliance Administrator for DSPM create/edit; Security Reader or AI Viewer for read-only; Content Explorer Content Viewer or Purview Data Security AI Content Viewer for content viewing if explicitly approved. | Cannot verify or view required evidence. |
| DLP roles | Information Protection Admin for DLP simulation. DLP creation can also use Compliance Admin, Compliance Data Admin, Information Protection, or Security Admin. | Cannot create, edit, or simulate DLP policy. |
| Pilot path | Foundry app/resource, model, API, auth flow, user-context behavior, and agent path are named. | Do not assume coverage. |
| Evidence handling | Customer-approved record location exists. | Do not run a test that creates evidence without an owner. |
| Test content | Synthetic non-customer prompt, expected classifier/SIT, user, and time window are approved. | Do not use customer data. |

## 2. Enable Foundry Purview integration

Preferred Foundry portal route:

1. Open `ai.azure.com`.
2. Select **Operate** -> **Compliance** -> **Data security and governance**.
3. Select the test subscription.
4. Enable **Powered by Microsoft Purview**.
5. Record only safe references: subscription alias, Foundry app/resource alias,
   enablement owner, timestamp, and status.

Alternative Azure portal route:

1. Open the Azure portal.
2. Go to **Microsoft Defender for Cloud** -> **Environment settings**.
3. Select the subscription.
4. Go to **AI services** -> **Settings**.
5. Enable data security for AI interactions.

Decision notes:

- This is a paid Purview capability, not a feature included in Defender for AI
  Services.
- Enable only after the customer accepts that Foundry interaction data for the
  subscription flows to the tenant Purview environment.
- Record any portal wording differences instead of forcing a screenshot into the
  lab output.

## 3. Configure Purview collection

In Microsoft Purview:

| Area | Portal path / action | Accepted when |
|---|---|---|
| Audit | **Audit** -> activate Microsoft Purview Audit if not active. | Audit is active for the tenant and the test time window. Audit Standard generally retains 180 days. |
| DSPM | **Data Security Posture Management**. Some guidance may show **Solutions** -> **DSPM for AI (classic)** -> **Recommendations**. | DSPM collection for AI can be viewed by the assigned reviewer. |
| Recommendation | Enable or verify **Secure data in Azure AI apps and agents**. | Recommendation state and owner are recorded. |
| Collection policy | Enable or verify **Secure interactions from enterprise apps** / **DSPM for AI - Capture interactions for enterprise AI apps**. | Policy state is enabled or deliberately deferred with owner and reason. |
| Custom apps | For custom or Entra-registered apps, follow the custom app integration path and KYD collection policy only with deliberate customer approval for prompt/response storage. | App ID/reference, collection scope, and storage acceptance are recorded without secrets. |

## 4. Run the synthetic Foundry test

1. Confirm the app uses the named non-production Foundry resource and pilot API
   path.
2. Confirm the auth path. Data-security policy enforcement is limited to
   managed-inference `/chat/completions` calls using an Entra user-context token
   or explicit user context.
3. Submit one synthetic, non-customer interaction through the non-production app.
4. Record the safe test reference: user, time window, app/resource alias, expected
   SIT/classifier, API path, auth context, and whether prompt/response content
   viewing was intentionally avoided.

Do not store the prompt, response, screenshots, policy export, tenant ID,
resource endpoint, secret, or customer content in this repository.

## 5. Inspect DSPM Activity Explorer

Portal route: **Purview** -> **DSPM** -> **Activity explorer**.

Filters:

- **AI app category** = **Enterprise AI apps**
- **App** = **Azure AI**
- Test user
- Test time window

Expected result:

- AI interaction event for the synthetic test.
- Test user and timestamp.
- App and access context.
- Sensitive information type or file-reference metadata if the synthetic test
  matched.

Interpretation:

| Result | How to record it |
|---|---|
| Event found | Record safe event reference, reviewer, filters, timestamp range, app/resource alias, and observed metadata categories. |
| Event delayed | DSPM reports and some views can take about 24 hours; record recheck time and owner. |
| No event | Validate subscription enablement, policy state, user/time filters, app category, role, license, and API/auth path before calling it a no-result. |
| Unsupported | Record the exact model/API/auth/agent path and route to Foundry/Purview owner. |

Prompt/response text requires Content Explorer Content Viewer or Purview Data
Security AI Content Viewer. Avoid content viewing unless the customer explicitly
approves it.

## 6. Search Audit

Portal route: **Purview** -> **Audit** -> search the test user and time window.

Expected evidence:

- `ConnectedAIAppInteraction` / `ConnectedAIApp` activity.
- Identity such as `ConnectedAIApp.AzureAI.<resource>`.
- Correlation to the test user and time window.

Record:

| Field | Value to capture |
|---|---|
| Search owner | Person or role that ran the search. |
| Scope | User, time window, app/resource alias, and workload terms. |
| Result | Event reference or no-result with validated scope. |
| Retention | Audit Standard generally retains 180 days; record if Premium or different tenant policy applies. |
| Limitation | Missing role, disabled audit, unsupported path, or delayed indexing. |

## 7. Review DSPM reports

Portal route: **Purview** -> **Reports** -> **Enterprise AI apps**.

Expected after processing:

- Total interactions.
- Sensitive interactions when the synthetic classifier/SIT matched.
- App and user/activity trend data appropriate to the tenant view.

Reports can take about 24 hours. A same-day empty report is a recheck item, not a
safety conclusion.

## 8. Classify DLP simulation boundary

Portal route: **Purview** -> **Data Loss Prevention** -> **Policies** -> create
or edit policy -> **Simulate** or turn on policy -> **Run policy in simulation
mode**.

Expected for supported simulation surfaces:

- Policy status: **In simulation**.
- **View simulation** shows matching items or alerts where supported.
- Activity Explorer policy mode can show `TestWithNotifyUser` or
  `TestWithoutNotifyUser`.

Boundary statement to include in every S2 decision:

> DLP simulation is used for policy tuning and observation. Documented DLP
> simulation workload locations do not list Enterprise AI apps / Foundry as
> end-to-end prompt blocking evidence, so S2 does not claim Foundry runtime
> blocking from a simulation result.

## 9. Configure or verify retention

Portal route: **Purview** -> **Data Lifecycle Management** -> **Policies** ->
**Retention policies**.

Steps:

1. Create or verify a retention policy that includes **Enterprise AI apps**.
2. Record the approved period, owner, and scope.
3. Confirm whether the pilot is Copilot, Foundry, custom Entra-registered app, or
   another non-Copilot generative app.
4. For non-Copilot generative apps, record whether content capture/collection is
   enabled; prompts and responses require collection before retention can apply
   to that content.

Do not validate retention by deleting AI interaction data.

## 10. Configure or verify eDiscovery route

Portal route: **Purview** -> **eDiscovery** -> **Cases** -> **Create case**.

Steps:

1. Create or identify the case owner.
2. Create a search with the relevant mailbox.
3. For Foundry, use item class
   `IPM.SkypeTeams.Message.ConnectedAIApp.AzureAI.<AzureResourceName>`.
4. For Copilot, all AI activity can be searched when that broader scope is
   approved.
5. Record only the route, case/search reference, owner, and limitation.

Do not use deletion as validation.

## 11. Support and limit decision table

| Area | Supported claim | Limit / caveat | Decision action |
|---|---|---|---|
| Subscription enablement | Foundry subscription is connected to tenant Purview. | All Foundry apps in that subscription send interaction data to Purview. | Use non-production subscription; record customer acceptance. |
| DSPM Activity Explorer | Synthetic Foundry interaction is observable as Azure AI / Enterprise AI app event. | Delays and role/license filters can hide results. | Recheck before declaring no-result. |
| Audit | ConnectedAIAppInteraction / ConnectedAIApp record can be searched for test user/time. | Audit must be active; Standard generally retains 180 days. | Record audit route and owner. |
| DSPM reports | Enterprise AI apps reports show total and sensitive interactions. | Reports can take about 24 hours. | Record report recheck if not ready. |
| DLP simulation | Policy simulation helps tune conditions and observe matches. | Not end-to-end Foundry prompt blocking evidence. | Classify as observation/tuning only. |
| Policy enforcement | Foundry data-security policies apply to managed-inference `/chat/completions` with Entra user-context token or explicit user context. | Other auth flows may be observable but not policy-enforced. | Verify exact API/auth path. |
| Network isolation | No supported claim from this Purview integration. | Network isolation is not supported by the integration. | Route to platform/network architecture. |
| Agents | Foundry control-plane guidance says subscription app/agent interaction data flows to Purview. | Defender onboarding guidance says Foundry-agent data/context is not currently supported. | Verify exact pilot model/API/agent path; do not assume coverage. |
| Custom apps | Custom app integration and KYD collection can capture prompts/responses. | Use only after customer accepts storage and evidence handling. | Record deliberate approval and scope. |

## 12. Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Preflight | Non-production subscription, tenant Purview, licensing/billing, roles, pilot path, and evidence handling are recorded. | Foundry owner / Compliance owner |
| Foundry enablement | The test subscription shows **Powered by Microsoft Purview** enabled or the blocker is documented. | Foundry Account Owner |
| Purview configuration | Audit, DSPM collection, recommendation, and enterprise app interaction policy state are verified. | Purview Compliance Admin |
| Synthetic test | One non-customer interaction is submitted through the named app/model/API/auth path. | App owner |
| Activity Explorer | Azure AI / Enterprise AI app event is found, delayed with recheck owner, or unsupported with path details. | Security Reader / AI Viewer |
| Audit | ConnectedAIAppInteraction / ConnectedAIApp search result or validated no-result is recorded. | Audit owner |
| DSPM reports | Enterprise AI apps report is checked after processing or assigned a 24-hour recheck. | DSPM owner |
| DLP boundary | Simulation status and matches are recorded only as observation/tuning; no Foundry prompt-blocking claim is made. | Information Protection Admin |
| Retention | Enterprise AI apps retention policy and approved period are recorded, including content-capture dependency. | Records-management owner |
| eDiscovery | Case/search route and Foundry item class are recorded; deletion is not used for validation. | eDiscovery owner |
| Limits | Managed-inference/API/auth, network isolation, custom app storage, and agent caveats are explicitly accepted or routed. | Governance lead |

## Boundary note

S2 records portal evidence routes and decisions. It exports no customer data,
changes no policy outside the customer change process, claims no blanket runtime
enforcement, and approves no production release.

## Related references

- [Use Microsoft Purview to manage data security and compliance for Microsoft Foundry](https://learn.microsoft.com/en-us/purview/ai-azure-foundry)
- [Manage compliance and security in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/control-plane/how-to-manage-compliance-security)
- [Configure DSPM for AI for custom AI apps](https://learn.microsoft.com/en-us/purview/developer/configurepurview)
- [Develop and deploy secure and compliant Microsoft Foundry or custom AI apps](https://learn.microsoft.com/en-us/purview/developer/secure-ai-with-purview)
- [Learn about DLP simulation mode](https://learn.microsoft.com/en-us/purview/dlp-simulation-mode-learn)
- [Learn about retention for Copilot and AI apps](https://learn.microsoft.com/en-us/purview/retention-policies-copilot)
- [Search the audit log](https://learn.microsoft.com/en-us/purview/audit-search)
- [Search for and delete AI application data in eDiscovery](https://learn.microsoft.com/en-us/purview/edisc-search-copilot-data)
