# Implementation artifacts

These files define the governed prompt agent.

```text
agents/policy-assistant/
  agent.json
  instructions.md
  tool-manifest.json
```

`agent.json` and `tool-manifest.json` are deployment inputs. `instructions.md` is part of the
prompt-agent version. Foundry holds the live agent version, endpoint selector, RAI policy, and
tracing connection. The scripts read that state instead of writing a release record.

The OpenAPI specification contains the approved `GET` operation and a runtime-only server URL.
The current shell supplies the API endpoint to preflight and deployment. Do not write it to the
repository. Keep write methods, credentials, customer prompts, responses, trace exports, and live
Azure identifiers out of this tree.
