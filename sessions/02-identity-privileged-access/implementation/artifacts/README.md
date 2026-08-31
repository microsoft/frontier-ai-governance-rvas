# Implementation artifacts

The artifact set defines the identity control:

- group-based Foundry assignments in `identity/human-role-assignments.bicep`;
- a dedicated managed identity, two narrow role assignments, and one GitHub environment trust in
  `identity/workload-identity.bicep`; and
- stable Azure role IDs in `identity/role-definitions.json`.

The artifacts create no standing platform-administrator assignment and leave shared PIM settings
unchanged. Microsoft Entra PIM and Azure RBAC hold live access records. Keep approval and restore
details in the normal identity change process.
