# Implementation artifacts

These artifacts hold the module-owned deployment definitions and decision records.

- `defender/` enables the Defender for Cloud AI services plan and keeps the extension decisions.
- `sentinel/` deploys the Copilot jailbreak analytics rule and stores the external-IP hunting query.
- `shadow-ai/` records Defender for Cloud Apps sanction decisions before portal changes.

Keep tenant IDs, subscription IDs, resource IDs, prompt text, alert exports, user names, IP exports,
tokens, and app credentials out of this folder. Store those values in the approved customer system.
