# Contributing

Contributions and suggestions are welcome. Most contributions require a
[Contributor License Agreement](https://cla.microsoft.com). When you open a
pull request, the CLA bot tells you whether action is needed.

This project follows the [Microsoft Open Source Code of
Conduct](https://opensource.microsoft.com/codeofconduct/). For more
information, see the [Code of Conduct
FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com).

## What belongs here

This repository contains an AI-governance curriculum, delivery guidance, and
offline lab kits. It does not store customer data, credentials, tenant
configuration, logs, exports, screenshots, or evidence payloads.

Keep changes within the repository's boundaries:

- `docs/` contains the published curriculum, delivery guidance, and reference
  material.
- `labs/` contains session work packages, templates, and shared offline helpers.
- `contracts/` contains shared JSON schemas.
- `diagrams/` contains source diagrams and their generated assets.

## Write clearly

Lead with the action or decision the reader needs to make. Use plain language
where it is accurate, and define an acronym the first time it appears. Keep
technical terms when they name a product, control, or specific process.

Do not use a template, sample, or offline result as proof that a customer
control is deployed or operating. State who performs an action, who owns the
decision, and what evidence supports it. Preserve the distinction between
report-only review, non-production work, and customer-approved production
changes.

Use bold only for a defined term, an explicit action or decision, or a short
warning. Do not use it for decoration.

## Update related material

When you change a session, check its related content:

1. Update the session pages in `docs/s*-*/` and any linked lab kit in
   `labs/s*-*/`.
2. Update templates, contracts, diagrams, and reference guidance when the
   change affects them.
3. Do not edit generated files in `docs/assets/data/`. Run `npm run build` to
   regenerate them.

## Before opening a pull request

Run `npm run build`. Check links, terminology, and the stated safety boundary.
For product claims, use an official source and avoid implying feature
availability, customer deployment, or approval that the evidence does not
establish.
