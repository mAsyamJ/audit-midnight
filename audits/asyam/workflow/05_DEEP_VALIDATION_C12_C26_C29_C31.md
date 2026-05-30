# Deep Validation: C-12, C-26, C-29, C-31

Date: 2026-05-30

## Test Ownership

- Protocol-authored tests remain unchanged and are read-only executable design evidence.
- Exploratory attack probes live under `test/asyam`.
- Stable regressions for closed priority queues live under `test/asyamFindings`.

## C-12 Reduce-Only Rounding Edge

**Result:** disproven.

`Midnight.take` computes unit-side `buyerCreditIncrease` and `sellerDebtIncrease`, then rejects a reduce-only offer if the relevant delta is non-zero. This guard runs before callbacks. Price rounding cannot bypass a unit-side overfill check.

Evidence:

- Protocol intent: `test/TakeTest.sol` fuzzes reduce-only success and revert behavior for buy and sell offers.
- Exploratory probe: `test/asyam/poc/PoC_DeepValidationQueues.t.sol`.
- Promoted regression: one-wei overfill reverts with `MakerCreditOrDebtIncreased`.

## C-26 Bundler Temporary-Balance Theft

**Result:** disproven under standard-token assumptions.

`MidnightBundles` routes computed per-call amounts. It does not sweep `balanceOf(router)` and does not approve callbacks to spend router balances. The nested multi-leg regression parks outer first-leg sell proceeds in the router, invokes another sell bundle during the second callback, and confirms the nested call cannot consume the parked outer proceeds.

Evidence:

- Exploratory probe: `test/asyam/poc/PoC_BundleTemporaryBalanceReentrancy.t.sol`.
- Promoted regressions: visible refund float cannot be extracted; nested sell bundle preserves outer parked proceeds.

Residual scope:

- Malicious token-hook reentry remains outside the stated token assumptions.

## C-29 Referral Exact-Fill Boundary

**Result:** invalid hypothesis.

For `buyWithUnitsTargetAndWithdrawCollateral`, `maxBuyerAssets` is the buyer's total budget. After fills, the router computes the referral amount and pays it before refunding the remainder. A budget of `requiredBudget - 1` reverts atomically with `Insufficient balance`; the exact `requiredBudget` succeeds with no router residual.

Evidence:

- Protocol intent: `MidnightBundles` NatSpec includes `filledBuyerAssets + fee` in buyer spend.
- Exploratory probe: `test/asyam/poc/PoC_DeepValidationQueues.t.sol`.
- Promoted regression: 257-run fuzz campaign across units and referral percentages.
- Separate promoted regression: asset-target route handles an extreme `WAD - 1` referral fee without residual.

## C-31 Same Loan/Collateral Token Self-Loop

**Result:** disproven for tested standard-token paths.

The protocol's same-token custody balance remains sufficient for collateral accounting plus withdrawable lender claims in the tested compositions.

Evidence:

- Exploratory probe: same-token repay callback withdraws collateral to fund repayment.
- Promoted regressions:
  - repay-from-collateral callback fully funds lender withdrawal;
  - two-step same-token leverage loop fully unwinds;
  - liquidation callback repays from seized same-token collateral while remaining custody equals remaining collateral plus withdrawable lender claims.

Residual scope:

- Multi-collateral same-token compositions remain a separate queue.
- Malicious token hooks and malicious oracle behavior remain separate trust-model questions.

## Verification

```text
forge test --match-path 'test/asyam/**/*.sol' -vvv
18 passed, 0 failed

forge test --match-path 'test/asyamFindings/*.sol' -vvv
12 passed, 0 failed
```
