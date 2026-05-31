# Creative PoC Backlog

Date: 2026-05-30

These are later implementations only. Reuse `test/asyam/Config.t.sol` and existing mocks where possible. Do not edit native tests or `src/*`.

### POC-COMP-01 — Ratifier Periphery Consumed

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol`
- **Compositions:** COMP-001, COMP-016, COMP-022, COMP-023
- **Imports:** `Config.t.sol`, `IMidnightBundles`, `EcrecoverRatifier`, `SetterRatifier`, `CALLBACK_SUCCESS`
- **Setup helpers needed:** signed/root-backed offers sharing maker/group; units-target bundle builder.
- **Mocks needed:** callback that can nested-take, toggle setter root, or call `setConsumed`.
- **Actor setup:** maker, authorized delegate, route caller, callback payer.
- **Transaction sequence:** direct partial fill -> cancel/disable root A -> route A/B -> optional callback consume/cancel -> fallback.
- **Assertions:** accepted `consumed <= max`; target either completes exactly or entire route reverts; router balance zero; no excess maker exposure.
- **Expected success condition:** any cap bypass, residue, or accepted route outside target bounds.
- **Expected disproof condition:** cap remains bounded and failed paths roll back atomically.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol' -vvvv`

### POC-COMP-02 — Maturity Liquidation Flash

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol`
- **Compositions:** COMP-004, COMP-014, COMP-024
- **Imports:** `Config.t.sol`, `IFlashLoanCallback`, `ILiquidateCallback`, `IRepayCallback`
- **Setup helpers needed:** matured borrower, lender credit, flash amount, liquidation quote.
- **Mocks needed:** callback orchestrator for flash -> liquidate -> nested withdraw/repay -> reimburse.
- **Actor setup:** borrower, lender, attacker callback/liquidator.
- **Transaction sequence:** warp `maturity + 1` -> flash -> liquidate repay-input -> callback withdraw/route/repay -> finish pulls.
- **Assertions:** attacker profit <= legitimate incentive; Midnight token balance and `totalUnits` backing hold; flash fully restored.
- **Expected success condition:** unpaid withdrawal, duplicated temporary balance, or net drain.
- **Expected disproof condition:** all compositions settle with no gain beyond funded incentive or revert atomically.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol' -vvvv`

### POC-COMP-03 — LossFactor Withdrawable Fee

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol`
- **Compositions:** COMP-003, COMP-028
- **Imports:** `Config.t.sol`, `Market`
- **Setup helpers needed:** two markets sharing loan token; lenders, repaying borrower, bad-debt borrower.
- **Mocks needed:** none beyond configurable oracle.
- **Actor setup:** fee claimer, liquidator, stale lender A, lender B.
- **Transaction sequence:** liquidate A -> repay B -> claim A fee -> update/withdraw lenders; repeat order permutations.
- **Assertions:** aggregate custody covers collateral + withdrawable + claimable fees; claims cannot starve other market.
- **Expected success condition:** first-claimer drains token balance needed for valid later claim.
- **Expected disproof condition:** all permutations remain backed; rounding bounded to dust.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol' -vvvv`

### POC-COMP-04 — MultiCollateral Oracle Gate

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_MultiCollateralOracleGate.sol`
- **Compositions:** COMP-006, COMP-020
- **Imports:** `Config.t.sol`, `RevertingOracle`, gate interfaces
- **Setup helpers needed:** market with two collaterals and configurable liquidator gate.
- **Mocks needed:** toggleable oracle and gate.
- **Actor setup:** borrower, allowed and blocked liquidators.
- **Transaction sequence:** activate both collaterals -> borrow -> toggle oracle revert -> withdraw dust -> warp maturity -> liquidate other collateral.
- **Assertions:** classify exact locked operations, no unexpected state drift, no non-consenting victim path.
- **Expected success condition:** protocol-level forced victim loss distinct from chosen oracle/gate risk.
- **Expected disproof condition:** only consenting-market liveness failure.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MultiCollateralOracleGate.sol' -vvvv`

