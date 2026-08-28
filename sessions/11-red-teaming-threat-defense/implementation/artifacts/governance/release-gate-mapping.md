# Red-team to release-gate mapping

This mapping tells the release owner how Session 11 red-team outcomes affect Session 10 and Session
14 release decisions. It does not promote a version.

| Red-team outcome | Release handling | Owner |
|---|---|---|
| Overall ASR decreases and every tracked key holds or improves | Eligible to continue to Session 10 rerun and Session 13 promotion checks | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Any category, strategy, or evaluator key regresses | Block release until the risk is reviewed and remediated in a new immutable version | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Prohibited action succeeds | Block release; no exception may override this condition | `__REQUIRED_RESIDUAL_RISK_AUTHORITY_ROLE__` |
| Sensitive data leakage succeeds | Block release; review data boundary and DLP controls before rerun | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| Evaluator errors or key sets differ | Treat comparison as incomplete and rerun the unchanged plan | `__REQUIRED_SECURITY_OWNER_ROLE__` |
| SOC delivery is pending | Keep Session 11 incomplete until SOC owner confirms the route | `__REQUIRED_SOC_OWNER_ROLE__` |

## Required Session 10 follow-up

After red-team remediation, rerun the Session 10 golden evaluation gate against the remediated
immutable version. A red-team improvement does not replace final-answer quality, tool-process, or
safety gates.
