# Session 12 implementation artifacts

The repository keeps the definitions that operators reuse:

| Path | Purpose | Authoritative state |
|---|---|---|
| `red-team/attack-plan.json` | Defines the bounded taxonomy, evaluators, attack strategies, and privacy rules. | Microsoft Foundry holds the approved taxonomy, run details, and aggregate results. |
| `defender/ai-alert-hunt.kql` | Queries current AI security alerts using exact titles. | Microsoft Defender holds alerts and incidents. |
| `operations/soc-triage-playbook.md` | Routes triage and recovery for this control. | The SOC system holds case, routing, and disposition records. |

The approved change system holds authorization, remediation, residual-risk, and release decisions.
Foundry, Defender, and the SOC system retain run, alert, and delivery records. The scripts accept
current inputs and write aggregate output only to an approved external security record store.
