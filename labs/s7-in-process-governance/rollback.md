# S7 Rollback

S7 is offline and does not deploy a tenant control, modify an agent, or call an
endpoint.

## Preserve the decision first

Keep the customer adoption decision, owner, and residual-risk notes in the
approved governance record. The generated audit illustration may be retained
with that record when useful.

## Remove generated local evidence

If the customer approves deletion of the local illustrative artifact after the
decision is retained, remove only the generated ignored file:

```bash
rm -f evidence/policy-decision-audit.json
```

No cloud, endpoint, code, credential, or tenant cleanup is required because S7
does not create or modify any of them.
