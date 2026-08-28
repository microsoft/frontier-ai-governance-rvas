# OBO implementation files

These files describe one organization-owned delegated trust chain:

- `control-definition.json` identifies the implementation boundary and implementationSession marker.
- `identity/app-registrations.json` defines the application roles and delegated permissions.
- `identity/key-vault-certificate-binding.json` records the certificate reference and runtime mount.
- `governance/authorization-matrix.md` assigns each authority to the correct actor.
- `governance/token-claim-contract.json` defines accepted inbound and downstream claims.
- `governance/threat-model.md` records the main token and consent abuse cases.
- `runtime/settings.json` configures the Python middle tier without storing credentials.
- `runtime/obo_proxy.py` validates the caller, performs OBO, and calls one fixed downstream route.
- `runtime/requirements.txt` pins the direct Python dependencies.

Resolve every `__REQUIRED_*__` value before configuration. Private keys, bearer tokens, tenant
values, endpoints, and user data stay outside this tree.
