# Economic Failure Modes

Date: 2026-05-30

Cross-link definitions: [../protocolIntent/01_ECONOMIC_MODEL.md](../protocolIntent/01_ECONOMIC_MODEL.md).

| Mode | Trigger functions | Symptom | Invariant | Sev if proven | Dedup keywords |
|---|---|---|---|---|---|
| Over-withdrawal | `withdraw` | Loan token out > post-slash credit | AP-INV-001 | High | — |
| Custody vs withdrawable desync | `repay`, `liquidate`, `withdraw` | `withdrawable` > `loanToken.balanceOf(Midnight)` | AP-INV-003 | High | C-020 |
| Consumed cap bypass | `take` | `consumed > maxAssets/maxUnits` | INV-011 | Medium | C-005 closed |
| reduceOnly risk increase | `take` | Maker credit/debt up on reduce-only | INV-012 | Medium | C-012 closed |
| Healthy borrower liquidated | `liquidate` | `debt <= maxDebt` but liquidated | AP-INV-007 | High | — |
| Bad debt over-realization | `liquidate` badDebt branch | Lenders slashed > unrecoverable | AP-INV-008 | High | L-10 dup-risk |
| Bad debt under-realization | `liquidate` | Insolvent debt remains | Design | Low | optimistic bad debt |
| lossFactor desync | `liquidate`, `updatePosition` | Credit not slashed after market slash | AP-INV-004 | Medium | C-021 dup |
| Fee extraction | `claim*` | Claim > accrued fees | AP-INV-FEE | Medium | — |
| Maturity boundary arbitrage | `take`, `settlementFee` | Inconsistent fee/debt at `maturity` | INV-014 | Low/Med | C-013 covered |
| Router balance leakage | `MidnightBundles` | Steal parked loan tokens | INV-019 | High | C-26 closed |
| Credit/debt from nothing | `take` | `totalUnits` mismatch vs transfers | AP-INV-005 | High | — |
| Signature domain break | ratifiers | Fill with mutated offer fields | INV-017 | High | L-01 partial |
| Oracle zero liquidation | `liquidate` | Free bad debt at price 0 | — | Med | Spearbit dup |
| Terminal market take | `take` | New credit when lossFactor maxed | — | — | reverts by design |
