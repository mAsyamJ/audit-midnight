# Top 5 Pattern PoC Plan

Implement only after this planning workspace is reviewed. Each PoC must use real protocol entrypoints, standard tokens, and a control execution.

## PT-POC-001 - Duplicate-token flash-array settlement
- Why selected: Batch accounting frequently assumes asset uniqueness, while `flashLoan` accepts parallel arrays without an explicit uniqueness check.
- Exact implementation plan: Create `test/asyam/poc/pattern/PoC_Pattern_DuplicateTokenFlashArray.t.sol` using the existing `test/asyam` harness style. Compare split duplicate-token arrays against one aggregated entry; overlap token custody held for ordinary protocol accounting.
- Required helpers/mocks: A callback mock that approves and repays summed standard-token obligations.
- Exact assertions: Final protocol token balance equals the pre-loan balance and all liabilities remain backed.
- Expected proof condition: Any standard-token repeated-entry trace leaves an externalizable deficit.
- Expected disproof condition: All repeated-entry variants repay the aggregate obligation and preserve custody.
- Command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_DuplicateTokenFlashArray.t.sol -vvvv`.

## PT-POC-002 - Multicall state-transition composition
- Why selected: `multicall` delegatecalls `address(this)` and preserves `msg.sender`; native batching coverage is narrower than the full public state machine.
- Exact implementation plan: Create `test/asyam/poc/pattern/PoC_Pattern_MulticallStateTransition.t.sol` using the existing `test/asyam` harness style. Compare sequential and batched public or legitimately authorized actions around authorization, consumed state, repay, collateral exit, and liquidation.
- Required helpers/mocks: Existing market setup helpers; no adversarial token mock.
- Exact assertions: No batching-only debt escape, collateral escape, consumed-cap bypass, or third-party transfer.
- Expected proof condition: Batching reaches a materially unsafe final state unavailable to the equivalent sequential execution.
- Expected disproof condition: Every batch either matches the control state or reverts atomically.
- Command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_MulticallStateTransition.t.sol -vvvv`.

## PT-POC-003 - Liquidation-order social-loss divergence
- Why selected: Historical lending bugs often arise when liquidator-selected collateral ordering changes lender loss rather than only documented incentive.
- Exact implementation plan: Create `test/asyam/poc/pattern/PoC_Pattern_LiquidationOrderSocialLoss.t.sol` using the existing `test/asyam` harness style. Clone an initial multi-collateral position and liquidate collateral indexes in opposite orders across transactions.
- Required helpers/mocks: Two collateral tokens and ordinary oracle mocks with distinct prices, LLTV, maxLif, and RCF-sensitive values.
- Exact assertions: Compare cumulative liquidator proceeds, residual recoverable collateral, `lossFactor`, `totalUnits`, and lender effective claims.
- Expected proof condition: Attacker-selected order creates reliable avoidable non-dust lender loss or private gain.
- Expected disproof condition: Order differences are fully explained by documented incentive parameters and do not increase social loss.
- Command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_LiquidationOrderSocialLoss.t.sol -vvvv`.

## PT-POC-004 - Continuous-fee claim context switch
- Why selected: Lazy position settlement and fee claiming can create ordering-sensitive accounting if claim context changes before all lenders update.
- Exact implementation plan: Create `test/asyam/poc/pattern/PoC_Pattern_ClaimContextSwitch.t.sol` using the existing `test/asyam` harness style. Compare eager-touch control against subset touch, bounded bad debt, fee claim, repay, and lender withdrawal permutations.
- Required helpers/mocks: Multiple lenders, fee accrual warp, borrower setup, and ordinary liquidation path.
- Exact assertions: Aggregate payouts plus fee claims remain backed and control-equivalent outside documented rounding.
- Expected proof condition: A realistic ordering externalizes non-dust value from untouched lenders or custody.
- Expected disproof condition: All permutations reconcile modulo documented dust and prior known fee behavior.
- Command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_ClaimContextSwitch.t.sol -vvvv`.

## PT-POC-005 - Partial-success poison route
- Why selected: Aggregator loops that tolerate failing legs need an atomicity check after earlier successful economic effects.
- Exact implementation plan: Create `test/asyam/poc/pattern/PoC_Pattern_PartialSuccessPoisonRoute.t.sol` using the existing `test/asyam` harness style. Execute a valid leg before a hostile later leg through each relevant bundle route; inspect revert and continuation paths.
- Required helpers/mocks: Minimal local ratifier or callback mock with bounded revert, gas, and return-data behavior.
- Exact assertions: The route completes within explicit bounds or rolls back collateral supply, fills, transfers, and approvals atomically.
- Expected proof condition: A hostile later leg strands value or preserves unintended partial economics for a non-consenting caller.
- Expected disproof condition: Failure rolls back fully or leaves only documented caller-selected route risk.
- Command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_PartialSuccessPoisonRoute.t.sol -vvvv`.
