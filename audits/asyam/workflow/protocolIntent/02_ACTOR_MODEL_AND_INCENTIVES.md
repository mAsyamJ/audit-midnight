# Actor Model and Incentives

Date: 2026-05-30

## Lender / credit buyer

| | |
|---|---|
| **Goal** | Earn fixed-rate exposure; exit by selling credit or withdrawing after repay |
| **Incentive** | Buy units below par; avoid `lossFactor` slashes |
| **Powers** | `take` (buy side), `withdraw`, `updatePosition`, authorize operators |
| **Must not** | Withdraw more than synced credit; steal others' custody |
| **Functions** | `take`, `withdraw`, `updatePosition`, `setIsAuthorized` |
| **PoC setup** | Fund buyer callback or direct pull; track `credit`, `withdrawable`, `lossFactor` |

## Borrower / debt seller

| | |
|---|---|
| **Goal** | Borrow loan tokens against collateral; repay or be liquidated |
| **Incentive** | Sell units for loan tokens; manage health |
| **Powers** | `take` (sell), `repay`, `supplyCollateral`, `withdrawCollateral` |
| **Must not** | Withdraw collateral while unhealthy; increase debt post-maturity |
| **Functions** | `take`, `repay`, collateral fns, `liquidate` (as borrower) |
| **PoC setup** | Collateral + oracle; sell offer with callback for loan token |

## Maker

| | |
|---|---|
| **Goal** | Quote liquidity via signed offers without escrow |
| **Incentive** | Spread + optional callback sourcing |
| **Powers** | Define offer economics; ratifier; `setConsumed` |
| **Must not** | Fill beyond group caps; violate `reduceOnly` |
| **Functions** | Off-chain offers; `setConsumed`; ratifier roots |
| **PoC setup** | `BaseTest` maker keys; Merkle/signature ratifier data |

## Taker

| | |
|---|---|
| **Goal** | Execute maker quotes |
| **Incentive** | Arbitrage / user flow completion |
| **Powers** | `take` with ratifier proof; optional taker callback |
| **Must not** | `SelfTake`; bypass authorization |
| **Functions** | `take`, via `MidnightBundles` |
| **PoC setup** | `Config.t.sol` actors ALICE/BOB |

## Liquidator

| | |
|---|---|
| **Goal** | Profit from collateral seizure vs repayment |
| **Incentive** | LIF bonus; post-maturity incentives |
| **Powers** | `liquidate` if `NotLiquidatable` false |
| **Must not** | Liquidate healthy borrowers (pre-maturity) |
| **Functions** | `liquidate` |
| **PoC setup** | Unhealthy position; `postMaturityMode` flag |

## Multi-collateral borrower

| | |
|---|---|
| **Goal** | Optimize collateral mix |
| **Incentive** | Health from **sum** of collateral slots (bitmap) |
| **Attack surface** | Bitmap/index desync; phantom collateral (audited) |
| **Functions** | `supplyCollateral`, `withdrawCollateral`, `liquidate` loop |
| **PoC setup** | 2+ collateral types; see POC-INTENT-007 |

## Offer ratifier / delegate

| | |
|---|---|
| **Goal** | Prove offer set membership or signature validity |
| **Incentive** | Service fee off-chain |
| **Powers** | `EcrecoverRatifier` / `SetterRatifier`; delegated `setIsAuthorized` |
| **Must not** | Ratify canceled roots (intended cancel semantics) |
| **Functions** | `isRatified`, `setIsAuthorized`, root cancel |
| **PoC setup** | `HashLib` proofs; delegate operator |

## Authorized delegate / relayer

| | |
|---|---|
| **Goal** | Operate on behalf of maker/lender |
| **Incentive** | Automation |
| **Powers** | Broad `isAuthorized` — take, repay, consumed, ratifier admin |
| **Must not** | Exceed maker-granted intent (operational risk) |
| **Classification** | **INTENDED** broad delegation (Spearbit/Blackthorn duplicate-risk) |

## Periphery user / referral recipient

| | |
|---|---|
| **Goal** | One-tx leverage, repay, exact fills |
| **Incentive** | UX; referral fee |
| **Powers** | Call `MidnightBundles` |
| **Must not** | Drain router via reentrancy |
| **Classification** | Bad `receiver` / referral = usually **user error** |

## Oracle / gate deployer (market creator)

| | |
|---|---|
| **Goal** | Define market policy |
| **Incentive** | Custom markets |
| **Powers** | Choose oracle, gates, collateral set at first `touchMarket` |
| **Classification** | Malicious oracle on **consenting** market = **INTENDED / NOT A BUG** |

## Fee setter / fee claimer / role setter

| | |
|---|---|
| **Goal** | Protocol fee administration |
| **Powers** | Fee defaults, claims, roles |
| **Classification** | Admin footguns (e.g. `roleSetter = 0`) = Low unless external attacker path |

## Callback contract

| | |
|---|---|
| **Goal** | Provide liquidity or atomic checks |
| **Untrusted** | Yes — reentrancy surface |
| **Must return** | `CALLBACK_SUCCESS` magic |
| **PoC setup** | `test/asyam/mocks/ReentrantCallback.sol` patterns |

## Attacker combining multiple roles

See **Multi-role attacker models** below.

---

## Multi-role attacker models

### Maker + callback + taker

- Maker posts sell offer with malicious `sellerCallback`; taker buys.
- **Test:** reenter `take`, `liquidate`, bundles during `onSell` / `onBuy`.
- **Status:** C-14 disproven for accounting break; composition may remain open.

### Borrower + liquidator

- Same entity triggers self-liquidation / bad debt paths.
- **Test:** zero-repay liquidation, optimistic bad debt (duplicate-risk Spearbit/Blackthorn).

### Authorized delegate + ratifier root manager

- Delegate cancels roots or manipulates `consumed`.
- **Test:** grief vs intended admin power (duplicate L-16).

### Relayer + Permit2 signature holder

- Signature bound to router + `msg.sender` pulls.
- **Status:** closed invalid per `04_PROTOCOL_TEST_INTENT_MAP`.

### Periphery route builder + referral recipient

- Exact budget includes referral; under-budget reverts.
- **Status:** C-29 invalid.

### Oracle/gate deployer + market creator

- Victim trades on malicious market.
- **Classification:** consenting participant risk unless forced cross-market.

### Lender + borrower across markets

- Isolation via distinct `toId`; no shared `withdrawable` across markets.