### POC-COMP-05 — Delegate Permit2 Route

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_DelegatePermit2Route.sol`
- **Compositions:** COMP-005
- **Imports:** `Config.t.sol`, `IMidnightBundles`, `Permit2`, token permit types
- **Setup helpers needed:** Permit2 signing helper, delegated taker position, collateral withdrawal array.
- **Mocks needed:** existing vendor `Permit2`.
- **Actor setup:** taker, delegate caller, unrelated victim signer, referral recipient, collateral receiver.
- **Transaction sequence:** authorize delegate -> sign Permit2 for caller/victim variants -> execute route -> inspect token payer and taker collateral.
- **Assertions:** victim token balance unchanged without matching call context; any taker collateral move is within broad authorization; refund and fee exact.
- **Expected success condition:** third-party payer drain or authority bypass.
- **Expected disproof condition:** only caller funds charged and voluntary delegation explains collateral movement.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_DelegatePermit2Route.sol' -vvvv`

### POC-COMP-06 — Exact Target Canceled Root

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol`
- **Compositions:** COMP-002, COMP-017, COMP-029
- **Imports:** `Config.t.sol`, `IMidnightBundles`, `EcrecoverRatifier`, ERC2612 token
- **Setup helpers needed:** signed offers A/B, exact-target route builder, root cancel helper.
- **Mocks needed:** none beyond existing permit token.
- **Actor setup:** maker, delegated signer, route caller, referral recipient.
- **Transaction sequence:** cancel root or revoke signer -> execute A/B exact route with referral -> inspect fallback and balances.
- **Assertions:** invalid A never fills; B obeys exact target; failed route rolls back pull; router residual zero.
- **Expected success condition:** residue, caller loss on revert, or accepted out-of-bound fallback.
- **Expected disproof condition:** strict equality and atomic rollback hold.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol' -vvvv`

### POC-COMP-07 — Cross Market Shared Token

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol`
- **Compositions:** COMP-007, COMP-018, COMP-026
- **Imports:** `Config.t.sol`, `IMidnightBundles`, callback interfaces
- **Setup helpers needed:** markets A/B with same loan token, optional same collateral token, different maturities.
- **Mocks needed:** cross-market callback router.
- **Actor setup:** attacker callback, lenders A/B, borrowers A/B.
- **Transaction sequence:** route/take A -> callback repay/withdraw/route B -> settle A -> reverse withdrawal order.
- **Assertions:** aggregate token custody covers all market-local obligations; no cross-ID claim.
- **Expected success condition:** valid B claim externalizes value backed only by temporary A funds.
- **Expected disproof condition:** each claim stays market-backed and aggregate custody holds.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol' -vvvv`

### POC-COMP-08 — Post Maturity Bad Debt Withdraw

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_PostMaturityBadDebtWithdraw.sol`
- **Compositions:** COMP-011, COMP-019
- **Imports:** `Config.t.sol`, `Market`
- **Setup helpers needed:** stale lender, repaying borrower, matured bad-debt borrower.
- **Mocks needed:** configurable gate if testing delayed liquidation.
- **Actor setup:** lender, two borrowers, liquidator.
- **Transaction sequence:** repay A before/after liquidate B -> update lender -> withdraw max -> reverse order.
- **Assertions:** withdraw amount <= post-slash backed credit; token custody nonnegative; losses proportional.
- **Expected success condition:** first-withdrawer advantage creates deficit.
- **Expected disproof condition:** order permutations remain backed.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_PostMaturityBadDebtWithdraw.sol' -vvvv`

### POC-COMP-09 — Callback Ratifier Root

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol`
- **Compositions:** COMP-008, COMP-015, COMP-027
- **Imports:** `Config.t.sol`, ratifier and callback interfaces
- **Setup helpers needed:** outer and nested offers, setter roots, maturity warp helper.
- **Mocks needed:** callback that toggles root and executes nested actions.
- **Actor setup:** maker callback/delegate, taker, seller borrower.
- **Transaction sequence:** outer take -> callback toggle root -> nested take/repay/collateral mutation -> outer settle.
- **Assertions:** cap bounded; seller healthy; lock cleared; no excess callback profit.
- **Expected success condition:** transient state monetized or persistent unhealthy seller accepted.
- **Expected disproof condition:** nested path reverts or completes with all invariants intact.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol' -vvvv`

### POC-COMP-10 — Formal Alias Executable

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_FormalAliasExecutable.sol`
- **Compositions:** COMP-009
- **Imports:** `Config.t.sol`, `IdLib`, `Market`
- **Setup helpers needed:** production-distinct markets sharing reduced CVL summary tuple.
- **Mocks needed:** none.
- **Actor setup:** lender/borrower in A and B.
- **Transaction sequence:** touch A/B -> create claims A -> attempt corresponding operations B -> shared-token ordering.
- **Assertions:** production IDs differ and every storage effect remains isolated.
- **Expected success condition:** runtime path crosses market-local state.
- **Expected disproof condition:** only formal alias remains; runtime isolation holds.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_FormalAliasExecutable.sol' -vvvv`

