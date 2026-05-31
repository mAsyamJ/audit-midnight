# Economic Attack Surfaces

Date: 2026-05-30

At least **45** surfaces. Columns: ID, concept, actors, files/functions, invariant, severity if proven, difficulty, evidence, next test.

---

## 1. Market creation and IDs

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-001 | Market ID collision | Creator | `IdLib.toId` | INV-001 | Critical | Low | **INTENDED** full encode | None |
| AS-002 | CVL vs prod ID alias | Auditor | `CVL_toId` | Formal | Info | Done | **Proven P3-02** | N/A |
| AS-003 | touchMarket fee defaults race | First taker | `touchMarket` | Fees | Low | Med | Duplicate Spearbit | Dedup |
| AS-004 | Immutable param grief | Creator | create market | — | Low | Low | INTENDED | — |
| AS-005 | rcfThreshold recovery abuse | Liquidator | `liquidate` | INV-010 | Med | High | Design | Fuzz close factor |

## 2. Offer / rate / tick pricing

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-006 | Tick zero price | Maker | `TickLib` | Pricing | Low | Low | Duplicate L-24 | — |
| AS-007 | Settlement fee bucket boundary | Taker | `settlementFee` | INV-014 | Low | Med | C-013 open | Maturity fuzz |
| AS-008 | buy price > WAD unreachable | Bundler | `TakeAmountsLib` | — | Low | Low | INTENDED | — |
| AS-009 | Fee increase cancels low ticks | Fee setter | fees | — | Low | Low | INTENDED | — |
| AS-010 | Self-take | Maker | `take` | — | — | Low | Reverts | — |

## 3. Assets / units conversion

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-011 | Rounding cap bypass | Taker | `take` mulDiv | INV-011 | Med | Med | **Closed** C-05 | — |
| AS-012 | reduceOnly unit bypass | Taker | `take` | INV-012 | Med | Med | **Closed** C-12 | — |
| AS-013 | Post-maturity debt increase | Taker | `take` | Maturity | Med | Low | Reverts | Boundary sec |
| AS-014 | maxAssets vs maxUnits confusion | Maker | offer | INV-011 | Med | Low | Enforced | — |

## 4. Credit / debt lifecycle

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-015 | Credit without updatePosition slash | Lender | `withdraw` | INV-004 | Med | Med | Certora UpdateBeforeCredit | Fuzz |
| AS-016 | Stale lastLossFactor | Lender | `take`/`withdraw` | INV-004 | Med | Med | Open C-021 | PoC |
| AS-017 | Terminal lossFactor fresh lender | Lender | `updatePosition` | Slash | Med | Med | Duplicate M-1 | Dedup |
| AS-018 | max lossFactor blocks take | Taker | `take` | — | — | Low | INTENDED | — |

## 5. Collateral and health

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-019 | Supply without oracle | Borrower | `supplyCollateral` | — | — | Low | INTENDED | — |
| AS-020 | Withdraw while unhealthy | Borrower | `withdrawCollateral` | Health | High | Low | Reverts | — |
| AS-021 | Bitmap desync | Borrower | collateral[] | INV-010 | High | High | Open C-033 | PoC |
| AS-022 | Too many collaterals | Borrower | bitmap | — | — | Low | Reverts | — |
| AS-023 | Phantom collateral block | Attacker | activate | — | Info | Med | Spearbit info | Dedup |

## 6. Liquidation and bad debt

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-024 | Liquidate healthy | Liquidator | `liquidate` | INV-007 | High | Med | Open | PoC-004 |
| AS-025 | Zero oracle liquidation | Liquidator | `liquidate` | Bad debt | Med | Med | Duplicate | Dedup |
| AS-026 | Zero-repay bad debt realize | Liquidator | `liquidate` | INV-008 | Med | Med | Duplicate L-10 | Dedup |
| AS-027 | Over-seize collateral | Liquidator | `liquidate` | INV-010 | High | Med | Open | PoC-005 |
| AS-028 | Post-maturity LIF edge | Liquidator | `liquidate` | INV-010 | Med | Med | Open | PoC-006 |

## 7. Loss socialization

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-029 | lossFactor overslash | All lenders | `liquidate` | INV-008 | High | High | Open | PoC-008 |
| AS-030 | totalUnits desync on bad debt | Protocol | `liquidate` | INV-001 | High | Med | Certora | Fuzz |
| AS-031 | continuousFeeCredit on slash | Fee claimer | `liquidate` | Fees | Low | Med | Spec | Review |

