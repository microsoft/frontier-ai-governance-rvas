# Implementation artifacts

`onboarding-decision.json` holds the decisions Microsoft Agent 365 does not store: the selected
onboarding route, the runtime-owned source reference, the owner roles, the connected-platform
credential decision, and the cross-platform retirement plan. Both preflight scripts read it.

Microsoft Agent 365 stays authoritative for the live inventory record. The runtime owner stays
authoritative for the agent definition and its source.

Never put a connection credential, key, secret, token, or exported agent metadata in this folder.
Record where the credential lives and who rotates it, not the credential itself.
