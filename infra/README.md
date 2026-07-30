# Infrastructure skeletons

This area groups infrastructure-as-code skeletons for implementation labs.
Assets here should be safe, parameterized, and non-production by default.

Use subfolders for the IaC language or deployment surface:

- `bicep/` for Azure Bicep skeletons.
- `terraform/` for Terraform skeletons.

Do not commit customer-specific subscription IDs, tenant IDs, resource names,
private endpoint values, secrets, or deployment outputs.
