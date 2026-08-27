# Purview coverage handoff

This Session 10 record keeps the manual product, label, source-access, DSPM, and DLP decisions in one
place. The data owner maintains it and reviews it on the recorded date.

| Field | Decision |
|---|---|
| Owner role | `__REQUIRED_DATA_OWNER_ROLE__` |
| Reviewed on | `__REQUIRED_COVERAGE_REVIEW_DATE__` |
| Control ID | `PURVIEW-AI-DATA-10` |
| Target scope | Approved nonproduction Microsoft 365 tenant |
| Purview operator role | `__REQUIRED_PURVIEW_OPERATOR_ROLE__` |
| Raw content retention | Prohibited |

## Verification boundary

The preflight scripts check the approved Microsoft 365 tenant identity and the Microsoft Graph
Audit Search permission. The following checks remain manual:

- Microsoft Agent 365 and Microsoft Purview entitlements;
- Microsoft Foundry Purview Data Security enablement and pay-as-you-go state;
- the selected sensitivity label identity through Microsoft Purview or Compliance PowerShell;
- DLP policy name availability through Microsoft Purview or Compliance PowerShell;
- Agent 365 label VIEW and EXTRACT rights;
- DLP scope, simulation, propagation, and enabled state; and
- DSPM findings and source-access review.

| Field | Decision |
|---|---|
| Label identity status | `__REQUIRED_LABEL_IDENTITY_STATUS__` |
| Label identity verified on | `__REQUIRED_LABEL_IDENTITY_VERIFIED_DATE__` |
| Label identity method | Microsoft Purview portal or Compliance PowerShell `Get-Label` |
| DLP policy name availability status | `__REQUIRED_DLP_NAME_AVAILABILITY_STATUS__` |
| DLP policy name verified on | `__REQUIRED_DLP_NAME_VERIFIED_DATE__` |
| DLP policy name method | Microsoft Purview portal or Compliance PowerShell `Get-DlpCompliancePolicy` |

The Graph application permission is `AuditLogsQuery.Read.All`.

## Product coverage

### Microsoft Agent 365

| Field | Decision |
|---|---|
| Agent instance alias | `__REQUIRED_AGENT_INSTANCE_ALIAS__` |
| Qualifying license | `__REQUIRED_AGENT365_LICENSE_STATUS__` |
| E5 prerequisite | `__REQUIRED_E5_STATUS__` |
| Control boundary | DLP explicitly targets the agent instance and test group recorded in the DLP template. |

### Microsoft Foundry

| Field | Decision |
|---|---|
| Azure subscription alias | `__REQUIRED_FOUNDRY_SUBSCRIPTION_ALIAS__` |
| Purview Data Security status | `__REQUIRED_FOUNDRY_PURVIEW_STATUS__` |
| Enablement route | `__REQUIRED_FOUNDRY_ENABLEMENT_ROUTE__` |
| Pay-as-you-go policy billing | `__REQUIRED_PURVIEW_PAYG_STATUS__` |
| Audit license status | `__REQUIRED_FOUNDRY_AUDIT_STATUS__` |
| User context status | `__REQUIRED_FOUNDRY_USER_CONTEXT_STATUS__` |
| Control boundary | The Agent 365 DLP policy does not govern Foundry calls. |

## Purview entitlements

| Capability | Status |
|---|---|
| DSPM | `__REQUIRED_DSPM_ENTITLEMENT__` |
| Data Loss Prevention | `__REQUIRED_DLP_ENTITLEMENT__` |
| Audit | `__REQUIRED_AUDIT_ENTITLEMENT__` |
| eDiscovery | `__REQUIRED_EDISCOVERY_ENTITLEMENT__` |

## Sensitivity label

