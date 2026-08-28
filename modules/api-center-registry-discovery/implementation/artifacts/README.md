# Implementation artifacts

This module keeps these files after delivery.

- `registry-client-settings.json` gives a client-management pipeline or client-specific adapter the
  settings it needs. Microsoft Learn documents the registry endpoint and supported client
  categories, but no single configuration-file shape works across every client.
- `registry-ownership.json` records the global visibility decision, approved server names, owner
  roles, review date, and restore reference.

Resolve the `__REQUIRED_*__` values in the approved private configuration path. Do not add access
tokens, directory IDs, application IDs, runtime secrets, or server credentials to these files.
