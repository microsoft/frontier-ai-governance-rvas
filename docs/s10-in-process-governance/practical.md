# Do this

**Customer owner:** Engineering owner. **Timebox:** 20 minutes. Use a fictional
or sanitized tool call; do not use customer code, credentials, endpoints, or
tenant data.

1. Record one tool-call reference, delegated authority, existing gateway
   control, policy owner, evidence owner, and review target date.
2. Choose gateway-only, in-process, both, or not applicable. The Microsoft
   default is gateway-only; an exception needs a real pre-tool decision that
   gateway control cannot make.
3. Run `python labs/s10-in-process-governance/pipelines/run_mock.py` and verify
   its local record. This is an offline illustration, not AGT or production
   evidence.
4. Complete the technical decision record with decision result
   (approve/defer/reject/route), acceptance evidence, and explicit handoff to
   S6, S9, and S11 as applicable.

**Acceptance:** the record names owner, evidence reference and limit, boundary
choice, target date, and next route. No customer-system change is made.
