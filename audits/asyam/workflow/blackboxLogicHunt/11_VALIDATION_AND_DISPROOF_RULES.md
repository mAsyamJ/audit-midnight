# Validation and Disproof Rules

Date: 2026-05-31

| PoC | Proof condition | Disproof condition | Downgrade / duplicate / intended condition | Exact assertion and trace evidence |
|---|---|---|---|---|
| BB-POC-001 | Accepted material overclaim or freeze from stale state | Sync-before-use or atomic revert | One-wei difference or direct pending-fee duplicate | Compare stored/effective/paid; save trace |
| BB-POC-002 | Socialized debt exceeds economically unrecoverable debt | Bound holds after every sequence | Zero-oracle or optimistic-bad-debt duplicate | Assert slash delta `<=` unrecoverable bound |
| BB-POC-003 | Valid bounded route causes unbounded economic side effect | All explicit args hold and rollback atomic | Voluntary broad authorization | Snapshot spend, proceeds, debt, collateral, residual |
| BB-POC-004 | Stale or unrelated intent moves assets without current capability | Nonce/current auth blocks action | Voluntary delegate effect or L-16 duplicate | Assert unrelated balances unchanged |
| BB-POC-005 | Successful route exceeds call bounds after quote transition | Bounded result or atomic revert | Stale quote DoS only / L-13 duplicate | Assert max/min args and router residue |
| BB-POC-006 | Valid claim starves another valid same-token liability | Custody covers aggregate liabilities under all orderings | Formal invariant confirmed | Assert balance `>= sum(withdrawable)+claimableFee` |
| BB-POC-007 | User enters bad market without selection, signature, or capability edge | Route rejects market or auth explains it | Chosen market risk | Assert market-consent edge |
| BB-POC-008 | Bounded dust cycle flips non-dust branch or extracts value | Only bounded residue | Audited rounding corpus | Assert material threshold and net profit |
| BB-POC-009 | Event replay misses actionable state | Replay diverges before economically necessary reaction | Cosmetic or P3 only | Compare replay mirror and storage |
| BB-POC-010 | Lazy lender subset plus claim order creates deficit | Backing holds modulo dust | Existing composition duplicate | Assert aggregate paid and custody |
| BB-POC-011 | Attacker-controlled one wei threshold causes victim loss | Intended threshold policy only | Parameter choice risk | Compare neighboring outcomes |
| BB-POC-012 | Liquidation choice creates avoidable excess slash | Each path bounded by recoverability | Documented preference | Compare order social loss |
| BB-POC-013 | Relayer can intentionally strand borrower collateral outside scope | Only caller-selected fee behavior | User error | Debt and collateral exit assertions |
| BB-POC-014 | Reverting seventeenth supply strands prior funds | Full rollback | Self-DoS | Snapshot all balances/storage |
| BB-POC-015 | Route increases debt after maturity | Core rejects or skips leg | Audited maturity edge if same root | Assert debt delta zero after maturity |
| BB-POC-016 | Mixed family cap harms non-consenting actor | Maker-only configuration effect | Docs warn same family | Assert affected actor consent |
| BB-POC-017 | Third-party touch changes value beyond accrued economics | Effective view equals touched state | Intended crystallization | Assert view/state identity |
| BB-POC-018 | Bitmap bit diverges from nonzero balances | Iff property holds | Direct bitmap duplicate | Iterate bits and balances |
| BB-POC-019 | Token reused as collateral creates aggregate deficit | Full aggregate backing holds | Standard-token model confirmed | Include collateral custody in liability sum |
| BB-POC-020 | Events cannot distinguish consent tuple or persistent state | Replay reconstructs state | Cosmetic only | Hash replayed tuple and storage |

## Severity Gate

- **High:** realistic actor can trigger meaningful fund loss, freeze, or systemic accounting corruption.
- **Medium:** bounded but reliable non-dust loss, meaningful freeze, or liveness-to-loss path for a non-consenting user.
- **Low:** admin-only, user-error-only, chosen-market-only, weird-token-only, dust-only, or self-DoS.
- **Invalid:** intended behavior, prior acknowledged issue, duplicate root cause, or no non-consenting affected party.

Every promoted trace must record setup, exact state deltas, attacker net flow, victim net flow, custody, liabilities, and
the dedup comparison.
