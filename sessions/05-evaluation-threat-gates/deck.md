---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 05</p>

# Evaluation, red-team, and threat release gates

330 minutes · Produce one quality and security release decision

---

## Why it matters

An average score can hide a failed tool path or safety regression.

**Quality, tool process, prohibited actions, and threat routing remain separate blocking layers.**

---

## Architecture overview

![Azure AI Content Safety](assets/icons/microsoft/azure-ai-content-safety.svg)

```text
governed APIM endpoint -> fixed agent and tools
                              |
                  +-----------+-----------+
                  |                       |
          Foundry evaluation       red-team comparison
                  +-----------+-----------+
                              |
                    customer release gate
```

The gate tests a release. It does not run inside APIM.

---

## Runtime controls and release signals

| Runtime path | Release and security path |
| --- | --- |
| APIM authorization, safety, rate limits | Foundry evaluation results |
| Fixed agent and tool versions | Authorized red-team findings |
| Correlated operational telemetry | Defender posture and SOC incidents |

These controls have different owners. A strong quality score cannot cover a tool or security failure.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Session position |
| --- | --- |
| Test endpoint | Use the governed APIM route |
| Gate layers | Keep quality, tool, safety, and adversarial results separate |
| Red team | Same authorized plan against fixed versions |
| Defender | Keep posture and incidents in the SOC process |
| Release record | Store aggregates and hashes, not prompts |

---

<!-- _class: implementation -->

## Working path

1. Run the approved baseline and candidate evaluation.
2. Apply the quality and tool-process gate.
3. Run the bounded red-team plan.
4. Compare every risk key.
5. Confirm the Defender-to-SOC route.

---

## Safety gates

- Use fixed baseline and candidate versions.
- Keep synthetic data and authorized attack scope separate from production content.
- Stop when the selected Defender signal does not reach the SOC queue with a stable identifier.
- Block promotion when any quality, tool, or threat layer fails.

---

## Expected result

The approved aggregate returns `PASS`. A generated tool regression returns `BLOCK`. The SOC owner
can locate the selected Defender signal by its alert or incident ID.

---

## Operating state

Foundry retains detailed evaluation results. Security systems retain threat findings. The repository keeps the reusable thresholds, attack plan, and release policy.

---

<!-- _class: closing -->

# Thank you!
