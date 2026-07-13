# S1 Rollback

This kit makes no tenant changes.

## Customer-owned policy changes
If the customer independently applies the reviewed report-only policy, its approved change process owns reversal and confirmation. The policy must remain report-only and preserve the break-glass exclusion until that process completes.

## Inventory & sponsor register
These are read-only exports/documents — nothing to revert in the tenant. Discard local evidence according to the customer's records policy.

The repository ignores live evidence output:
```bash
rm -f labs/s1-identity/evidence/*.json
```