| Field | Decision |
|---|---|
| Display name | `__REQUIRED_SENSITIVITY_LABEL_NAME__` |
| Label ID | `__REQUIRED_SENSITIVITY_LABEL_ID__` |
| Publication scope alias | `__REQUIRED_LABEL_POLICY_SCOPE_ALIAS__` |
| SharePoint and OneDrive label support | `__REQUIRED_SHAREPOINT_LABEL_SUPPORT_STATUS__` |
| Encryption decision | `__REQUIRED_LABEL_ENCRYPTION_DECISION__` |
| Agent instance VIEW and EXTRACT rights | `__REQUIRED_AGENT_LABEL_RIGHTS_STATUS__` |
| Labelled synthetic item alias | `__REQUIRED_LABELLED_SYNTHETIC_ITEM_ALIAS__` |
| Generated content inherits the source label | No |
| Generated-content observation | `__REQUIRED_GENERATED_CONTENT_LABEL_OBSERVATION__` |
| Compensating control | `__REQUIRED_GENERATED_CONTENT_COMPENSATING_CONTROL__` |
| Owner role | `__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__` |

## Source access

| Field | Decision |
|---|---|
| Agent instance alias | `__REQUIRED_AGENT_INSTANCE_ALIAS__` |
| Source alias | `__REQUIRED_SYNTHETIC_SOURCE_ALIAS__` |
| Source type | SharePoint or OneDrive |
| Synthetic only | Yes |
| Data classification | `__REQUIRED_DATA_CLASSIFICATION__` |
| Sensitivity label ID | `__REQUIRED_SENSITIVITY_LABEL_ID__` |
| Agent access | Explicitly shared |
| Data owner role | `__REQUIRED_DATA_OWNER_ROLE__` |
| Review date | `__REQUIRED_SOURCE_REVIEW_DATE__` |
| Expiry date | `__REQUIRED_SOURCE_EXPIRY_DATE__` |

## DSPM review

Reviewed on: `__REQUIRED_FINDINGS_DATE__`

Record summaries only. Do not copy prompts, responses, identities, source names, URLs, or raw
activity records.

| Category | Summary | Decision | Owner role |
|---|---|---|---|
| Sensitive grounding data | `__REQUIRED_SENSITIVE_GROUNDING_SUMMARY__` | `__REQUIRED_SENSITIVE_GROUNDING_DECISION__` | `__REQUIRED_DATA_OWNER_ROLE__` |
| Agent oversharing path | `__REQUIRED_OVERSHARING_SUMMARY__` | `__REQUIRED_OVERSHARING_DECISION__` | `__REQUIRED_AGENT_OWNER_ROLE__` |
| Unlabelled generated content | `__REQUIRED_GENERATED_CONTENT_SUMMARY__` | `__REQUIRED_GENERATED_CONTENT_DECISION__` | `__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__` |

## DLP policy

| Field | Decision |
|---|---|
| Policy name | `__REQUIRED_DLP_POLICY_NAME__` |
| Description | `implementationSession=10-purview-data-governance` |
| Workload | Microsoft Agent 365 |
| Agent instance ID | `__REQUIRED_AGENT_INSTANCE_ID__` |
| Agent instance alias | `__REQUIRED_AGENT_INSTANCE_ALIAS__` |
| Test group alias | `__REQUIRED_TEST_GROUP_ALIAS__` |
| Out-of-scope test group alias | `approved-out-of-scope-synthetic-group` |
| Environment | Nonproduction |
| Supported interaction directions | Human-to-agent; agent-to-human |
| Supported locations | Microsoft Teams; OneDrive or SharePoint; Exchange email |
| Rule condition | Sensitivity label |
| Rule label ID | `__REQUIRED_SENSITIVITY_LABEL_ID__` |
| Action | `__REQUIRED_DLP_ACTION__` |
| User notification | `__REQUIRED_DLP_NOTIFICATION_DECISION__` |
| Incident report owner role | `__REQUIRED_DLP_INCIDENT_OWNER_ROLE__` |
| Initial mode | `TestWithNotifications` |
| Final mode | `Enable` |
| Propagation allowance in hours | `__REQUIRED_DLP_PROPAGATION_HOURS__` |
