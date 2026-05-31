# Attacker Playbooks

Date: 2026-05-30

Setup base: [`test/asyam/Config.t.sol`](../../../../test/asyam/Config.t.sol) extends [`test/BaseTest.sol`](../../../../test/BaseTest.sol).

---

## PB-Liquidator

**Goal:** Seize collateral / realize bad debt profitably.

**Prerequisites:** Borrower with `debt > 0`; unhealthy or post-maturity mode; funded liquidator.

**Calls:**
1. `touchMarket` (if needed)
2. `liquidate(market, collateralIndex, seized, repaid, borrower, postMaturity, receiver, callback, data)`

**Assertions:**
- Pre: `NotLiquidatable` when healthy (pre-maturity)
- Post: `debt` decreased; collateral decreased; if bad debt, `lossFactor` increased

**False positives:** Zero oracle (duplicate); gate revert (intended).

---

## PB-CallbackTaker

**Goal:** Profit via reentrancy during `take`.

**Prerequisites:** Malicious `IBuyCallback`/`ISellCallback`; lender funded for pull.

**Calls:**
1. Deploy `ReentrantCallback` mock
2. `take` with callback pointing to mock
3. In callback: try `take` again / `liquidate` / `withdraw`

**Assertions:** No net profit; `consumed` cap holds on double-take.

**Evidence:** `PoC_TakeCallbackReentrancy.t.sol` — closed.

---

## PB-BundleRelayer

**Goal:** Exact fill with referral within total budget.

**Prerequisites:** `MidnightBundles`; offers on same market; `maxBuyerAssets` = total budget.

**Calls:** `buyWithUnitsTargetAndWithdrawCollateral(...)`

**Assertions:** Router balance 0 after; referral paid; revert if budget - 1 wei.

**Evidence:** C-29 invalid; `Validation_LiveQueues.t.sol`.

---

## PB-RatifierGriefer

**Goal:** Block maker fills via root cancel / `setConsumed`.

**Prerequisites:** Authorized delegate on maker.

**Calls:** `cancelRoot` or `setConsumed(max)`

**Assertions:** Subsequent `take` fails ratifier or cap.

**Verdict:** Intended delegation (duplicate L-16).

---

## PB-MarketGriefer

**Goal:** Trap users with malicious oracle/gate.

**Prerequisites:** Create market with reverting oracle.

**Calls:** `touchMarket` → victim trades → `withdrawCollateral` reverts.

**Verdict:** Accepted market-design unless victim did not consent.

---

## PB-LenderSlash

**Goal:** Exploit `lossFactor` timing vs `updatePosition`.

**Prerequisites:** Bad debt event; multiple lenders.

**Calls:**
1. `liquidate` realizing bad debt
2. Lender A skips `updatePosition`; Lender B updates; compare `credit`

**Assertions:** Stale `lastLossFactor` cannot withdraw inflated credit.

**Links:** AP-008, AP-010.

---

## PB-FlashBorrower

**Goal:** Use `flashLoan` to manipulate inner state without repayment.

**Prerequisites:** Midnight holds loan tokens or callback pulls.

**Calls:** `flashLoan(tokens, amounts, callback, data)` → inner `take`/`repay`

**Assertions:** End balance of Midnight unchanged; callback magic return.

**Links:** AP-019 (open).

---

## PB-RepayReentrant

**Goal:** Inflate `withdrawable` before loan tokens arrive.

**Calls:** `repay` with callback → `withdraw` in `onRepay`

**Assertions:** Withdraw reverts or custody sufficient.

**Verdict:** closed-duplicate-risk C-022.
