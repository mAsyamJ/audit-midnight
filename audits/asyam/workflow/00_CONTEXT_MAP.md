# 00 Context Map

Date: 2026-05-30

## Scope

Morpho Midnight is a non-custodial fixed-rate lending protocol with isolated fixed-maturity markets. Users trade credit and debt units through off-chain offers that are ratified on-chain at fill time. Capital is sourced during settlement, not pre-escrowed.

Primary files in scope:

- `src/Midnight.sol`: core market state, roles, fees, take/repay/withdraw/collateral/liquidation/flash loan entrypoints.
- `src/periphery/MidnightBundles.sol`: UX router for multi-offer fills, collateral supply/withdraw, repay, Permit2/ERC2612, and referral fees.
- `src/periphery/TakeAmountsLib.sol` and `src/periphery/ConsumableUnitsLib.sol`: inverse target-fill math for bundles.
- `src/periphery/EcrecoverAuthorizer.sol`: EIP-712 delegated authorization helper.
- `src/ratifiers/EcrecoverRatifier.sol`, `src/ratifiers/SetterRatifier.sol`, `src/ratifiers/libraries/HashLib.sol`: Merkle and signature based offer authorization.
- `certora/**`: formal specs and modeling assumptions.
- `test/**`: Foundry tests.
- `audits/asyam/audited/**`: prior audited issue corpus for deduplication.
- `audits/asyam/hashlock/**`: AI/hypothesis reports only.

## Actors And Trust Boundaries

- Makers sign or ratify offers and may provide callbacks as liquidity sources.
- Takers execute offers directly or through `MidnightBundles`.
- Authorized operators can act for an authorizer across core state, consumed caps, and ratifier root controls.
- Fee roles can set defaults, market fees, and claim fees.
- Gate contracts are optional market policy hooks for entering credit/debt or liquidating.
- Oracles are arbitrary market-specified contracts returning `uint256 price()`.
- ERC20 tokens are external systems; Certora and comments assume exact, non-reentrant token behavior for core safety claims.
- Callbacks are untrusted external calls in `take`, `repay`, `liquidate`, and `flashLoan`.

## Core External/Public Surface

Admin and fee functions:

- `multicall`
- `setRoleSetter`
- `setFeeSetter`
- `setFeeClaimer`
- `setTickSpacingSetter`
- `setMarketTickSpacing`
- `setMarketSettlementFee`
- `setDefaultSettlementFee`
- `setMarketContinuousFee`
- `setDefaultContinuousFee`
- `claimSettlementFee`
- `claimContinuousFee`

Market/user state transitions:

- `take`
- `withdraw`
- `repay`
- `supplyCollateral`
- `withdrawCollateral`
- `liquidate`
- `setConsumed`
- `setIsAuthorized`
- `flashLoan`
- `touchMarket`
- `updatePosition`

View/reconstruction helpers:

- `updatePositionView`
- `toId`
- `toMarket`
- position and market field getters
- `liquidationLocked`
- `isHealthy`
- `settlementFee`

Periphery:

- `buyWithUnitsTargetAndWithdrawCollateral`
- `supplyCollateralAndSellWithUnitsTarget`
- `buyWithAssetsTargetAndWithdrawCollateral`
- `supplyCollateralAndSellWithAssetsTarget`
- `repayAndWithdrawCollateral`

Ratifiers/auth:

- `SetterRatifier.setIsRootRatified`
- `SetterRatifier.isRatified`
- `EcrecoverRatifier.cancelRoot`
- `EcrecoverRatifier.isRatified`
- `EcrecoverAuthorizer.setIsAuthorized`

## Checklist Categories Loaded

From `smart-contract-audit`:

- `attacker-s-mindset.md`: DOS, front-running, reentrancy, replay, slippage.
- `basics.md`: access control, events, input validation, loops, public surface.
- `defi.md`: lending, liquidation, oracle, slippage, decimal/token assumptions.
- `external-call.md`: callback, delegatecall/multicall, external call ordering, caller semantics.
- `signature.md`: nonce, chain/domain separation, malleability, signer origin, deadlines.
- `hash-merkle-tree.md`: Merkle proof, leaf binding, zero hash/proof edge cases.
- `token.md`: non-standard ERC20, approvals, zero transfers, Permit/ERC2612.
- `heuristics.md`: duplicate logic, asymmetry, rounding amplification, repeated calls.

Most relevant checklist anchors for this codebase:

- `SOL-EC-1`, `SOL-EC-13`, `SOL-EC-14`: callback and caller binding.
- `SOL-Defi-Lending-*`: liquidation, debt/credit, same-asset lending, solvency.
- `SOL-Defi-Oracle-2`, `SOL-Defi-Oracle-3`: zero/stale oracle handling.
- `SOL-Signature-*`: EIP-712 replay, malleability, deadlines.
- `SOL-HMT-*`: Merkle proof and leaf binding.
- `SOL-Token-FE-*`: non-standard token and permit behavior.
- `SOL-Heuristics-10`, `SOL-Heuristics-17`: rounding amplification and split-vs-aggregate equivalence.
- `SOL-Basics-Event-1`: event completeness.

## Formal Verification Context

Certora verifies many core invariants: accounting, balance effects, market creation, health, liquidation bounds, consumed caps, authorization, role access, settlement/continuous fees, solvency, and fixed-point math.

Important modeling limits from `certora/README.md` and specs:

- `multicall` is deleted from specs because it delegates only to the current contract.
- ERC20 tokens are assumed well-behaved.
- Unless a property is specifically about callbacks, external calls are assumed not to re-enter Midnight.
- Some callback rules model callbacks as pure ghost-controlled returns/reverts.
- Periphery bundle contracts are not covered by the core CVL suite.
- Oracle prices are often summarized as constant or ghost values, with explicit assumptions in division/liquidation specs.

These limits make the highest-value remaining queues cross-contract and composition-heavy: callbacks, periphery, gate/oracle liveness, signed authorization scope, and exact helper/core math.
