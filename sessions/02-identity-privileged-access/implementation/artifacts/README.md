# Implementation artifacts

The implementation includes these control definitions and operating records:

- group-based Foundry assignments in `identity/human-role-assignments.bicep`;
- a dedicated managed identity, two narrow roles, and one GitHub environment trust in
  `identity/workload-identity.bicep`;
- stable Azure role IDs in `identity/role-definitions.json`;
- the role and scope decisions in `identity/role-to-task-matrix.md`; and
- a customer change pointer in `pim/pim-change-reference.md`.

The implementation does not create a permanent platform-administrator assignment or automate shared
PIM settings. Microsoft Entra PIM and Azure RBAC enforce the live control.
