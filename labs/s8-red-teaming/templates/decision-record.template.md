# S8 · Authorized Red Teaming run record

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry
exports, endpoint details, payloads, credentials, secrets, tenant identifiers, or
live configuration.

## Scope

| Field | Value |
|---|---|
| Target alias |  |
| Target version |  |
| Environment | Non-production / deferred production request / other |
| Method | AI Red Teaming Agent / PyRIT / manual / third-party / unsupported / production-test deferred |
| Red-team lead |  |
| Target owner |  |
| Evidence owner/location |  |
| Remediation owner model |  |
| Retest owner |  |
| Stop condition |  |

## Authorization and support gate

| Check | State | Owner / evidence reference | Notes |
|---|---|---|---|
| Written authorization approved | Accepted / blocked / review |  |  |
| Rules of engagement approved | Accepted / blocked / review |  |  |
| Non-production target confirmed | Accepted / production-test deferred / blocked |  |  |
| SOC contact and monitoring window ready | Accepted / blocked / N/A / review |  |  |
| Legal/risk contact ready where required | Accepted / blocked / N/A / review |  |  |
| Evidence handling approved | Accepted / blocked / review |  |  |
| Rate/cost boundary approved | Accepted / blocked / review |  |  |
| Target support status checked | Supported / unsupported / preview / blocked / review |  |  |
| Category support status checked | Supported / unsupported / blocked / review |  |  |
| Retest route defined | Accepted / blocked / review |  |  |

## Target and method

| Field | Value |
|---|---|
| Target type | Foundry project deployment / connected Azure OpenAI-Foundry Tools deployment / Foundry Agent / PyRIT adapter / manual / third-party / other |
| Foundry project endpoint reference, if used |  |
| Agent/deployment/version reference |  |
| Approved adapter boundary, if PyRIT | Callback / PromptChatTarget / custom HTTP / customer wrapper / other |
| Dataset or prompt-source reference |  |
| Categories |  |
| Excluded categories |  |
| Threshold / qualitative tolerance |  |
| Threshold owner |  |
| Sample/objective count or manual sample note |  |
| Stop/rate/cost limit |  |

## Run result

| Field | Value |
|---|---|
| Target/run ID |  |
| Run status | Completed / failed / canceled / blocked / unsupported |
| Support status | Supported / unsupported / preview / diagnostic-only / blocked |
| ASR or qualitative result |  |
| Category breakdown reference |  |
| Result interpretation | Below threshold / ASR above threshold / not comparable / diagnostic-only / blocked |
| Result not comparable reason, if any |  |
| Safe finding export/reference |  |

## Finding route

| Field | Value |
|---|---|
| Finding reference |  |
| Category |  |
| Severity | Critical / high / medium / low / informational / disputed |
| Affected route |  |
| Finding route | Prompt/design / retrieval-data / tool-API / identity / gateway / Content Safety / Prompt Shields / SOC / legal-risk / evaluation / other |
| Remediation owner |  |
| Release or lifecycle impact | Continue / hold / block / route / accepted risk / N/A |
| Accepted-risk owner and expiry, if any |  |
| Stop condition if risk remains active |  |

## Retest

| Field | Value |
|---|---|
| Changed target version |  |
| Retest method | Same method/category / approved alternate |
| Retest run ID / result |  |
| Comparison rule | Same success condition / same threshold / qualitative adjudication / not comparable |
| Retest result | Passed / failed / not comparable / blocked |
| Closure owner |  |
| Remaining risk |  |
| Reopen trigger |  |

## Final action

| Decision | Select one | Rationale |
|---|---|---|
| Test completed within scope |  |  |
| Remediation required |  |  |
| Retest required |  |  |
| Route |  |  |
| Block |  |  |
| Unsupported |  |  |
| Production-test deferred |  |  |
| Accepted risk |  |  |
| Diagnostic-only |  |  |

## Blockers and next technical action

| Blocker / gap | Owner | Acceptance check | Next action | Target date/event |
|---|---|---|---|---|
|  |  |  |  |  |
