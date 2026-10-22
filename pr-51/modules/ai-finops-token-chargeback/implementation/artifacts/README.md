# Implementation artifacts

These files define the optional AI FinOps module.

| File | Job |
|---|---|
| `policy/tag-allocation.bicep` | Assign the subscription tag policies and managed identities used for staged resource-group tag requirements and resource tag inheritance. |
| `policy/tag-allocation.bicepparam` | Hold the approved policy deployment inputs. |
| `cost/ai-budget-with-filters.bicep` | Deploy the filtered AI budget notifications. |
| `cost/ai-budget-with-filters.bicepparam` | Hold the approved budget inputs, filters, contacts, and action group. |
| `apim/token-chargeback-policy.xml` | Merge token metric dimensions and per-product quota into the existing AI gateway policy. |
| `queries/token-chargeback.kql` | Attribute token use by cost center, consumer, product, API, and model. |
| `finance/chargeback-decisions.json` | Record the finance, policy, budget, gateway, and restore decisions. |
| `finance/token-rate-table.json` | Record the finance-approved token rates used by chargeback reporting. |

Resolve every `__REQUIRED_*__` value in the approved private implementation path before deployment.
Do not store tenant IDs, subscription IDs, tokens, prompts, responses, or customer data in this
repository.
