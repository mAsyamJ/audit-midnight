# 03 Dedup Map

Date: 2026-05-30

This map is the gate before PoC work. Candidates matching Spearbit or Blackthorn are duplicate/known unless a PoC proves a materially different root cause, path, or impact in current code.

## Spearbit Known Issues

| Severity | Title | Dedup keywords |
|---|---|---|
| Medium | Zero Oracle Prices are allowed | zero oracle, zero price, liquidation division, bad debt from zero price |
| Medium | Obligation can be created before default fees are set for a loan token | default fee initialization, market creation race, fee defaults |
| Low | Deltas of pending fee for buyer, seller and position updates round in the wrong direction | pending fee rounding, continuous fee dust |
| Low | Input validation is missing for offer.obligation.maturity | maturity validation, too-far maturity |
| Low | Enforce stricter trading fee rounding | settlement/trading fee rounding |
| Low | During liquidation explicit check is missing to ensure collateralIndex is one the activated collaterals | liquidation inactive collateral, phantom collateral |
| Low | When lossIndex is at its max withdrawal would not be possible but other endpoints can be called | terminal loss factor/loss index |
| Low | Foreign ratifiers can import delegated signer authority from another Midnight instance | foreign ratifier, delegated signer scope |
| Low | ApprovalRatifier approvals can replay across Midnight deployments | ratifier replay, approval replay, deployment replay |
| Low | Calls to take() can be forced to revert via front-running | fill front-run, consumed grief |
| Low | Continuous fee calculation could round down to zero for tokens with small decimals | low decimal token, continuous fee zero |
| Low | Obligation accounting breaks in the event of a hardfork | chain fork, obligation id, market id |
| Gas | Verification and potential optimisation of countBits implementation | countBits gas |
| Informational | Minor issues (typos, comments, ...) | docs, formatting, typos |
| Informational | A phantom collateral can block liquidations | phantom collateral, malicious collateral activation |
| Informational | In the presence of liquidity the lenders and the feeClaimer can avoid their credits getting slashed | loss avoidance, fee claimer slash timing |
| Informational | clz opcode is not supported on all almost EVM-compatible chains | CLZ, Osaka compatibility |
| Informational | Trust assumptions for buyerCallback | buyer callback trust |
| Informational | Loss index inflation | loss factor inflation |

## Blackthorn Known Issues

| ID | Title | Current-code note |
|---|---|---|
| M-1 | In `lossIndex == type(uint128).max` state a fresh lender principal can be slashed to zero on entry | Duplicate for terminal loss-factor/fresh lender slash |
| M-2 | `take()` does not control near-maturity fills, allowing unconsented seller debt and post-maturity collateral seizure | Duplicate for maturity-edge forced debt |
| L-1 | Chain fork changes all obligation Ids, making them unreachable | Duplicate for hardfork id path |
| L-2 | `testReturnJumps` asserts the wrong ratio direction | Duplicate for that test issue |
| L-3 | Midnight constructor can use msg.sender instead of reading roleSetter from storage | Current constructor already uses `msg.sender` |
| L-4 | `LLTV_8 = WAD` eliminates post-maturity liquidation incentive | Duplicate |
| L-5 | Grouped offers can exceed a maker's intended shared liquidity cap | Duplicate for grouped cap/rounding overfill |
| L-6 | Mismatched obligation ids in `TakeAmountsLib` can cause incorrect calculation | Duplicate/fixed check needed for helper/core id mismatch |
| L-7 | Inconsistent behavior between `TakeAmountLib` helper and core settlement | Duplicate for helper/core divergence |
| L-8 | Values returned by helpers might unexpectedly trigger gates | Duplicate for helper/gate interaction |
| L-9 | Pending fee can be reduced by repeated self-transfer | Duplicate for self-transfer/rounding fee dust |
| L-10 | Side-effect of "optimistic" bad debt socialization | Duplicate for zero-cost/optimistic bad debt |
| L-11 | Transfer's comments improvement | Duplicate docs |
| L-12 | Potential overflow due to checked multiplications through `mulDivDown`/`mulDivUp` | Duplicate math overflow |
| L-13 | Existing fillable orders might break after updating the trading fee | Duplicate fee staleness/fillability |
| L-14 | Initiator address is not passed into the `onFlashLoan()` function | Duplicate/fixed check around callback context |
| L-15 | Incumbent lenders are involuntarily rolled from realized cash back into fresh borrower risk | Duplicate |
| L-16 | Excessive privilege granted to ratifier | Duplicate delegated authority scope |
| L-17 | Risk of being unable to or delaying in disabling compromised operator addresses | Duplicate operator revocation delay |
| L-18 | Zero amount liquidate won't work if underlying doesn't support zero amount transfer | Duplicate zero transfer / weird ERC20 |
| L-19 | Absence of actor binding lets attackers drain third-party callback funds across maker-buyer, taker-buyer, and seller orders | Duplicate for callback actor binding |
| L-20 | Zero-unit `take()` can replay callbacks and emit zero-value Take events | Duplicate zero-unit callback replay |
| L-21 | Fee slippage and stale credit documentation | Duplicate docs/slippage/stale views |
| L-22 | `midnight` parameter in `MidnightBundles` could be set in the constructor | Current code has immutable `MIDNIGHT`; fixed/known |
| L-23 | `proof.length` can be used instead of `height` in `EcrecoverRatifier.isRatified` | Current code uses `proof.length`; fixed/known |
| L-24 | `TickLib.tickToPrice(0) = 0` is an unguarded state | Duplicate/acknowledged |
| L-25 | Receiver and transaction initiator addresses not passed into `onLiquidate()` | Current callback signature includes caller and receiver; fixed/known |
| L-26 | Liquidator callbacks cannot gate exposure, so extra allowance can be exploited | Duplicate for callback-before-pull allowance exposure |

## High Duplicate-Risk Buckets

- zero oracle prices
- default fee initialization
- fee rounding / continuous fee dust
- maturity-edge forced debt
- grouped offer cap overfill
- terminal loss factor / lossIndex slash behavior
- obligation id hardfork/replay
- ratifier delegated authority scope
- callback actor-binding / zero-unit callback replay
- liquidation bad debt socialization
- helper/core `TakeAmountsLib` mismatch
- tick zero price
- fee staleness / stale credit documentation

## Hashlock Treatment

Hashlock reports are not dedup proof of audited issues, but they are hypothesis queues. If a Hashlock claim also matches Spearbit/Blackthorn, treat it as duplicate-risk first. If it does not, require a local PoC before promoting it.

## Surviving Research Themes

1. Callback reentrancy or callback composition that is materially different from Blackthorn L-19/L-20/L-26.
2. Periphery temporary-balance leakage that does not rely only on out-of-scope malicious token behavior.
3. Exact-fill helper/core divergence in current code, after excluding Blackthorn L-6/L-7/L-8 and current tests.
4. Permit2/ERC2612 context misuse with real third-party impact.
5. Event/state reconstruction gaps worth P3 reporting.
6. Same-asset loan/collateral behavior if it breaks an invariant rather than reflecting market choice.
7. CVL model summaries that collapse production-distinct states or silently prune supported compositions.
