# Implementation artifacts

Keep one production-shaped, syntactically valid artifact tree here. Each implementation file must
supply automation or policy, check live state, support an operational action, act as a downstream
machine contract, or record a customer decision that the platform cannot reconstruct. Name its
consumer and operational purpose in `session.yaml`. Classify it and name its consumer in the
implementation document.

Merge, remove, or justify files that mirror live Microsoft service state, restate another file, or
only prove that repository files agree. The service is authoritative unless a named deployment or
reconciliation process makes the repository the owner of the target state.

Use explicit decision sentinels for customer values that preflight must resolve before deployment.
Do not create temporary resources just to test the session result.
