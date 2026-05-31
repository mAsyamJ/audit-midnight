# Intended Behaviors (Not Bugs)

Date: 2026-05-30

Use this file to **reject false positives** before writing PoCs or Cantina submissions.

Format: **Why not a finding** | **When it could escalate** | **PoC required to escalate**

---

## Permissionless market creation

- **Why:** Core design (README, whitepaper); anyone can `touchMarket`.
- **Escalate:** If two distinct configs collide on `toId` in production — would be critical (not observed; distinct IDs use full `Market` encode).
- **PoC:** Demonstrate ID collision in `IdLib.toId`.

## Market creator chooses bad oracle / gate

- **Why:** Consenting participants accept market params.
- **Escalate:** Non-consenting victim forced to trade on that market.
- **PoC:** Show victim loss without opting into market.

## Maker voluntarily authorizes delegate

- **Why:** `setIsAuthorized` semantics; Spearbit/Blackthorn L-16.
- **Escalate:** Unauthorized third party gains powers without maker action.
- **PoC:** Bypass authorization check.

## User passes bad receiver / referral address

- **Why:** User-supplied addresses; self-DoS or lost refund.
- **Escalate:** Third-party funds drained without user signature on that path.
- **PoC:** Drain unrelated account.

## Route failure due to stale off-chain quote

- **Why:** Slippage / quote risk; bundler reverts or skips per docs.
- **Escalate:** Documented min-fill guarantee violated.
- **PoC:** Show guaranteed fill failed silently.

## Dust rounding

- **Why:** mulDiv wei imprecision; Certora bounded.
- **Escalate:** Cap bypass or Medium fund loss at scale.
- **PoC:** Accumulate to meaningful theft.

## Admin-only actions

- **Why:** `OnlyRoleSetter`, `OnlyFeeSetter`, etc.
- **Escalate:** External attacker triggers admin footgun.
- **PoC:** P3-01 style — proven Low footgun only.

## Weird ERC20 (fee-on-transfer, hooks)

- **Why:** Core assumes exact non-reentrant tokens (comments, Certora).
- **Escalate:** Competition explicitly in scope + production path with normal callback.
- **PoC:** Reentrant drain without malicious token.

## Already audited Spearbit / Blackthorn items

- **Why:** [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md).
- **Escalate:** Materially new root cause in **current** code.
- **PoC:** Required for any resubmission.

## Hashlock AI claims — closed in this audit

| Claim | Closure |
|---|---|
| High-02 bundler balance theft | **Disproven** C-26 |
| Medium-01 referral underflow | **Invalid** C-29 |
| High-01 ERC777 reentrancy | Parked — token assumption |
| Take callback reentrancy | **Disproven** C-14 |
| Grouped cap overfill | **Duplicate** C-05 |
| reduceOnly bypass | **Disproven** C-12 |
| Same loan/collateral | **Disproven** C-31 |

## Interface-only claims

- **Why:** No implementation impact.
- **Escalate:** Reachable state corruption in `Midnight.sol`.
- **PoC:** State diff proof.

## P3-02 CVL market-ID aliasing (formal assurance gap)

- **Why:** Proven mismatch between `CVL_toId` / `equalsGlobalMarket` and production `IdLib.toId` — **no production fund-loss exploit claimed**.
- **Escalate:** Production code uses CVL summary for runtime decisions (it does not).
- **PoC:** `PoC_SolvencySpecMarketIdAliasing.t.sol` — formal verification limitation only.

## Proven findings (do not re-file as new)

- **L-01** signature malleability (Low)
- **P3-01** roleSetter zero brick (Low)
- **P3-02** CVL ID aliasing (formal/P3)

## Certora callback nondeterminism

- **Why:** Proofs abstract callbacks; not a production bug.
- **Escalate:** Reentrant take composition breaks solvency — needs Foundry PoC (C-14 closed).

## Optimistic bad debt / zero-repay liquidation

- **Why:** Documented design; Blackthorn L-10 / Spearbit zero oracle — duplicate-risk.
- **Escalate:** Solvent borrower slashed without oracle grief.
- **PoC:** Distinct from known oracle issues.

## Cross-links

- [14_PROTOCOL_INTENT_TO_POC_TARGETS.md](14_PROTOCOL_INTENT_TO_POC_TARGETS.md) — open targets only
- [../../findings/findings.md](../../findings/findings.md)
