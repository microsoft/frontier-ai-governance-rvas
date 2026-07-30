# About AI Governance Platform

AI Governance Platform is a co-delivered set of working sessions for deciding
agent ownership, applicable Microsoft controls, and retained customer evidence.
The facilitator runs the method; customer administrators perform privileged
actions, and customer owners make decisions and accept risk.

The programme identifies the next platform, security, engineering, or operating
action; the customer carries it out through its existing processes. See [What
customers get](customer-journey.md) for the practical path from a decision to
customer-owned work.

## Why AI-agent governance needs a complete approach

An agent can read business data, call tools, act for a user, use its own
identity, and change quickly. One generic review cannot cover the resulting
decisions about ownership, identity, data, platform, engineering, security, and
operations. Where appropriate, the work uses the customer's Microsoft
environment, including Entra Agent ID, Purview, Defender, Foundry, and Azure
API Management.

![A governed path turns strategic ambition into decisions leaders can stand behind: ambition and use cases feed accountable decisions, then enforceable controls, then evidence and observation, then portfolio learning, which loops back to ambition to learn and improve. Each stage leaves the customer with a decision, a control state, or an evidence reference.](../assets/diagrams/proof-flow.svg)

The programme asks questions people can answer in the room:

- Who owns the agent, its access, and its lifecycle?
- Which platform path and trust boundary must the agent use?
- How do we admit, change, publish, and retire the agent?
- Which Microsoft evidence supports the security, quality, and remediation decision?
- How does the customer improve governance across the agent portfolio?

## Delivery shape

The customer selects only the workshops that fit its evidence, architecture,
dependencies, and priorities.

| Phase | Goal | Typical decisions |
|---|---|---|
| **Establish accountability** | Set an accountable foundation. | Ownership, identity, data responsibilities, and evidence location. |
| **Choose the technical path** | Define platform and engineering controls. | Platform boundary, admission standards, and tool or API publication. |
| **Build assurance** | Review safety, quality, and release readiness. | Runtime evidence, evaluation, and authorized adversarial testing. |
| **Operate and improve** | Turn evidence into sustained action. | Reconciliation, operating review, model change control, and portfolio priorities. |

## Workshop map

| Customer question | Workshop | Decision and retained outcome |
|---|---|---|
| Who owns the pilot, and what technical blocker is first? | [Governance baseline and operating model](../s0-foundations/index.md) | Baseline, owner, evidence location, and first technical action. |
| Which identity and access boundary applies to each agent? | [Agent identity path](../s1-identity/index.md) | Ownership and authority review. |
| What data may the agent access, process, or expose? | [Data-path trace and control map](../s2-data-compliance/index.md) | Data findings and review actions. |
| Which enterprise platform path and trust boundary do we use? | [Platform route and trust boundaries](../s3-platform-foundation/index.md) | Platform-path decision and work list. |
| What must an agent pass before admission or major change? | [Agent build path and admission](../s4-agent-engineering/index.md) | Admission standard and change-review record. |
| How do we publish and withdraw tools, APIs, and MCP services safely? | [Tool and API admission and withdrawal](../s5-tool-api-governance/index.md) | Controlled publication and lifecycle model. |
| Does the approved runtime path produce security evidence we can review? | [Runtime-path evidence and response](../s6-security-runtime/index.md) | Runtime assurance decision and handoff. |
| Is quality and safety evidence strong enough to proceed? | [Evaluation evidence and release readiness](../s7-evaluation/index.md) | Evaluation and release decision. |
| What happens under approved misuse testing? | [Authorized red teaming and retest](../s8-red-teaming/index.md) | Findings, remediation, and residual-risk decision. |
| Do agent, identity, tool, and lifecycle records match? | [Control-plane reconciliation and lifecycle](../s9-control-plane/index.md) | Reconciliation and stewardship backlog. |
| What do operational evidence and trends require next? | [Operating evidence and FinOps](../s10-operate-measure/index.md) | Operating review, FinOps, drift hypothesis, and validation action. |
| How are approved models and prompts versioned, changed, and retired? | [LLMOps change control](../s11-llm-operations/index.md) | Model and prompt operating-model decision and lifecycle backlog. |
| Which portfolio decisions improve the next technical action? | [Portfolio evidence and roadmap](../s12-portfolio-governance/index.md) | Portfolio review, source lineage, priority trade-off, and baseline feedback. |

## Evidence and change boundary

The programme records customer-owned decisions and safe references; it does not
deploy a platform, run controls, store evidence payloads, or approve production
changes. Templates, samples, offline results, and reference architectures are
preparation aids, not proof of a production control.

## Continue with delivery planning

Read [Plan the engagement](plan-engagement.md) to prepare the first decision.
