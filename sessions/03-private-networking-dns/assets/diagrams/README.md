# Session 03 diagrams

The `.excalidraw` files are the authoritative, editable sources:

- `private-network-flow.excalidraw` maps the approved client, DNS, private endpoints, dedicated
  Agent subnet, firewall route, five services, and denied public paths.
- `public-access-cutover.excalidraw` shows the checks and stored restore state that must exist
  before public access is disabled.

The matching `.svg` files are portable renders used by the implementation guide and deck. Regenerate
an SVG from its Excalidraw source after any diagram change.

The diagrams use the endpoint aliases, required FQDN placeholders, DNS zones, and state fields from
the Session 03 artifacts. They contain no customer topology, addresses, or identifiers.
