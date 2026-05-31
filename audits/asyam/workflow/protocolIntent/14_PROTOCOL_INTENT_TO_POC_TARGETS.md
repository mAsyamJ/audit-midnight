# Protocol Intent to PoC Targets

Date: 2026-05-30

Format per target. **Status:** Open | Closed-disproven | Closed-invalid | Closed-proven | Closed-duplicate

---

### POC-INTENT-001 — take callback monetizes temporary credit/debt before final transfer

- **Protocol intention:** Position updates precede transfers; callbacks must not extract value from transient state.
- **Invariant:** INV-005, INV-023
- **Files/functions:** `Midnight.take`, `onBuy`/`onSell`
- **Setup:** Malicious callback contract; funded payer.
- **Attack sequence:** Reenter `take` or drain payer during callback window.
- **Expected assertion:** Attacker profit > 0 or `totalUnits` mismatch.
- **Severity if true:** High
- **False-positive risk:** Medium — seller liquidation lock
- **Candidate:** MIDNIGHT-CAND-014
- **Status:** **Closed-disproven** — `test/asyam/poc/PoC_TakeCallbackReentrancy.t.sol`
- **Test file:** above

---

### POC-INTENT-002 — take consumed cap mismatch with maxAssets/maxUnits and settlement fee

- **Protocol intention:** Group caps include asset-denominated consumption including fee side.
- **Invariant:** INV-011
- **Files/functions:** `take`, `consumed`
- **Setup:** Grouped offers shared `maxAssets`.
- **Attack sequence:** Repeated fills with rounding to exceed cap.
- **Expected assertion:** `newConsumed > maxAssets`
- **Severity if true:** Medium
- **False-positive risk:** Low
- **Candidate:** MIDNIGHT-CAND-005
- **Status:** **Closed-duplicate/disproven** — `PoC_OfferConsumedCapRounding.t.sol`

---

### POC-INTENT-003 — reduceOnly offer increases maker economic exposure

- **Protocol intention:** reduceOnly forbids new maker credit (buy) or debt (sell).
- **Invariant:** INV-012
- **Files/functions:** `take` reduceOnly check
- **Setup:** reduceOnly buy offer; fuzz units.
- **Attack sequence:** Fill for 1 wei over debt closure.
- **Expected assertion:** `MakerCreditOrDebtIncreased` OR credit created
- **Severity if true:** Medium
- **Candidate:** MIDNIGHT-CAND-012
- **Status:** **Closed-disproven** — `PoC_DeepValidationQueues.t.sol`, `Validation_LiveQueues.t.sol`

---

### POC-INTENT-004 — liquidation realizes badDebt while borrower economically solvent

- **Protocol intention:** Bad debt only when collateral at maxLif cannot cover debt.
- **Invariant:** INV-007, INV-008
- **Files/functions:** `liquidate` badDebt loop
- **Setup:** Oracle price manipulation within market consent model.
- **Attack sequence:** Liquidate with mispriced oracle while solvent under fair price.
- **Expected assertion:** `badDebt > 0` with positive economic collateral
- **Severity if true:** High (if permissionless victim) / Info (market risk)
- **Candidate:** MIDNIGHT-CAND-018
- **Status:** **Open** (duplicate-risk zero oracle) — novel path only
- **Test file:** `test/asyam/poc/PoC_LiquidationSolventBadDebt.t.sol` (proposed)

---

### POC-INTENT-005 — liquidation seizes too much collateral under extreme oracle/rounding

- **Protocol intention:** Seizure bounded by LIF and collateral balance.
- **Invariant:** INV-010
- **Files/functions:** `liquidate` seize branch
- **Setup:** Extreme prices, partial liquidation.
- **Expected assertion:** `seizedAssets > collateral` or lender loss
- **Severity if true:** High
- **Status:** **Open**
- **Test file:** proposed `PoC_LiquidationOverSeize.t.sol`

---

### POC-INTENT-006 — post-maturity liquidation differs from settlement model

- **Protocol intention:** Post-maturity unwind without new debt; LIF decay.
- **Invariant:** INV-010, maturity rules
- **Files/functions:** `liquidate(postMaturityMode=true)`
- **Setup:** Matured market; underwater borrower.
- **Attack sequence:** Compare post-maturity vs pre-maturity outcomes at same economic state.
- **Expected assertion:** Inconsistent `repaidUnits`/seizure vs whitepaper
- **Severity if true:** Medium
- **Status:** **Open**
- **Test file:** proposed

---

### POC-INTENT-007 — multi-collateral bitmap/index desync

