# Duplicate and Scope Filter

Date: 2026-05-31

Compared against:

- `audits/asyam/audited/2026-04-07-spearbit-DRAFT_Audited_NAME.json`
- `audits/asyam/audited/2026-05-21-blackthorn-DRAFT_Audited_NAME.json`
- `audits/asyam/workflow/03_DEDUP_MAP.md`
- `audits/asyam/workflow/protocolIntent/11_INTENDED_BEHAVIORS_NOT_BUGS.md`
- `audits/asyam/workflow/02_HASHLOCK_VALIDATION.md`

## L-01 - ECDSA high-s signature malleability

- Potential duplicate source: Hashlock L-01 hypothesis only.
- Similarity: Exact hypothesis, but the local Foundry PoC independently proves
  both authorizer and ratifier paths in current code.
- Root cause same?: Yes, relative to Hashlock hypothesis.
- Code path same?: Yes.
- Impact same?: Local packet narrows the impact to canonicality and integration
  risk.
- Recommendation same?: Local packet includes concrete low-s enforcement.
- Scope risk: Low.
- Final duplicate decision: `SUBMIT_LOW`. No matching accepted Spearbit or
  Blackthorn item was found in the local audited corpus.

## P3-02 - CVL market-ID summary aliasing

- Potential duplicate source: None found in local audited corpus.
- Similarity: N/A.
- Root cause same?: No prior corpus root cause found.
- Code path same?: Formal model only.
- Impact same?: N/A.
- Recommendation same?: N/A.
- Scope risk: Informational-only because production IDs are distinct.
- Final duplicate decision: `SUBMIT_INFORMATIONAL`.

## P3-01 - `roleSetter` zero-address bricking

- Potential duplicate source: None found in local audited corpus.
- Similarity: Common one-step admin-transfer footgun class.
- Root cause same?: No local accepted duplicate found.
- Code path same?: N/A.
- Impact same?: Administrative role rotation is permanently disabled.
- Recommendation same?: Standard zero-address rejection / two-step transfer.
- Scope risk: High. Only the current role setter can trigger it.
- Final duplicate decision: `HOLD_WEAK_ADMIN_ONLY`.

## L-02 - Tiny repayment liquidation gas grief

- Potential duplicate source: Spearbit "`take()` calls can be forced to revert
  via front-running".
- Similarity: Both invalidate a pending exact-input transaction with a cheap
  state change.
- Root cause same?: Adjacent but not identical. L-02 is
  `repay(1 wei) -> stale liquidate(repaidUnits)`.
- Code path same?: No.
- Impact same?: Yes: repairable stale-transaction gas grief.
- Recommendation same?: Operational refresh / slippage handling.
- Scope risk: High duplicate-risk and weak practical impact.
- Final duplicate decision:
  `MAYBE_DUPLICATE_DO_NOT_SUBMIT_UNLESS_REVIEWED`.

## L-03 - RCF top-up liquidation gas grief

- Potential duplicate source: Spearbit RCF appendix and generic liquidation
  quote front-running.
- Similarity: The RCF boundary is documented policy behavior.
- Root cause same?: The observed transition is the intended branch condition.
- Code path same?: RCF liquidation guard.
- Impact same?: Repairable stale transaction only.
- Recommendation same?: Liquidator refresh / helper documentation.
- Scope risk: Intended behavior.
- Final duplicate decision: `DO_NOT_SUBMIT_INTENDED`.

