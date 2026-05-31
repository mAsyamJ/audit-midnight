# Cantina Submission — L-02

## Cantina UI Fields

| Field | Value |
|---|---|
| **Finding Title** | A borrower can invalidate an exact liquidation transaction by front-running it with a tiny repayment |
| **Likelihood** | Medium |
| **Impact** | Low |
| **Severity** | Low / Gas / Informational |
| **Checklist anchors** | `SOL-AM-FrA-3`, `SOL-AM-GA-1`, `SOL-Defi-Lending-1`, `SOL-Defi-Lending-2` |
| **PoC location** | `test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol` |
| **PoC type** | Local Foundry (no fork required) |
| **Proof selection** | Local |
| **Submission status** | Complete packet; hold for manual duplicate review |

## Summary

A borrower can front-run an exact debt-sized `liquidate` transaction with a one-wei repayment. The repayment lowers
the stored debt immediately. The stale liquidation then attempts to subtract the old `repaidUnits` value from the
smaller current debt and reverts.

An adaptive liquidator can recompute the current debt and retry successfully. The local PoC did not demonstrate bad
debt escalation, reduced lender recovery, frozen funds, or attacker profit. This is therefore a Low/Gas/Informational
finding, not a High/Medium finding.

## Finding Description

`Midnight.repay` allows a borrower or authorized operator to reduce debt by an arbitrary nonzero amount:

```solidity
position[id][onBehalf].debt -= UtilsLib.toUint128(units);
marketState[id].withdrawable += UtilsLib.toUint128(units);
```

`Midnight.liquidate` later applies the liquidator-provided `repaidUnits` value against the current debt:

```solidity
_marketState.withdrawable += UtilsLib.toUint128(repaidUnits);
_position.debt -= UtilsLib.toUint128(repaidUnits);
```

If a liquidator submits an exact full-debt liquidation and the borrower repays one wei before inclusion, the
liquidation underflows and reverts. This can force liquidation bots to refresh quotes and resubmit transactions during
volatile periods.

The PoC also establishes the limits of the observation:

- the one-wei repayment is backed by a real token transfer;
- it decreases rather than increases debt;
- an adaptive retry using the current debt fully liquidates the position;
- lender withdrawable matches prompt control liquidation;
- at an identical lower oracle price, the tiny repayment does not increase socialized loss;
- an unrelated third party cannot dust-repay the borrower without authorization.

## Impact Explanation

**Impact: Low**

The demonstrated impact is wasted gas and delayed keeper execution for stale exact-input liquidation transactions.
The borrower pays the repayment amount and transaction gas. A liquidator can recover by reading current debt and
retrying.

No non-dust lender loss, bad-debt escalation, frozen recoverability, unfair liquidation, or attacker profit was
demonstrated. Treat as Gas or Informational if the competition does not accept repairable transaction-invalidation
grief as Low.

### Why this is not High or Medium

The adaptive retry succeeds with equivalent lender recovery and zero
`lossFactor` increase. The observation does not create a solvency break or
non-dust economic loss.

### Why this is still useful

The liquidation-specific trace is useful integration guidance: bots that submit
exact debt-sized liquidations must refresh state and tolerate stale-input
reverts.

## Likelihood Explanation

**Likelihood: Medium**

A borrower can observe a pending exact liquidation transaction and submit a one-wei repayment with a higher priority
fee. The path uses ordinary ERC20 behavior and a normal borrower permission. Its practical usefulness is limited
because liquidation bots can refresh state, batch retries, or use non-maximal liquidation amounts.

## Dedup Note

Spearbit previously reported that `take()` calls can be forced to revert via front-running. This observation affects a
different entrypoint and state transition: borrower `repay()` invalidates an exact `liquidate()` input. The common
theme is mempool transaction invalidation, but the affected operation, attacker action, stale parameter, and mitigation
are liquidation-specific.

Because the practical impact remains repairable gas grief, this packet is held
for manual duplicate review and is not recommended for submission by default.

## Proof of Concept

Github code: https://github.com/mAsyamJ/audit-midnight/blob/main/test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol

### Preconditions

- A borrower has `100e18` debt units.
- A liquidator prepares an exact full-debt liquidation using
  `repaidUnits = 100e18`.