- **Protocol intention:** Bitmap matches non-zero collateral slots.
- **Invariant:** INV-010, health aggregation
- **Files/functions:** `supplyCollateral`, `withdrawCollateral`, `liquidate` loop
- **Setup:** 2+ collaterals; selective withdraw.
- **Attack sequence:** Desync bitmap vs array; liquidate wrong index.
- **Expected assertion:** Hidden debt or unliquidatable insolvent position
- **Severity if true:** High
- **Candidate:** MIDNIGHT-CAND-033
- **Status:** **Open**
- **Test file:** proposed `PoC_CollateralBitmapDesync.t.sol`

---

### POC-INTENT-008 — lossFactor update over-slashes lenders

- **Protocol intention:** Slash proportional to unrecoverable debt only.
- **Invariant:** INV-008, INV-029
- **Files/functions:** `liquidate`, `updatePositionView`
- **Setup:** Multiple lenders; partial bad debt.
- **Expected assertion:** Lender credit after update < fair share
- **Severity if true:** High
- **Status:** **Open**
- **Test file:** proposed

---

### POC-INTENT-009 — withdrawable exceeds actual repaid/recovered loan tokens

- **Protocol intention:** `withdrawable` backed by custody.
- **Invariant:** INV-003, INV-006
- **Files/functions:** `repay`, `withdraw`, `liquidate`
- **Setup:** Partial repay sequence.
- **Attack sequence:** Withdraw more than token balance allows.
- **Expected assertion:** `withdraw` succeeds with insolvent custody
- **Severity if true:** High
- **Candidate:** MIDNIGHT-CAND-020
- **Status:** **Open**
- **Test file:** proposed

---

### POC-INTENT-010 — pendingFee/continuousFee desync allows fee extraction

- **Protocol intention:** Fees accrue only through `updatePosition` math.
- **Invariant:** INV-004
- **Files/functions:** `_updatePosition`, `take`, `claimContinuousFee`
- **Setup:** Terminal `lossFactor`; skip updates.
- **Expected assertion:** Claim fees without corresponding credit accrual
- **Severity if true:** Medium
- **Candidate:** MIDNIGHT-CAND-021, C-034
- **Status:** **Open**
- **Test file:** proposed

---

### POC-INTENT-011 — ratifier root cancellation bypass

- **Protocol intention:** Canceled roots cannot ratify fills.
- **Invariant:** INV-016
- **Files/functions:** `SetterRatifier`, `EcrecoverRatifier`
- **Setup:** Cancel root; replay old proof.
- **Expected assertion:** `take` succeeds after cancel
- **Severity if true:** Medium
- **Status:** **Open** (protocol tests cover happy path)
- **Test file:** extend `test/ratifier/`

---

### POC-INTENT-012 — delegated root manager grief exceeds authorization

- **Protocol intention:** Delegation scope acceptable to maker.
- **Invariant:** INV-018
- **Files/functions:** `setIsAuthorized`, ratifier admin
- **Setup:** Delegate cancels all roots.
- **Expected assertion:** Maker cannot trade (grief)
- **Severity if true:** Low (operational)
- **Candidate:** MIDNIGHT-CAND-025
- **Status:** **Closed-duplicate** accepted risk
- **Test file:** N/A

---

### POC-INTENT-013 — signature does not bind all economic fields

- **Protocol intention:** EIP-712 digest includes offer fields.
- **Invariant:** INV-017
- **Files/functions:** `HashLib`, `EcrecoverRatifier`
- **Setup:** Sign offer A; mutate field; use proof.
- **Expected assertion:** Fill with altered tick/maturity
- **Severity if true:** High
- **Status:** **Partial** — L-01 malleability only (Low)
- **Test file:** `PoC_SignatureMalleability.t.sol`

---

### POC-INTENT-014 — periphery temporary balance leakage through nested call

- **Protocol intention:** Router uses per-leg amounts; nested sells cannot spend parked proceeds.
- **Invariant:** INV-019
- **Files/functions:** `MidnightBundles` sell + callback
- **Setup:** Multi-leg sell; reentrant bundle in callback.
- **Expected assertion:** Outer leg proceeds stolen
- **Severity if true:** High
- **Candidate:** MIDNIGHT-CAND-026
- **Status:** **Closed-disproven** — `PoC_BundleTemporaryBalanceReentrancy.t.sol`

---

### POC-INTENT-015 — periphery exact target assets impossible due to inverse rounding

