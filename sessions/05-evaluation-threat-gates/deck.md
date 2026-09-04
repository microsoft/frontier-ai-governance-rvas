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
fixed versions -> evaluation -> quality gate
       |                         |
       +------> red team --------+-> PASS or BLOCK
                                 |
                          Defender and SOC
```

Detailed results stay in Foundry and security systems.

---

<!-- _class: decision -->

## Implementation tradeoffs

- Synthetic dataset and fixed versions
- Blocking evaluators and thresholds
- Authorized attack plan and prohibited actions
- Judge model, region, budget, and run window
- Payload-free release and security stores

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
- Block promotion when any quality, tool, or threat layer fails.

---

## Expected result

The approved aggregate returns `PASS`. A generated tool regression returns `BLOCK`. No candidate moves to promotion while a blocking layer fails.

---

## Operating state

Foundry retains detailed evaluation results. Security systems retain threat findings. The repository keeps the reusable thresholds, attack plan, and release policy.

---

<!-- _class: closing -->

# Thank you!
