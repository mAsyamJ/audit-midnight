# Disproof and False Positive Filter

Date: 2026-05-30

Use before investing PoC time. See also [../protocolIntent/11_INTENDED_BEHAVIORS_NOT_BUGS.md](../protocolIntent/11_INTENDED_BEHAVIORS_NOT_BUGS.md).

## Triage checklist

- [ ] Dedup keywords in [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md)?
- [ ] Listed in [../POC_RESULTS.md](../POC_RESULTS.md) as disproven/invalid?
- [ ] Contradicts [../protocolIntent/00_PROTOCOL_INTENTION_SUMMARY.md](../protocolIntent/00_PROTOCOL_INTENTION_SUMMARY.md)?
- [ ] Requires malicious ERC20 hook without competition scope?
- [ ] User-chosen bad address only?
- [ ] Admin footgun without external attacker?
- [ ] Dust-only without cap impact?

## Closed attack classes

| Attack class | Verdict | Evidence |
|---|---|---|
| Bundler balance theft | disproven | `PoC_BundleTemporaryBalanceReentrancy.t.sol` |
| Take callback accounting profit | disproven | `PoC_TakeCallbackReentrancy.t.sol` |
| Referral underflow / budget | invalid | `PoC_DeepValidationQueues.t.sol`, C-29 |
| Grouped cap overfill | duplicate/disproven | `PoC_OfferConsumedCapRounding.t.sol` |
| reduceOnly bypass | disproven | `Validation_LiveQueues.t.sol` |
| Same loan/collateral insolvency | disproven | C-31 regressions |
| Flash loan callback reentrancy profit | disproven | `PoC_FlashLoanReentrancy.t.sol` (AP-019, MC-04) |
| Liquidation over-seize | disproven | `PoC_LiquidationOverSeize.t.sol` (AP-005) |
| Post-maturity liquidation divergence | disproven | `PoC_PostMaturityLiquidation.t.sol` (AP-006) |
| Canceled Merkle root reuse | disproven | `PoC_CanceledRootReuse.t.sol` (AP-011) |
| Liquidate callback reentrancy profit | disproven | `PoC_LiquidateCallbackReentrancy.t.sol` (AP-026 slice) |
| lossFactor over-slash lenders | disproven/covered | `PoC_LossFactorOverslash.t.sol` (AP-008) |
| pendingFee / lossFactor desync | duplicate/covered | `PoC_PendingFeeLossFactorSync.t.sol` (AP-010) |
| Solvent borrower bad debt | disproven | `PoC_LiquidationSolventBadDebt.t.sol` (AP-004) |
| Bundle exact-fill / TakeAmountsLib drift | disproven/covered | `PoC_BundleExactFillAlignment.t.sol` (AP-015) |
| Enter gate forced debt | disproven | `PoC_EnterGateForcedDebt.t.sol` (AP-018) |
| Bundle helper revert vs take skip | invalid (documented) | `PoC_BundleHelperRevertSemantics.t.sol` (AP-016) |
| Sell-callback liquidate/flash composition | disproven | `PoC_SellCallbackComposition.t.sol` (AP-026 slice) |
| Hashlock High-02 | disproven | C-26 |
| Hashlock Medium-01 referral | invalid | C-29 |
| Permit2 victim drain | invalid | source review + test intent map |
| Spearbit zero oracle | duplicate | audited JSON |
| Optimistic bad debt zero-repay | duplicate | Blackthorn L-10 |
| Delegate ratifier grief | duplicate | L-16 |
| Repay callback theft | duplicate-risk closed | C-022, Blackthorn L-19/L-26 |
| Multi-collateral bitmap desync | covered | C-033, `CollateralBitmap.spec` |
| Maturity fee bucket surprise | covered | C-013, settlement fee tests |
| Withdrawable > custody | covered | C-020, CVL |
| Terminal lossFactor fee extract | duplicate | C-021, C-034 |
| P3-02 CVL market ID alias | proven formal only | not production exploit |
| L-01 signature malleability | proven Low | do not re-file as new |
| P3-01 roleSetter zero | proven Low | admin footgun |

## When to escalate parked items

| Parked | Escalate if |
|---|---|
| Weird ERC20 | Competition in scope + normal callback path |
| Bad oracle market | Non-consenting victim forced to trade |
| Dust rounding | Accumulates to cap bypass or >$X at realistic TVL |
| Admin role | External attacker can trigger without admin key |
