# Cantina Submission — L-03

## Cantina UI Fields

| Field | Value |
|---|---|
| **Finding Title** | A borrower can invalidate a full-close liquidation by crossing the RCF boundary with a tiny collateral top-up |
| **Likelihood** | Medium |
| **Impact** | Low |
| **Severity** | Low / Gas / Informational |
| **Checklist anchors** | `SOL-AM-FrA-3`, `SOL-AM-GA-1`, `SOL-Defi-Lending-6` |
| **PoC location** | `test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol` |
| **PoC type** | Local Foundry (no fork required) |
| **Submission status** | Archived; do not submit |

## Summary

The normal-mode liquidation recovery close factor (RCF) is intentionally deactivated when the collateral remainder is
smaller than `rcfThreshold`. At the exact boundary, a borrower can supply `2 wei` of ordinary collateral to switch the
same position from RCF-deactivated to RCF-active. A pending full-close liquidation then reverts with
`RecoveryCloseFactorConditionsViolated`.

An adaptive liquidation sized to the current RCF limit succeeds and restores the borrower to health without realizing
bad debt. This is therefore a Low/Gas/Informational finding, not a High/Medium finding.

## Finding Description

For normal-mode liquidations, `Midnight.liquidate` permits repayment above the computed recovery amount only if the
remaining collateral value is below `rcfThreshold`:

```solidity
require(
    repaidUnits <= maxRepaid
        || _position.collateral[collateralIndex].mulDivDown(liquidatedCollatPrice, ORACLE_PRICE_SCALE)
            .mulDivDown(WAD, lif).zeroFloorSub(maxRepaid) < market.rcfThreshold,
    RecoveryCloseFactorConditionsViolated()
);
```

A tiny collateral top-up can move the remainder from `rcfThreshold - 1` to `rcfThreshold`, changing the accepted
liquidation amount:

1. Before the top-up, a full-close liquidation succeeds because the RCF exception is active.
2. The borrower supplies `2 wei` of ordinary collateral.
3. The same full-close liquidation reverts because the RCF exception is no longer active.
4. A recomputed `maxRepaid` liquidation succeeds and restores the position to health.

The top-up is borrower-controlled: `supplyCollateral` rejects an unrelated third party attempting to mutate the
borrower's position.

## Impact Explanation

**Impact: Low**

The demonstrated impact is wasted liquidator gas and a need to refresh the liquidation amount. No lender slash, bad
debt, frozen recoverability, or attacker profit was demonstrated. After retrying with the current `maxRepaid`, the
position is healthy and `lossFactor` remains zero.

This may be judged Informational because RCF exists to limit normal-mode liquidation to the amount needed to restore
health, and the boundary transition is consistent with that design.

### Why this is not High or Medium

The adaptive RCF-sized retry succeeds, restores borrower health, and leaves
`lossFactor == 0`. No lender loss, frozen recoverability, or attacker profit was
demonstrated.

### Why this is still useful

The trace is retained as integration evidence: liquidators should recompute RCF
limits before submission and tolerate stale full-close quotes.

## Likelihood Explanation

**Likelihood: Medium**

A borrower can observe a pending full-close normal-mode liquidation and add a minimal amount of collateral. The local
test crosses the boundary with `2 wei`. Practical impact remains bounded because a liquidator can recompute the RCF
limit and resubmit.

## Dedup Note

This is adjacent to L-02 and generic liquidation-quote front-running. It is also closely tied to the documented RCF
policy. The reported impact is intentionally limited to operational gas grief at the exact branch boundary.

The submission review classifies the observed branch transition as intended RCF
policy behavior. This packet is archived and should not be submitted.

## Proof of Concept

Run:

```bash
forge test --match-path test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol -vvvv
```

Validated locally: `3 passed, 0 failed`.

## Recommendation

Document that liquidation bots must recompute RCF-limited repayment immediately before submission and tolerate stale
transaction reverts. If operational mitigation is desired, expose a quoting helper or bounded slippage mechanism for
normal-mode liquidations.