- The borrower is authorized to repay its own debt.

### Run command

```bash
forge test --match-path test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol -vvvv
```

Verified locally on 2026-05-31:

```text
Ran 1 test suite: 3 tests passed, 0 failed, 0 skipped
```

### What the PoC proves

| Test | Proof |
|---|---|
| `testHist_TinyRepayInvalidatesStaleExactLiquidationButAdaptiveRetryRecoversEquivalentValue` | A borrower repayment of `1 wei` causes the stale exact liquidation to revert with arithmetic underflow. A liquidation recomputed against current debt succeeds and restores the same lender recovery as the prompt control. |
| `testHist_TinyRepayDoesNotIncreaseBadDebtUnderIdenticalLowerPrice` | At an identical lower oracle price, the one-wei repayment does not increase socialized loss or reduce lender credit relative to control. |
| `testHist_UnauthorizedThirdPartyCannotDustRepayBorrower` | An unrelated third party cannot mutate borrower debt because `repay` reverts with `Unauthorized`. |

### Core reproducer

The local test snapshots a control liquidation, then replays the same state with
the borrower front-run:

```solidity
function testHist_TinyRepayInvalidatesStaleExactLiquidationButAdaptiveRetryRecoversEquivalentValue() public {
    _openBorrowerDebt(UNITS);
    _fundLoanToken(LIQUIDATOR_ACTOR, UNITS);
    vm.warp(market.maturity + TIME_TO_MAX_LIF);

    uint256 snapshot = vm.snapshotState();

    vm.prank(LIQUIDATOR_ACTOR);
    midnight.liquidate(market, 0, 0, UNITS, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

    uint256 controlWithdrawable = midnight.withdrawable(marketId);
    assertEq(midnight.debtOf(marketId, borrower), 0, "control liquidation repays all debt");
    assertEq(midnight.lossFactor(marketId), 0, "control liquidation realizes no bad debt");

    vm.revertToState(snapshot);

    vm.prank(borrower);
    midnight.repay(market, 1, borrower, address(0), hex"");

    vm.prank(LIQUIDATOR_ACTOR);
    vm.expectRevert(stdError.arithmeticError);
    midnight.liquidate(market, 0, 0, UNITS, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

    uint256 currentDebt = midnight.debtOf(marketId, borrower);
    assertEq(currentDebt, UNITS - 1, "tiny repayment lowers debt by one wei");

    vm.prank(LIQUIDATOR_ACTOR);
    midnight.liquidate(market, 0, 0, currentDebt, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

    assertEq(midnight.debtOf(marketId, borrower), 0, "adaptive liquidation repays current debt");
    assertEq(midnight.lossFactor(marketId), 0, "tiny repayment does not create bad debt");
    assertEq(midnight.withdrawable(marketId), controlWithdrawable, "adaptive retry restores equivalent recovery");

    uint256 lenderBefore = loanToken.balanceOf(lender);
    vm.prank(lender);
    midnight.withdraw(market, UNITS, lender, lender);
    assertEq(loanToken.balanceOf(lender), lenderBefore + UNITS, "lender can withdraw the full recovered claim");
}
```

### Trace interpretation

The first post-repayment liquidation is stale: it still submits `UNITS`, while
the borrower's current debt is `UNITS - 1`. The subtraction in
`Midnight.liquidate` reverts. The subsequent liquidation reads current debt,
repays `UNITS - 1`, leaves debt at zero, leaves `lossFactor` at zero, and allows
the lender to withdraw the full recovered claim.

## Recommendation

Document that liquidation integrations should refresh debt immediately before submission and tolerate stale
transaction reverts. If the protocol wants to reduce this operational surface, consider a bounded liquidator slippage
mechanism or a repay-all sentinel that resolves against current debt while preserving the liquidator's minimum seized
collateral constraint.

One possible integration-facing API is an explicit repay-all sentinel:

```solidity
uint256 effectiveRepaidUnits = repaidUnits == type(uint256).max
    ? _position.debt
    : repaidUnits;
```

Any sentinel implementation must preserve the liquidator's seized-collateral
slippage bound and existing RCF checks.
