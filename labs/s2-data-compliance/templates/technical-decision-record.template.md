# Technical decision record

[S2 Technical decisions](../../../docs/s2-data-compliance/technical.md) — option
menus and selection criteria for this record.

Copy this blank record into the customer's approved records system. It captures a
customer-owned technical decision, the options considered, rationale, owner, and
adoption stage. It does not make a tenant change, export content, or approve
production.

## Decision

| Field | Record |
|---|---|
| Decision under review | ‹e.g. data classification / PII and retrieval handling / compliance and residency mapping› |
| Bounded agent, workload, and data-source scope | |
| Decision owner and date | |

## Options considered

| Option | Fit for this scope | Key trade-off / limitation | Chosen? (yes / no / deferred) |
|---|---|---|---|
| Microsoft Purview Information Protection (sensitivity labels and DLP) | | | |
| Existing enterprise DLP or classification process | | | |
| Manual / customer-defined classification | | | |
| Gateway PII masking (AI Hub Gateway / Citadel pattern) | | | |
| Upstream data minimization at the source | | | |
| Microsoft Purview data map / DSPM for AI review | | | |
| Azure AI Content Safety | | | |
| Data residency / region pinning | | | |
| GDPR and records-of-processing mapping | | | |
| Sector-specific regulation mapping | | | |
| Retention ownership | | | |

## Chosen option and rationale

| Field | Record |
|---|---|
| Selected option(s) | |
| Rationale (criteria that decided it) | |
| Alternatives rejected or deferred and why | |
| Evidence references (customer records system only) | |
| Named owner(s) | |
| Dependencies (classification, source permissions, S3/S5/S6, customer change process) | |
| Verified-status caveat (availability / licensing / region checked on) | |

## Adoption progress

| Field | Record |
|---|---|
| Adoption stage (decided / backlogged / in adoption) | |
| S0 maturity dimension advanced | Data posture / compliance evidence / retention ownership |
| Next step and owner | |
| Review date and S12 portfolio reference | |