## 8. Fees

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-032 | Settlement fee theft | Taker | `take` | INV-014 | Med | Med | Open | Audit spreads |
| AS-033 | Continuous fee extraction | Lender | `updatePosition` | INV-004 | Med | Med | Open C-034 | Dust fuzz |
| AS-034 | Fee claim > accrued | Fee claimer | `claim*` | INV-FEE | Med | Low | Certora | — |
| AS-035 | Pending fee rounding loop | Maker | self-transfer | — | Low | Med | Duplicate L-9 | Dedup |

## 9. Ratification / signatures

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-036 | High-s malleability | Relayer | `ecrecover` | Uniqueness | Low | Low | **Proven L-01** | — |
| AS-037 | Root cancel grief | Delegate | ratifier | INV-016 | Low | Med | Duplicate | Dedup |
| AS-038 | Merkle proof length gas | Maker | `SetterRatifier` | — | Gas | Low | Park | — |
| AS-039 | Cross-deployment replay | Maker | ratifier | INV-015 | Med | Med | Spearbit Low | Dedup |

## 10. Authorization / delegation

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-040 | Operator excessive power | Delegate | `setIsAuthorized` | INV-018 | Low | Low | INTENDED | — |
| AS-041 | Taker not authorized | Taker | `take` | — | — | Low | Reverts | — |
| AS-042 | setConsumed grief | Maker | `setConsumed` | — | Low | Low | INTENDED cancel | — |

## 11. Periphery routing

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-043 | Router balance theft | Attacker | `MidnightBundles` | INV-019 | High | High | **Closed** C-26 | — |
| AS-044 | Referral underflow | User | buy units target | INV-021 | Med | Med | **Closed** C-29 | — |
| AS-045 | Helper revert DoS | User | libs before try | INV-022 | Low | Med | Open | PoC-016 |
| AS-046 | Exact fill impossible | User | `TakeAmountsLib` | INV-020 | Low | Med | Dup-risk | Fuzz |
| AS-047 | Mixed market bundle | User | bundles | — | — | Low | **Invalid** | — |

## 12. Callbacks / reentrancy

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-048 | Take callback profit | Attacker | `take` | INV-023 | High | High | **Closed** C-14 | — |
| AS-049 | Repay callback reenter | Attacker | `repay` | INV-023 | High | High | Open C-022 | PoC |
| AS-050 | Liquidate callback allowance | Liquidator | `liquidate` | — | Med | Med | Duplicate L-26 | Dedup |
| AS-051 | Flash loan reentrancy | Attacker | `flashLoan` | Solvency | High | Med | Open | PoC-019 |

## 13. Oracle / gate liveness

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-052 | Oracle revert DoS withdraw | Borrower | `withdrawCollateral` | Liveness | Low | Low | INTENDED | — |
| AS-053 | Gate blocks liquidation | Liquidator | `liquidatorGate` | INV-009 | Low | Low | INTENDED | — |
| AS-054 | Forced victim gate | Attacker | market choice | INV-025 | High | High | Open | PoC-018 |

## 14. Maturity-boundary transitions

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-055 | Maturity second fee flip | Taker | `take` | INV-014 | Low | Med | Open C-013 | PoC-020 |
| AS-056 | Post-maturity take/liquidate race | All | both | Accounting | Med | High | Open | Composition |

## 15. Multi-market / multi-role

| ID | Concept | Actors | Functions | Invariant | Sev | Diff | Evidence | Next test |
|---|---|---|---|---|---|---|---|---|
| AS-057 | Cross-market isolation | Attacker | `toId` | Isolation | High | Low | INTENDED | — |
| AS-058 | Same token loan=collateral | User | repay/liq | Custody | Med | Med | **Closed** C-31 | — |
| AS-059 | Maker+callback+taker combo | Attacker | composed | INV-023 | High | High | Partial close | New composition |
| AS-060 | Nested bundle during sell CB | Attacker | bundles | INV-019 | High | High | **Closed** C-26 | — |

---

See [protocol_intent_graph.json](protocol_intent_graph.json) for machine-readable `attack_surfaces` entries.
