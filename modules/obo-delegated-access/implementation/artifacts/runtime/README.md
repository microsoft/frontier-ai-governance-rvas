# Python OBO middle tier

`obo_proxy.py` is a deployable reference component for an existing protected application host. It
validates a user-delegated token, uses MSAL with the mounted PFX to perform OBO, then calls the
configured HTTPS endpoint.

Deploy it through the approved application pipeline. Resolve `settings.json` outside the public
repository and set `OBO_SETTINGS_PATH` to that protected copy. Install the pinned dependencies from
`requirements.txt`.

The component returns status and correlation metadata only. Extend the downstream response model
inside the owning application after its data classification and output contract are approved.
