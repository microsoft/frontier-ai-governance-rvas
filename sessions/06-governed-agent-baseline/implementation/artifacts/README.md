# Implementation artifacts

These files define one governed prompt agent.

```text
agents/policy-assistant/
  agent.json
  instructions.md
  tool-manifest.json
  prohibited-actions.json
operations/
  release-operations.json
```

`agent.json`, `prohibited-actions.json`, and `release-operations.json` are parsed as JSON by the
cross-platform scripts.

The OpenAPI specification intentionally contains one `GET` operation and a runtime-only server URL.
The API endpoint is supplied to preflight and deployment in the current shell; it is never written
to the repository. Do not add write methods, credentials, customer prompts, responses, trace
exports, or live Azure identifiers to this tree.
