# Review Scope

Date: 2026-05-31

## Authorized Scope

This is an authorized local-only Cantina review for Morpho Midnight. Evidence
comes from repository source, protocol-authored tests, local audit PoCs,
Certora specifications, protocol-intent notes, and the local audited corpus.
No live contracts or external systems were queried.

## Severity Discipline

- High or Medium requires realistic, non-dust user or protocol loss, frozen
  funds, or systemic accounting corruption.
- Low is appropriate for a bounded protocol defect without a material loss
  path.
- Gas / Informational is appropriate for repairable stale-transaction grief,
  operational footguns, and assurance gaps.
- A duplicate, intended behavior, user-error-only path, admin-only path,
  weird-token-only path, consenting-malicious-market path, dust-only path, or
  revert-only hypothesis is not promoted.

## Evidence Hierarchy

1. Compiling Foundry PoC with concrete impact.
2. Current `src/` and protocol-authored tests.
3. `workflow/protocolIntent/` as the economic-intent model.
4. `workflow/03_DEDUP_MAP.md` and `audited/*.json` as prior-finding corpus.
5. Hashlock material as untrusted hypothesis input only.
6. Planning backlogs as archived research queues only.

## Closed Runtime Escalations

The local campaigns closed callback extraction, temporary bundle balance
leakage, grouped-cap bypass, reduce-only bypass, exact-fill mismatch, same-token
custody drain, flash repayment bypass, liquidation over-seize, solvent bad-debt
realization, loss-factor over-slash, pending-fee desync, root reuse, forced gate
debt, cross-market custody drain, self-liquidation callback extraction, and
quote fallback compositions.

## Final Gate

The recommended manual submission pack contains L-01 and P3-02 only. P3-01 and
L-02 remain available for human judgment but are not marked submit-ready.
L-03 is archived as intended RCF policy behavior.

