# Implementation artifacts

Keep one production-shaped, syntactically valid artifact tree here. Each implementation file must supply
automation or policy, check live state, support an operational action, act as a downstream machine
contract, or record a customer decision that the platform cannot reconstruct. Name its consumer
and operational purpose in `session.yaml`; classify it and name its consumer in the implementation
document.

Merge, remove, or explicitly justify files that only mirror live Microsoft service state, restate
another file, or prove that repository files agree. The service remains authoritative unless the
repository intentionally owns desired state through a named deployment or reconciliation process.

Use explicit decision sentinels for customer values that preflight must resolve before deployment.
Do not add temporary resources solely to test the session result.
