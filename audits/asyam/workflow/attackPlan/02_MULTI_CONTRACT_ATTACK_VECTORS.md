# Multi-Contract Attack Vectors

Date: 2026-05-30

Composed paths spanning 2+ contracts. Status from [../POC_RESULTS.md](../POC_RESULTS.md).

---

## MC-01 — Nested bundle during sell callback

- **Sequence:** Outer `supplyCollateralAndSellWithUnitsTarget` → leg1 `onSell` → reenter `supplyCollateralAndSellWithUnitsTarget` while proceeds parked on router.
- **Contracts:** `MidnightBundles` → callback → `MidnightBundles` → `Midnight.take`
- **Invariant:** INV-019 / router only distributes leg proceeds
- **Status:** **closed-disproven** (C-26)
- **Evidence:** `PoC_BundleTemporaryBalanceReentrancy.t.sol`, `Validation_LiveQueues.t.sol`

## MC-02 — Buy callback reenter core

- **Sequence:** `take` with `onBuy` → reenter `take` / `liquidate` / `withdraw`
- **Contracts:** callback + `Midnight`
- **Status:** **closed-disproven** (C-14)
- **Evidence:** `PoC_TakeCallbackReentrancy.t.sol`

## MC-03 — Repay callback reenter before loan pull

- **Sequence:** `repay` reduces debt + increases `withdrawable` → `onRepay` → `withdraw` / `liquidate` before `transferFrom`
- **Contracts:** callback + `Midnight`
- **Status:** **duplicate-risk closed** (C-022 per POC_RESULTS; no novel extraction)
- **Residual:** New composition beyond Blackthorn L-19/L-26 only

## MC-04 — Flash loan → take → repay same tx

- **Sequence:** `flashLoan` → inner `take` + `repay` → verify loan token balance restored
- **Contracts:** `Midnight` only
- **Status:** **closed-disproven** (`PoC_FlashLoanReentrancy.t.sol`, AP-019)
- **AP:** AP-019

## MC-05 — Cancel ratifier root → fill offer

- **Sequence:** `cancelRoot` → submit old Merkle proof on `take`
- **Contracts:** `EcrecoverRatifier` + `Midnight`
- **Status:** **open** (protocol tests cover happy path)
- **AP:** AP-011

## MC-06 — Permit2 → bundle buy → referral

- **Sequence:** User permit → router pull → buy with referral from total budget
- **Contracts:** Permit2 + `MidnightBundles`
- **Status:** **closed-invalid** (third-party drain; `from = msg.sender`)
- **Evidence:** `04_PROTOCOL_TEST_INTENT_MAP.md`

## MC-07 — Multi-collateral oracle composition

- **Sequence:** Supply collateral A and B → move price on B → liquidate on C → health bitmap
- **Contracts:** `Midnight` + 2+ oracles
- **Status:** **disproven/covered** (C-033 bitmap — native + `CollateralBitmap.spec`)
- **Residual:** Novel cross-index desync only

## MC-08 — Same loan token as collateral unwind

- **Sequence:** Market with `loanToken` in collateral set → repay callback pulls collateral → withdraw
- **Contracts:** `Midnight` + callback
- **Status:** **closed-disproven** (C-31)
- **Evidence:** `PoC_DeepValidationQueues.t.sol`, `Validation_LiveQueues.t.sol`

## MC-09 — Signature malleability + authorization

- **Sequence:** Valid sig → high-s malleated sig → `setIsAuthorized` / ratifier fill
- **Contracts:** `EcrecoverRatifier`, `EcrecoverAuthorizer`, `Midnight`
- **Status:** **partial proven** (L-01 Low); not economic field replay
- **Evidence:** `PoC_SignatureMalleability.t.sol`

## MC-10 — Fee setter mid-bundle

- **Sequence:** Bundle loop → external `setMarketSettlementFee` → next `take` sees new fee
- **Contracts:** admin + `MidnightBundles`
- **Status:** **duplicate-risk** (fee staleness L-13)
- **Impact:** Usually self-DoS / stale quote

## MC-11 — Authorizer delegate + ratifier root grief

- **Sequence:** Maker authorizes delegate → delegate `cancelRoot` / `setConsumed`
- **Status:** **duplicate** (L-16 accepted delegation)

## MC-12 — Liquidation callback + liquidator gate

- **Sequence:** `liquidate` with callback → gate checks `msg.sender` only at entry
- **Status:** **duplicate-risk** (L-26 allowance)

## MC-13 — Multicall batch role brick

- **Sequence:** `multicall([setRoleSetter(0), ...])`
- **Status:** **proven footgun** P3-01 (admin)

## MC-14 — touchMarket + immediate take before fees

- **Sequence:** First touch creates market → take with default fees
- **Status:** **duplicate** Spearbit medium

## MC-15 — Bundler as payer on sell take

- **Sequence:** Taker buys sell offer without callback → `msg.sender` (router) is payer after pre-pull
- **Contracts:** `MidnightBundles` → `Midnight.take`
- **Status:** **intended**; zero residual tested in `MidnightBundlesTest`

## MC-16 — Stateful gate changes in callback

- **Sequence:** `take` passes enter gate → callback changes gate state → second leg blocked
- **Status:** **accepted market-design** unless victim forced

## MC-17 — Zero-repay liquidation + oracle zero

- **Sequence:** `liquidate(0,0)` realize bad debt
- **Status:** **duplicate** Spearbit/Blackthorn zero oracle / L-10

## MC-18 — EcrecoverAuthorizer + Midnight authorization replay

- **Sequence:** Sign auth on deployment A, replay on B
- **Status:** **duplicate** Spearbit approval replay lows

## Summary

| Status | Count |
|---|---|
| closed-disproven / invalid | 6 |
| duplicate / duplicate-risk | 6 |
| proven / partial | 2 |
| open / residual composition | 3 |

Open focus: **MC-04** flash composition, **MC-05** root cancel bypass (if novel), **MC-16** forced gate victim (if any).
