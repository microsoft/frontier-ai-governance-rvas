# Implementation artifacts

The implementation includes these control definitions:

- group-based Foundry assignments in `identity/human-role-assignments.bicep`;
- a dedicated managed identity, two narrow roles, and one GitHub environment trust in
  `identity/workload-identity.bicep`; and
- stable Azure role IDs in `identity/role-definitions.json`.

The implementation does not create a permanent platform-administrator assignment or automate shared
PIM settings. Microsoft Entra PIM and Azure RBAC hold the live control, and the normal identity
change process holds its approval and restore details.
