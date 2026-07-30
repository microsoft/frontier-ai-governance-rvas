# S8 · Authorized Red Teaming Runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · AI Red Teaming Agent, PyRIT, risk categories, target support, region support, and SDK/API versions change. Confirm current Microsoft Learn pages and customer authorization before any test starts.

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Legal / risk</span>

!!! abstract "What this workshop does"
    S8 authorizes, runs, reviews, routes, and retests a bounded defensive red-team check for one customer-owned non-production target. It starts with support and authorization gates, then uses the AI Red Teaming Agent where supported, PyRIT or an approved manual/third-party path where needed, and records only safe run references and finding routes.

## 1. Stop before any test if support or authorization is missing

Before selecting categories or tools, confirm:

- Written authorization and rules of engagement name target, version, operators,
  time window, methods, categories, data limits, stop conditions, SOC contact,
  legal/risk contact where required, and evidence handling.
- Target is customer-owned and **non-production**. Production users, production
  data, production endpoints, and production change windows are out of scope for
  this workshop.
- Target support is known. AI Red Teaming Agent cloud supports Foundry project
  deployments, Azure OpenAI model deployments connected to the Foundry project,
  and Foundry Agents in the project. Local AI Red Teaming Agent/PyRIT routes have
  their own text-only, single-turn, adapter, Python, region, and preview limits.
- Evidence location is customer-owned. Do not store prompts, outputs, datasets,
  endpoint details, payloads, credentials, incident data, screenshots, exports,
  or raw run records in this repository.

If any item is missing, record **blocked**, **unsupported**, or **production-test
deferred** and route to the customer owner. Do not start testing.

## 2. AI Red Teaming Agent playbook

Use this path when the target and category are supported and the customer can
operate the native Foundry route.

1. Open `ai.azure.com`, select the Foundry project, and copy the project
   endpoint from **Overview**.
2. Confirm the operator has **Foundry User** or approved equivalent access.
3. Check target support:
   - Foundry project deployment;
   - connected Azure OpenAI/Foundry Tools deployment using
     `connectionName/deploymentName`;
   - Foundry Agent target with agent name/version.
4. Select approved categories. For local AI Red Teaming Agent, documented risk
   categories include `Violence`, `HateUnfairness`, `Sexual`, `SelfHarm`,
   `ProtectedMaterial`, `CodeVulnerability`, and `UngroundedAttributes`; cloud
   agentic scenarios can include configured evaluators such as prohibited
   actions, task adherence, and sensitive-data leakage. Record unsupported
   categories before running.
5. Configure the run:
   - project endpoint;
   - target name, deployment, connection, or agent version;
   - category list;
   - objective/sample count or taxonomy reference where used;
   - approved strategy group or baseline-only setting;
   - stop conditions, rate/cost limit, and monitoring window.
6. Create the red-team/evaluation group and run through the Microsoft Foundry SDK
   or approved customer automation.
7. Poll run status until **completed**, **failed**, or **canceled**.
8. Review the scorecard: Attack Success Rate (ASR), category breakdown, target
   version, method, limitations, and not-comparable conditions.
9. Export or reference findings in the customer records system. Store only target
   alias, run ID, category, ASR/threshold verdict, finding route, and retest
   reference here.
10. Retest after remediation using the same category and comparison rule, or an
    approved alternate with reason.

## 3. PyRIT playbook

Use PyRIT only when the customer approves a repeatable custom route or when the
native AI Red Teaming Agent route does not cover the target/category.

Preflight:

- Approved target adapter boundary: callback, Azure OpenAI/Foundry deployment,
  PyRIT `PromptChatTarget`, custom HTTP target, or customer wrapper. The adapter
  must exclude production and must not expose secrets in notebooks or logs.
- Dataset/prompt source: Microsoft-curated objectives, customer-approved
  synthetic set, or customer-approved custom seed file. Keep source content in
  customer storage, not this repository.
- Python/runtime: approved environment for `azure-ai-evaluation[redteam]` or
  PyRIT; customer controls package source and dependency review.
- Evidence handling: scorecard/run output path points to the customer records
  system. Raw prompts, outputs, and payload content stay there.

Notebook route:

1. Open the customer-approved PyRIT or AI Red Teaming Agent notebook in the
   customer's controlled environment.
2. Load the target adapter from customer configuration.
3. Load the approved dataset/prompt source by reference.
4. Select categories and sample/objective counts allowed by the rules of
   engagement.
5. Run the scan against the non-production target.
6. Write the scorecard/run output to the customer evidence location.
7. Copy only safe references into the S8 template: method, target/run ID,
   categories, threshold verdict, support caveat, finding route, and retest
   result.

If the customer uses a command-line wrapper, run only the documented customer
wrapper command with safe references. Do not invent payloads or paste prompt
content into this repository.

## 4. Manual or third-party branch

Use this route for unsupported target types, legal/policy judgment, specialist
testing, or independent assessment.

Minimum records before handoff:

- Authorization reference and rules of engagement.
- Target alias, version, non-production environment, owner, reset/rollback path,
  monitoring window, and excluded production scope.
- Method: manual expert, third-party engagement, table-top review, or approved
  test tool.
- Categories and excluded categories.
- Threshold or qualitative success condition and owner.
- Evidence location and retention/export/deletion owner.
- Finding route: receiving owner, severity model, remediation path, release or
  lifecycle impact, stop condition, retest method, and accepted-risk authority.

Do not import third-party reports, raw notes, prompts, outputs, screenshots, or
payload details into this repository. Store a safe reference only.

## 5. Expected signals

| Signal | What to check | Action |
|---|---|---|
| Target supported | Foundry project deployment, connected Azure OpenAI/Tools deployment, Foundry Agent, or approved PyRIT adapter is in scope. | Continue only inside written rules of engagement. |
| Category unsupported | Category missing from tool support, evaluator unavailable, or target/category combination unsupported. | Route to alternate method or mark unsupported. |
| Run blocked by authorization | Missing written approval, ROE, SOC/legal contact, non-production proof, stop condition, or evidence owner. | Do not test; route blocker. |
| ASR above threshold | Category ASR or qualitative success exceeds the customer threshold. | Open finding, hold or route release impact, assign remediation and retest. |
| Result not comparable | Different target version, method, category, sample, threshold, or unsupported route prevents comparison. | Mark diagnostic-only; define re-run conditions. |
| Finding retested | Same category/success condition or approved alternate retest has a run ID/result. | Close only when severity/remediation owner accepts remaining risk. |

## 6. Lab output

`labs/s8-red-teaming/` contains the authorized testing lab kit and template. Store
completed run details, evidence, and findings in the customer's approved records
system. This repository keeps only blank templates and safe field shapes.

## Related references

- [Run AI Red Teaming Agent in the cloud](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/run-ai-red-teaming-cloud)
- [Run AI Red Teaming Agent locally](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/run-scans-ai-red-teaming-agent)
- [PyRIT documentation](https://microsoft.github.io/PyRIT/latest/)
- [S7 evaluation runbook](../s7-evaluation/technical.md)
