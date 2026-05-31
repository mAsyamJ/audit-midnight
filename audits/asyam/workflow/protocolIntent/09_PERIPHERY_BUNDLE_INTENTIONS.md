# Periphery Bundle Intentions

Date: 2026-05-30

## Why MidnightBundles exists

UX router over immutable `MIDNIGHT` core: multi-offer fills, collateral supply/withdraw, repay, Permit2/ERC2612, referral fees—**without** changing core accounting rules.

## Units-target vs assets-target

| Mode | User specifies | Lib helpers |
|---|---|---|
| Units target | Exact units to fill | `TakeAmountsLib`, `ConsumableUnitsLib` |
| Assets target | Exact loan-token budget | Inverse math; may revert if unreachable |

Helpers run **before** core `take` in try/catch paths where documented.

## Key flows

- **buyWithUnitsTargetAndWithdrawCollateral** — `maxBuyerAssets` is **total** buyer budget including referral (NatSpec).
- **supplyCollateralAndSellWithUnitsTarget** — sell legs; proceeds park temporarily on router.
- **repayAndWithdrawCollateral** — repay debt + pull collateral.
- **Permit2 / ERC2612** — pull to router; `pullToken` uses `from = msg.sender`.

## Referral fee semantics

- Paid from router after fills; reduces refund to user.
- **INTENDED:** `filledBuyerAssets + referralFee ≤ maxBuyerAssets`.
- Under-budget by 1 wei reverts atomically (C-29 **invalid**).

## Failed take skipping

- Documented: some routes skip failing legs in try/catch.
- **INTENDED** if documented; **BUG** if min-fill guarantees violated.

## exact target fill / forceApproveMax / refunds

- Router refunds excess loan tokens to `msg.sender` after exact pulls.
- `forceApproveMax` — approve type(uint256).max for efficiency.

## Temporary token balance risk

- Router holds loan/collateral between steps.
- **INTENDED:** transfers use **computed** amounts per call, not `balanceOf(router)` sweep.
- **Closed disproven:** C-26 — `PoC_BundleTemporaryBalanceReentrancy.t.sol`, `Validation_LiveQueues.t.sol`.
- **Residual:** malicious token hooks out of standard-token assumption.

## Intended vs bug

| Behavior | Classification |
|---|---|
| Failed takes skipped (documented) | INTENDED |
| Helper revert before try/catch | UX/DoS — Low unless third-party loss |
| User zero receiver | User error |
| Referral reduces repayment (documented) | INTENDED / UX |
| Cross-call balance leakage | BREAK if proven |
| Exact target impossible (realistic liquidity) | REQUIRES POC |
| Mixed markets in one bundle | **Invalid** — `InconsistentMarket` |
| Empty `takes[]` | Self-DoS revert |

## PoC target section

| Target | Status |
|---|---|
| Temporary balance leakage | **Closed disproven** |
| Exact equality rounding | Partially covered; Blackthorn L-6/L-7 duplicate-risk |
| Pre-try/catch route DoS | REQUIRES POC |
| Referral underflow | **Closed invalid** |
| Permit2 misuse | **Closed invalid** per test intent map |
| Mixed-market route | **Closed invalid** |
| Empty takes | Self-DoS |

## Cross-links

- [03_ASSET_AND_VALUE_FLOW.md](03_ASSET_AND_VALUE_FLOW.md)
- [../04_PROTOCOL_TEST_INTENT_MAP.md](../04_PROTOCOL_TEST_INTENT_MAP.md)
