# Implementation artifacts

These artifacts define this control:

- group-based Foundry assignments in `identity/human-role-assignments.bicep`;
- a dedicated managed identity, two narrow role assignments, and one GitHub environment trust in
  `identity/workload-identity.bicep`; and
- stable Azure role IDs in `identity/role-definitions.json`.

The artifacts do not create a permanent platform-administrator assignment or change shared PIM
settings. Microsoft Entra PIM and Azure RBAC hold the live control. Keep approval and restore
details in the normal identity change process.
