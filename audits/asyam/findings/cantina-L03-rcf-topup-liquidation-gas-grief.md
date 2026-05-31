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
| **Proof selection** | Local |
| **Submission status** | Complete packet; archive unless manually submitted as Informational |

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

### Proof mode

Select **Local** in Cantina. The PoC uses the repository's Foundry harness and
ordinary local ERC20 mocks. It does not require a live fork, RPC URL, or external
deployment.

### Preconditions

- A normal-mode borrower position is unhealthy and liquidatable.
- The configured `rcfThreshold` is one unit above the calculated repayable
  collateral remainder.
- The liquidator prepares a full-close transaction.
- The borrower supplies the minimal collateral top-up required to cross the RCF
  boundary.

### Run command

```bash
forge test --match-path test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol -vvvv
```

Verified locally on 2026-05-31:

```text
Ran 1 test suite: 3 tests passed, 0 failed, 0 skipped
```

### What the PoC proves

| Test | Proof |
|---|---|
| `testHist_SmallTopUpFlipsFullCloseToRcfButAdaptivePartialLiquidationRecoversHealth` | A control full-close liquidation succeeds immediately below the threshold. After the borrower supplies `2 wei`, the stale full-close liquidation reverts with `RecoveryCloseFactorConditionsViolated`. A recomputed `maxRepaid` liquidation succeeds, restores health, and leaves `lossFactor == 0`. |
| `testHist_SmallTopUpCannotIncreaseBadDebtAtIdenticalPrice` | The minimal top-up cannot slash lenders, decrease `totalUnits`, or increase `lossFactor`. |
| `testHist_UnauthorizedThirdPartyCannotTopUpBorrowerToFlipRcf` | An unrelated third party cannot mutate borrower collateral because `supplyCollateral` reverts with `Unauthorized`. |

### Core reproducer

The local test runs a prompt control liquidation, reverts to the same state,
adds the minimal top-up, observes the stale full-close revert, and executes the
adaptive RCF-sized liquidation:

```solidity
function testHist_SmallTopUpFlipsFullCloseToRcfButAdaptivePartialLiquidationRecoversHealth() public {
    (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();
    _fundLoanToken(LIQUIDATOR_ACTOR, UNITS);

    uint256 snapshot = vm.snapshotState();

    vm.prank(LIQUIDATOR_ACTOR);
    midnight.liquidate(rcfMarket, 0, 0, UNITS, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");
    assertEq(midnight.debtOf(id, borrower), 0, "control full-close liquidation succeeds below RCF threshold");
    assertEq(midnight.lossFactor(id), 0, "control liquidation realizes no bad debt");

    vm.revertToState(snapshot);

    uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);
    _supplyTopUp(rcfMarket, topUpAssets);

    vm.prank(LIQUIDATOR_ACTOR);
    vm.expectRevert(IMidnight.RecoveryCloseFactorConditionsViolated.selector);
    midnight.liquidate(rcfMarket, 0, 0, UNITS, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");

    uint256 maxRepaid = _maxRepaid(rcfMarket, id);
    vm.prank(LIQUIDATOR_ACTOR);
    midnight.liquidate(rcfMarket, 0, 0, maxRepaid, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");

    assertEq(topUpAssets, 2, "two collateral wei cross the RCF threshold");
    assertGt(midnight.debtOf(id, borrower), 0, "RCF leaves a healthy residual position");
    assertTrue(midnight.isHealthy(rcfMarket, id, borrower), "adaptive RCF liquidation restores health");
    assertEq(midnight.lossFactor(id), 0, "small top-up does not create socialized loss");
    assertEq(midnight.withdrawable(id), maxRepaid, "lenders receive exactly the adaptive repayment");
}
```

The PoC calculates the RCF-sized repayment with the same economic relation
exercised by the production path:

```solidity
function _maxRepaid(Market memory rcfMarket, uint256 collateral, uint256 debt)
    internal
    pure
    returns (uint256)
{
    uint256 lltv = rcfMarket.collateralParams[0].lltv;
    uint256 lif = rcfMarket.collateralParams[0].maxLif;
    uint256 maxDebt = collateral.mulDivDown(LIQUIDATION_PRICE, ORACLE_PRICE_SCALE).mulDivDown(lltv, WAD);
    return (debt - maxDebt).mulDivUp(WAD * WAD, WAD * WAD - lif * lltv);
}
```

### Trace interpretation

The top-up moves the repayable collateral remainder from below `rcfThreshold`
to the threshold boundary. The full-close exception no longer applies, so the
stale transaction reverts. The correctly sized partial liquidation restores
health and credits lenders with exactly `maxRepaid`. This is evidence of a
quote-sensitive RCF branch, not evidence of lender loss.

## Recommendation

Document that liquidation bots must recompute RCF-limited repayment immediately before submission and tolerate stale
transaction reverts. If operational mitigation is desired, expose a quoting helper or bounded slippage mechanism for
normal-mode liquidations.

For example, expose a view helper that returns the currently valid repayment
ceiling and whether the full-close exception applies:

```solidity
function maxLiquidationRepayment(Market memory market, address borrower, uint256 collateralIndex)
    external
    view
    returns (uint256 maxRepaid, bool fullCloseAllowed);
```
