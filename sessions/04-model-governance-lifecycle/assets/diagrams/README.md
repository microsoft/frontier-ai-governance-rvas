# Session diagrams

`model-governance-flow.excalidraw` is the editable source for the model approval funnel and
lifecycle loop. `model-governance-flow.svg` is its generated publishing copy.

Edit the Excalidraw JSON by hand, render it, inspect the result, then regenerate the SVG. The
diagram uses only the palette defined by the Excalidraw diagram skill.

The diagram shows how workload purpose and processing location narrow into the selected deployment
plan. Preflight stops mismatches before Bicep changes a child deployment under the existing
`AIServices` resource. Review can keep the deployment, reopen approval for migration or
replacement, or retire the child deployment.