### POC-COMP-11 — Fee Change Route Quote

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol`
- **Compositions:** COMP-010, COMP-021, COMP-025
- **Imports:** `Config.t.sol`, `IMidnightBundles`
- **Setup helpers needed:** signed A/B offers near fee/tick boundary and route bounds.
- **Mocks needed:** none.
- **Actor setup:** fee setter, makers, route caller, referral recipient.
- **Transaction sequence:** quote -> update fee or warp expiry -> execute route -> observe skip/fallback.
- **Assertions:** route reverts or fills only within max/min and exact targets; no residual.
- **Expected success condition:** accepted fill outside explicit caller bounds.
- **Expected disproof condition:** documented stale quote behavior only.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol' -vvvv`

### POC-COMP-12 — Partial Repay LossFactor

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_PartialRepayLossFactor.sol`
- **Compositions:** COMP-011
- **Imports:** `Config.t.sol`, `Market`
- **Setup helpers needed:** lender with stale `lastLossFactor`, two borrower debts.
- **Mocks needed:** configurable oracle.
- **Actor setup:** lender, repayer, bad-debt borrower, liquidator.
- **Transaction sequence:** repay/slash permutations -> update -> withdraw.
- **Assertions:** same aggregate backed exit under each order, modulo bounded rounding.
- **Expected success condition:** material order-dependent over-withdrawal.
- **Expected disproof condition:** no deficit and only dust variance.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_PartialRepayLossFactor.sol' -vvvv`

### POC-COMP-13 — ReduceOnly Bundle Route

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_ReduceOnlyBundleRoute.sol`
- **Compositions:** COMP-012
- **Imports:** `Config.t.sol`, `IMidnightBundles`
- **Setup helpers needed:** maker position near credit/debt crossing and two route legs.
- **Mocks needed:** none.
- **Actor setup:** maker, taker.
- **Transaction sequence:** normal fill changes maker side -> later reduceOnly fill sized by route -> finalize.
- **Assertions:** accepted reduceOnly leg never increases maker credit/debt.
- **Expected success condition:** maker exposure increases by any amount.
- **Expected disproof condition:** leg skips/reverts or reduces exposure only.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ReduceOnlyBundleRoute.sol' -vvvv`

### POC-COMP-14 — Gate Liquidation Social Loss

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_GateLiquidationSocialLoss.sol`
- **Compositions:** COMP-019
- **Imports:** `Config.t.sol`, liquidator gate interface
- **Setup helpers needed:** gated market and multi-lender state.
- **Mocks needed:** toggleable gate.
- **Actor setup:** creator, borrower, blocked/allowed liquidators, lenders.
- **Transaction sequence:** block liquidation -> warp/change price -> allow -> slash -> withdraw lenders in both orders.
- **Assertions:** quantify only chosen-market timing effect; search for forced victim path.
- **Expected success condition:** non-consenting victim or protocol-level loss outside gate disclosure.
- **Expected disproof condition:** accepted gated-market risk only.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_GateLiquidationSocialLoss.sol' -vvvv`

### POC-COMP-15 — Dust Drift to Non-Dust Loss

- **Exact test path:** `test/asyam/poc/composition/PoC_Comp_DustDriftToNonDustLoss.sol`
- **Compositions:** COMP-013, COMP-030
- **Imports:** `Config.t.sol`, `IMidnightBundles`
- **Setup helpers needed:** bounded iteration harness, fair-value accounting mirror, two shared-token markets.
- **Mocks needed:** configurable oracle.
- **Actor setup:** attacker maker/taker, borrowers, liquidator, fee claimer.
- **Transaction sequence:** repeat microfills and updates -> realize bad debt -> claim -> withdraw A/B.
- **Assertions:** measure attacker net profit and aggregate deficit against realistic gas/TVL bounds.
- **Expected success condition:** reproducible material extraction, not wei dust.
- **Expected disproof condition:** only bounded dust or uneconomic amplification.
- **Command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_DustDriftToNonDustLoss.sol' -vvvv`
