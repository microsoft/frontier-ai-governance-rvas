# PIM customer-system reference

| Field | Customer-system reference |
|---|---|
| PIM change or decision | `__REQUIRED_PIM_CHANGE_REFERENCE__` |
| Identity owner | `__REQUIRED_PIM_OWNER__` |
| Eligible principal | `__REQUIRED_PLATFORM_ADMINISTRATOR_GROUP_REFERENCE__` |

Microsoft Entra PIM is authoritative for eligibility, activation duration, MFA, justification,
approval, expiry, notifications, and role settings. The customer identity system holds the change
decision and restore owner. Do not mirror that live state in this repository.
