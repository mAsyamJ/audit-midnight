# Function Attack Surface Map

Date: 2026-05-30

Template: **Function | Mutates | External calls | Reentrancy | Trust input | Priority | Tests | Attack hooks**

---

## P0 — Core settlement and risk

### `Midnight.take`

| Field | Detail |
|---|---|
| **Mutates** | `position[id][buyer/seller]`, `marketState.totalUnits`, `consumed[maker][group]`, `claimableSettlementFee`, pending fees |
| **External** | `IRatifier.isRatified`, `IEnterGate`, `IBuyCallback`/`ISellCallback`, `SafeTransferLib` ×2 |
| **Reentrancy** | After state update: `onBuy` → transfers → `onSell`; seller liquidation lock during sell CB |
| **Trust** | `Offer` calldata, `ratifierData`, taker callback |
| **Tests** | `TakeTest.sol`, `PoC_TakeCallbackReentrancy.t.sol` |
| **Hooks** | Double-take same group; callback reenter; cap rounding; reduceOnly; post-maturity debt |

### `Midnight.liquidate`

| Field | Detail |
|---|---|
| **Mutates** | `position` debt/collateral/bitmap, `lossFactor`, `totalUnits`, `withdrawable`, `continuousFeeCredit` |
| **External** | `IOracle.price` (loop), `ILiquidatorGate`, `ILiquidateCallback`, ERC20 out + in |
| **Reentrancy** | Collateral out → `onLiquidate` → loan pull |
| **Trust** | `collateralIndex`, `seizedAssets`/`repaidUnits`, oracle |
| **Tests** | `LiquidationTest.sol` |
| **Hooks** | Zero-repay bad debt; healthy liquidate; over-seize; post-maturity LIF |

### `Midnight.repay`

| Field | Detail |
|---|---|
| **Mutates** | `position.debt`, `marketState.withdrawable` **before** transfer |
| **External** | `IRepayCallback` then `transferFrom` |
| **Reentrancy** | **Callback before pull** — reenter withdraw/liquidate/take |
| **Trust** | `units`, callback payer |
| **Tests** | repay tests in `TakeTest` / `OtherFunctionsTest` |
| **Hooks** | Inflate withdrawable without tokens; nested liquidation |

### `Midnight.withdraw`

| Field | Detail |
|---|---|
| **Mutates** | `_updatePosition` first; credit, pendingFee, `withdrawable`, `totalUnits` |
| **External** | ERC20 transfer out |
| **Reentrancy** | Low after state finalized |
| **Trust** | `onBehalf` auth |
| **Tests** | withdraw fuzz tests |
| **Hooks** | Over-withdraw vs slashed credit |

### `Midnight.supplyCollateral` / `withdrawCollateral`

| Field | Detail |
|---|---|
| **Mutates** | `collateral[]`, `collateralBitmap` |
| **External** | ERC20; **withdraw** calls `isHealthy` (oracle loop) |
| **Reentrancy** | Supply: transfer only; withdraw: health then transfer |
| **Trust** | `collateralIndex`, auth |
| **Tests** | collateral tests, `GateTest` |
| **Hooks** | Bitmap desync; phantom index; supply without oracle |

### `Midnight.flashLoan`

| Field | Detail |
|---|---|
| **Mutates** | transient balance only if repaid |
| **External** | send → `onFlashLoan` → pull |
| **Reentrancy** | Full window during callback |
| **Tests** | `FlashloanTest.sol` |
| **Hooks** | Reenter take/repay without repayment |

---

## P0 — Periphery bundles

| Function | Mutates | External | Reentrancy | Tests |
|---|---|---|---|---|
| `buyWithUnitsTargetAndWithdrawCollateral` | router ERC20 | `MIDNIGHT.take`, referral transfer | per-leg try/catch | `MidnightBundlesTest` |
| `supplyCollateralAndSellWithUnitsTarget` | router + collateral | supply + sell takes | sell callbacks | + `PoC_BundleTemporaryBalanceReentrancy` |
| `buyWithAssetsTargetAndWithdrawCollateral` | router | libs + take | helper revert atomic | `TakeAmountsTest` |
| `supplyCollateralAndSellWithAssetsTarget` | router | same | nested bundle | closed C-26 |
| `repayAndWithdrawCollateral` | router | repay + withdrawCollateral | repay CB | bundles tests |

Internal: `pullToken` — **always `from = msg.sender`** (Permit2/ERC2612 closed for victim drain).

---

## P1 — Auth, ratification, market lifecycle

| Function | Priority | Attack hooks |
|---|---|---|
| `EcrecoverRatifier.isRatified` / `SetterRatifier.isRatified` | P1 | canceled root; proof malleability; field binding |
| `setIsAuthorized` | P1 | delegate scope (duplicate L-16) |
| `setConsumed` | P1 | grief maker groups |
| `touchMarket` | P1 | fee default race (duplicate Spearbit) |
| `updatePosition` | P1 | slash sync; terminal lossFactor |
| `claimSettlementFee` / `claimContinuousFee` | P1 | over-claim vs accrued |
| Fee setters | P1 | stale offers (duplicate) |

---

## P2 — Admin and views

| Function | Notes |
|---|---|
| `setRoleSetter` etc. | P3-01 footgun proven Low |
| `multicall` | delegatecall batch — role ops only |
| `isHealthy`, `settlementFee`, getters | Used in attack setup |

---

## Priority audit order

```text
take → liquidate → repay → withdraw → collateral → flashLoan
→ MidnightBundles (5 routes) → ratifiers → updatePosition/fees
```

See [../protocolIntent/15_AGENTIC_AUDITOR_PLAYBOOK.md](../protocolIntent/15_AGENTIC_AUDITOR_PLAYBOOK.md).
