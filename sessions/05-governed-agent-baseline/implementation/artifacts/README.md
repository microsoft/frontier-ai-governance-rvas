# Implementation artifacts

These files define one governed prompt agent.

```text
agents/policy-assistant/
  agent.json
  instructions.md
  tool-manifest.json
```

`agent.json` and `tool-manifest.json` are deployment inputs. `instructions.md` is part of the
prompt-agent version. Foundry retains the live agent version, endpoint selector, RAI policy, and
tracing connection; the scripts query that state instead of writing a release record.

The OpenAPI specification intentionally contains one `GET` operation and a runtime-only server URL.
The API endpoint is supplied to preflight and deployment in the current shell; it is never written
to the repository. Do not add write methods, credentials, customer prompts, responses, trace
exports, or live Azure identifiers to this tree.
