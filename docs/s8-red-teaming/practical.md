# Practical activity: run an authorized non-production test

## What you will do

The customer security team runs an approved adversarial test against one
customer-owned non-production target and assigns the resulting finding.

## Before you start

- Confirm written authorization, rules of engagement, SOC notification,
  monitoring window, approved categories, stop conditions, and an endpoint
  owner who can pause or reset the target.
- The target must be customer-owned and non-production. Stop if any condition
  is absent, expires, or changes.
- The customer alone operates credentials, target access, test data, and its
  adapter.

## Customer-operated activity

1. Complete the pre-flight in `labs/s8-red-teaming/runbook.md`.
2. Inside the approved monitoring window, the customer runs the approved
   adapter with `labs/s8-red-teaming/scripts/redteam-airt.py`.
3. The customer retains the native scorecard in its approved evidence location,
   interprets the authorized scope, and chooses remediation, accepted risk,
   blocked, or re-test.

## What good looks like

The run has a valid authorization trail, an in-scope native result, and a named
owner for every material finding. It does not prove security outside the tested
scope.

## If the environment is not ready

Complete the authorization and readiness pre-flight only. Do not fabricate,
simulate, or infer an attack result.

## Keep and hand over

Keep native evidence in the customer system. Hand remediation or re-test work
to the customer security and non-production change process.