- **Protocol intention:** Exact targets reachable when liquidity exists.
- **Invariant:** INV-020
- **Files/functions:** `TakeAmountsLib`, `ConsumableUnitsLib`
- **Setup:** Valid offers; realistic prices.
- **Expected assertion:** Bundle reverts though manual take would succeed
- **Severity if true:** Low/Medium
- **Status:** **Open** (duplicate-risk Blackthorn L-6/L-7)
- **Test file:** fuzz vs `MidnightBundlesTest`

---

### POC-INTENT-016 — pre-try/catch helper revert makes documented skip behavior false

- **Protocol intention:** Documented skip only on core failures.
- **Invariant:** INV-022
- **Files/functions:** bundle outer route + libs
- **Setup:** Helper reverts on valid input.
- **Expected assertion:** Whole tx reverts vs partial fill
- **Severity if true:** Low
- **Status:** **Open**
- **Test file:** proposed

---

### POC-INTENT-017 — Permit2 signature used for unintended operation

- **Protocol intention:** Permit binds token, amount, spender, nonce.
- **Invariant:** periphery pull semantics
- **Files/functions:** `pullToken`, Permit2
- **Setup:** Relayer with user permit.
- **Expected assertion:** Different bundle function drains user
- **Severity if true:** Medium
- **Candidate:** MIDNIGHT-CAND-032
- **Status:** **Closed-invalid** per `04_PROTOCOL_TEST_INTENT_MAP`
- **Test file:** N/A

---

### POC-INTENT-018 — oracle/gate liveness forced on victim

- **Protocol intention:** Users choose markets knowingly.
- **Invariant:** INV-025
- **Files/functions:** gates, oracle in `withdrawCollateral`
- **Setup:** Victim position on market they didn't opt into (if possible).
- **Expected assertion:** Funds locked with no escape
- **Severity if true:** High
- **Status:** **Open** (usually market risk)
- **Test file:** proposed

---

### POC-INTENT-019 — flashLoan repayment check bypass or duplicate accounting

- **Protocol intention:** Loan token returned in full after callback.
- **Invariant:** INV-001 custody
- **Files/functions:** `flashLoan`
- **Setup:** Reentrant flash + take.
- **Expected assertion:** Midnight loan token balance deficit
- **Severity if true:** High
- **Status:** **Open**
- **Test file:** proposed `PoC_FlashLoanReentrancy.t.sol`

---

### POC-INTENT-020 — maturity-boundary one-second transition inconsistent accounting

- **Protocol intention:** Smooth fee bucket and debt rules at `maturity`.
- **Invariant:** INV-014, maturity
- **Files/functions:** `take` at `timestamp == maturity`
- **Setup:** Warp to maturity; take sell/buy.
- **Expected assertion:** Unexpected revert or debt increase
- **Severity if true:** Medium
- **Candidate:** MIDNIGHT-CAND-013
- **Status:** **Open**
- **Test file:** proposed

---

### POC-INTENT-021 — repay callback reentrancy before pull

- **Protocol intention:** Debt reduced before external call; loan tokens must still arrive.
- **Invariant:** INV-023
- **Files/functions:** `repay`, `onRepay`
- **Setup:** Reenter withdraw/liquidate during `onRepay`.
- **Expected assertion:** Profit or `withdrawable` inflation without transfer
- **Severity if true:** High
- **Candidate:** MIDNIGHT-CAND-022
- **Status:** **Open**
- **Test file:** proposed `PoC_RepayCallbackReentrancy.t.sol`

---

### POC-INTENT-022 — CVL market ID aliasing confuses off-chain integrations (formal)

- **Protocol intention:** Production IDs unique per full market config.
- **Invariant:** Formal proof soundness (not user funds)
- **Status:** **Closed-proven P3-02** — `PoC_SolvencySpecMarketIdAliasing.t.sol`
- **Severity if true:** Informational / formal

---

## Top 10 open targets (priority)

1. POC-INTENT-007 — multi-collateral bitmap
2. POC-INTENT-021 — repay callback reentrancy
3. POC-INTENT-010 — pendingFee/lossFactor desync
4. POC-INTENT-020 — maturity boundary
5. POC-INTENT-009 — withdrawable vs custody
6. POC-INTENT-019 — flash loan composition
7. POC-INTENT-006 — post-maturity liquidation model
8. POC-INTENT-004 — bad debt on solvent borrower (novel oracle path)
9. POC-INTENT-011 — canceled root bypass
10. POC-INTENT-059 class — nested callback + bundle beyond C-26

## Next command

```bash
forge test --match-path 'test/asyam/poc/PoC_DeepValidationQueues.t.sol' -vvvv
```

Then implement highest-open target under `test/asyam/poc/`.
