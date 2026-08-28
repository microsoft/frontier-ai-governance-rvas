# Implementation artifacts

This module keeps two files after delivery.

- `registry-client-settings.json` is the machine contract for a client-management pipeline or
  client-specific adapter. Microsoft Learn documents the registry endpoint and supported client
  categories, but it does not define one configuration-file shape that works across every client.
- `registry-ownership.json` is the operating record for the global visibility decision, approved
  server names, owner roles, review date, and restore reference.

Resolve the `__REQUIRED_*__` values in the approved private configuration path. Do not add access
tokens, directory IDs, application IDs, runtime secrets, or server credentials to these files.
