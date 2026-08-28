# Implementation artifacts

These artifacts define the control:

- group-based Foundry assignments in `identity/human-role-assignments.bicep`;
- a dedicated managed identity, two narrow roles, and one GitHub environment trust in
  `identity/workload-identity.bicep`; and
- stable Azure role IDs in `identity/role-definitions.json`.

The artifacts do not create a permanent platform-administrator assignment or automate shared PIM
settings. Microsoft Entra PIM and Azure RBAC hold the live control. The normal identity change
process holds approval and restore details.
