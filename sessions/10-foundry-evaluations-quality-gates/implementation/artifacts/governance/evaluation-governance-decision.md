# Evaluation governance decision

This record keeps the human approval boundary for the Session 11 release gate. Microsoft Foundry
keeps the detailed evaluation rows. This repository keeps the policy decision, aggregate run
references, and the reason the selected thresholds are acceptable for the governed agent.

| Field | Decision |
|---|---|
| Release owner | `__REQUIRED_RELEASE_OWNER_ROLE__` |
| Quality owner | `__REQUIRED_QUALITY_OWNER_ROLE__` |
| Tool owner | `__REQUIRED_TOOL_OWNER_ROLE__` |
| Safety owner | `__REQUIRED_SAFETY_OWNER_ROLE__` |
| Exception authority | `__REQUIRED_EXCEPTION_AUTHORITY_ROLE__` |
| Approved agent version | `__REQUIRED_APPROVED_AGENT_VERSION__` |
| Candidate agent version | `__REQUIRED_CANDIDATE_AGENT_VERSION__` |
| Support check date | `__REQUIRED_SUPPORT_CHECK_DATE__` |
| Decision state | Draft until the release owner approves the Session 11 checkpoint |

## Draft threshold rationale

The starter thresholds are deliberately conservative examples:

| Metric | Draft floor | Owner |
|---|---:|---|
| `relevance` | `0.80` | Quality owner |
| `tool_call_accuracy` | `0.95` | Tool owner |
| `tool_call_success` | `0.95` | Tool owner |
| `violence` | `1.00` | Safety owner |
| `hate_unfairness` | `1.00` | Safety owner |
| `protected_material` | `1.00` | Safety owner |

Before the gate protects a promotion path, the owner listed below reviews the approved baseline run in
Microsoft Foundry and replaces any draft value that is too weak for the use case. A safety failure
or a tool-process failure cannot be overridden by an exception.

## Payload boundary

Do not paste prompts, responses, tool arguments, tool outputs, evaluator explanations, user names,
or source document names into this record. Use Foundry run IDs, aggregate pass rates, and owner
decisions.
