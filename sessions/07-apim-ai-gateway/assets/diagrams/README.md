# Session diagrams

`apim-ai-gateway-flow.excalidraw` is the editable source for the ordered request pipeline.
`apim-ai-gateway-flow.svg` is its rendered form for the briefing deck and implementation guide.

The diagram follows the deployed order in `implementation/artifacts/gateway/policies/policy.xml`.
It also shows the backend pool and circuit breaker defined in
`implementation/artifacts/gateway/main.bicep`. Update the Excalidraw source first, then render the
SVG and inspect it before publishing.

Use the bundled Microsoft service icons without changing their color, crop, rotation, or aspect
ratio. Keep product names beside the icons.
