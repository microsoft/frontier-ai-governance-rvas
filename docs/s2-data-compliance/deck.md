# S2 · Foundry Purview Compliance Runbook

**Facilitator deck**

Microsoft default: **Microsoft Foundry + Microsoft Purview Data Security
Posture Management, Audit, retention, eDiscovery, and DLP simulation** for a
non-production Foundry path.

Concrete decision: **Can we verify Purview observation and investigation routes
for this exact Foundry pilot path, and can we name what is not enforced or not
supported?**

---

## Start with the subscription blast radius

- Use a dedicated non-production Azure subscription.
- Enabling Purview in Foundry sends interaction data from all Foundry apps in
  that subscription to the tenant Purview environment.
- Confirm Purview exists, licensing/billing is approved, and evidence handling is
  customer-owned.
- Do not use customer data, prompts, outputs, screenshots, exports, tenant IDs,
  endpoints, or secrets in the lab artifact.

Note:
If the room wants to use a production subscription, pause. The subscription-level
collection impact must be deliberately accepted by the customer.

---

## Role check before portal work

- Foundry enablement: Foundry Account Owner / Azure AI Account Owner.
- DSPM create/edit: Compliance Admin / Compliance Administrator.
- Read-only review: Security Reader or AI Viewer.
- Content viewing: Content Explorer Content Viewer or Purview Data Security AI
  Content Viewer, only if explicitly approved.
- DLP simulation: Information Protection Admin.
- DLP creation may also use Compliance Admin, Compliance Data Admin, Information
  Protection, or Security Admin.

Note:
Missing roles are a blocker, not an invitation to borrow screenshots or paste
exports into the repo.

---

## Enable from Foundry first

1. Open `ai.azure.com`.
2. Go to **Operate** -> **Compliance** -> **Data security and governance**.
3. Select the test subscription.
4. Enable **Powered by Microsoft Purview**.
5. Record the safe reference, owner, timestamp, and state.

Alternative: Azure portal -> **Microsoft Defender for Cloud** -> **Environment
settings** -> subscription -> **AI services** -> **Settings** -> enable data
security for AI interactions.

Note:
The Azure route is a paid Purview data-security capability. It is not included in
Defender for AI Services.

---

## Verify Purview collection

In Purview, verify:

- **Audit** is activated.
- **Data Security Posture Management** is available. Some guidance still says
  **Solutions** -> **DSPM for AI (classic)** -> **Recommendations**.
- Recommendation **Secure data in Azure AI apps and agents** is enabled or
  deliberately deferred.
- Policy **Secure interactions from enterprise apps** / **DSPM for AI - Capture
  interactions for enterprise AI apps** is enabled or deliberately deferred.
- Custom/Entra app KYD collection is used only after the customer accepts
  prompt/response storage.

Note:
The point is collection and observation for the pilot path, not a Purview feature
tour.

---

## Verify the exact pilot path

Record the model, API, app/resource, auth flow, and agent route before testing.

Hard limits:

- Policy enforcement applies to managed-inference `/chat/completions` with Entra
  user-context token or explicit user context.
- Other auth flows may be visible in Audit or DSPM Activity Explorer but are not
  policy-enforced.
- Network isolation is not supported by this Purview integration.
- Do not assume agent coverage: Foundry control-plane guidance and Defender
  onboarding guidance differ. Verify the exact path.

Note:
If the team cannot name the path, the decision is blocked.

---

## Run one safe synthetic interaction

- Use the non-production Foundry app.
- Submit one synthetic non-customer test prompt.
- Record the test user, time window, app/resource alias, expected classifier/SIT,
  API path, and auth context.
- Do not store prompt text, response text, screenshots, policy exports, resource
  endpoints, tenant IDs, or secrets.

Note:
The lab needs enough metadata to find the event, not enough content to create a
new compliance problem.

---

## Inspect DSPM Activity Explorer

Portal route: **Purview** -> **DSPM** -> **Activity explorer**.

Filter:

- **AI app category** = **Enterprise AI apps**
- **App** = **Azure AI**
- Test user and test time window

Expected event:

- AI interaction event.
- Test user and timestamp.
- App/access context.
- SIT or file-reference metadata if the test matched.

Note:
Prompt/response text requires Content Viewer or Data Security AI Content Viewer.
Avoid content viewing unless explicitly approved.

---

## Search Audit

Portal route: **Purview** -> **Audit**.

- Search the test user and time window.
- Look for `ConnectedAIAppInteraction` / `ConnectedAIApp` records.
- Identity can look like `ConnectedAIApp.AzureAI.<resource>`.
- Audit Standard generally retains 180 days.
- Record event reference or validated no-result with scope.

Note:
Empty audit results are not meaningful until subscription, policy, role, user/time,
app, API, auth, and indexing delay are checked.

---

## Check DSPM reports after processing

Portal route: **Purview** -> **Reports** -> **Enterprise AI apps**.

- Reports can take about 24 hours.
- Expect total interactions.
- Expect sensitive interactions if the classifier/SIT matched.
- If not ready, assign a recheck owner and time.

Note:
A same-day blank report is usually a follow-up item, not a green light.

---

## Draw the DLP boundary honestly

Portal route: **Purview** -> **Data Loss Prevention** -> **Policies** ->
**Simulate** or **Run policy in simulation mode**.

Expected:

- Policy status **In simulation**.
- **View simulation** shows matching items/alerts where supported.
- Activity Explorer policy mode may show `TestWithNotifyUser` or
  `TestWithoutNotifyUser`.

Boundary:
Documented DLP simulation workload locations do not list Enterprise AI apps /
Foundry as end-to-end prompt blocking evidence.

Note:
Say "policy tuning and observation," not "Foundry prompt blocking verified."

---

## Check retention and eDiscovery

Retention route:

- **Purview** -> **Data Lifecycle Management** -> **Policies** -> **Retention
  policies**.
- Include **Enterprise AI apps** and the approved period.
- Non-Copilot generative apps need content capture/collection for prompts and
  responses.

eDiscovery route:

- **Purview** -> **eDiscovery** -> **Cases** -> **Create case**.
- Search the relevant mailbox.
- For Foundry use
  `IPM.SkypeTeams.Message.ConnectedAIApp.AzureAI.<AzureResourceName>`.
- Do not use deletion as validation.

Note:
The outcome is an investigation route with owner, not a destructive test.

---

## Decide and route gaps

Classify each area:

| Area | Decision |
|---|---|
| Foundry enablement | Enabled / blocked / deferred |
| Activity Explorer | Event found / delayed / no-result / unsupported |
| Audit | Event found / validated no-result / blocked |
| DSPM reports | Ready / 24-hour recheck / unsupported |
| DLP | Simulation observation only / not configured / unsupported |
| Retention | Enterprise AI apps policy verified / gap routed |
| eDiscovery | Case/search route verified / gap routed |
| Enforcement limits | Managed-inference API/auth path accepted or routed |

Note:
Close with owner, accepted-when condition, target event, and customer evidence
reference. S2 approves no production release.
