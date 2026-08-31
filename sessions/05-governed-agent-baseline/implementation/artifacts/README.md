# Implementation artifacts

This artifact set defines the prompt agent used in this session.

```text
agents/policy-assistant/
  agent.json
  instructions.md
  tool-manifest.json
```

`agent.json` and `tool-manifest.json` are deployment inputs. `instructions.md` is part of the
prompt-agent version. Foundry holds the agent version, endpoint selector, RAI policy, and tracing
connection. The scripts inspect those resources.

The OpenAPI specification contains the approved `GET` operation and a runtime-only server URL.
The current shell supplies the API endpoint to preflight and deployment. Keep write methods,
credentials, customer prompts, responses, trace exports, and live Azure identifiers out of this tree.
