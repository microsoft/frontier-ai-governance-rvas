# OBO authorization matrix

| Actor | Presents | Audience | Required authority | Must not receive |
| --- | --- | --- | --- | --- |
| Approved client | User-delegated access token | Middle tier | `access_as_user` | Downstream certificate or application permission |
| Python middle tier | Validated user assertion plus certificate authentication | Microsoft Entra token endpoint | Downstream delegated `Policy.Read` permission | A broad application permission used as fallback |
| Microsoft Entra ID | Downstream delegated access token | Protected downstream API | Consent granted by the identity owner listed in the control definition | Permission beyond the approved scope |
| Downstream API | User and delegated scope claims | Its own API audience | Resource authorization for that user | The original inbound bearer token |
| Operations team | Correlation and error metadata | Approved telemetry store | Diagnostic read access | User assertions, access tokens, or response payloads |

The downstream API makes the final resource decision. A successful token exchange does not prove
that the user may read the requested resource.
