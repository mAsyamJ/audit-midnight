# Incentive and Market Manipulation Hunt

Date: 2026-05-31

| ID | Rational attacker goal | Sequence | Possible victim loss | Market risk or protocol bug hurdle | PoC feasibility |
|---|---|---|---|---|---|
| IM-001 | Externalize recoverable debt as lender loss | Borrow -> price boundary -> partial liquidation -> zero-realize | Lender slash | Bug only if recoverable value remains and path is realistic | High |
| IM-002 | Win first-claimer race across same-token markets | Accrue fees A -> repay B -> claim A -> withdraw B | Lender freeze | Must violate aggregate backing, not just disclosed race | High |
| IM-003 | Force unfavorable lender crystallization | Realize loss -> permissionless `updatePosition(lender)` before lender plan | Reduced exit | Likely intended; bug only if ordering changes economics | Medium |
| IM-004 | Route delegated borrower into materially worse fallback | Prepare valid legs -> invalidate first -> execute second | Extra debt or worse collateral risk | Explicit args must fail to bound harm | Medium |
| IM-005 | Collect referral on an economically different route | Choose fallback and referral threshold | Route-user value loss | Must exceed user-provided bounds | Medium |
| IM-006 | Use permissionless market creation as contamination | Create malicious oracle market -> induce route selection | User position trapped | Need missing consent boundary | Medium |
| IM-007 | Leave competitors with unfillable signed quotes | Fee change or consumed front-run | Maker/taker DoS | Likely market behavior or duplicate | Low |
| IM-008 | Delay liquidation until collateral worsens | Gate blocks -> price declines -> gate opens | Lender loss | Chosen gate risk unless propagated to non-consenting user | Low unless boundary crossed |
| IM-009 | Choose collateral seizure order maximizing avoidable social loss | Activate multiple collaterals -> liquidate preferred token first | Lenders lose more | Preference documented; need avoidable protocol-created loss | Medium |
| IM-010 | Exploit RCF deactivation threshold | Construct residual just below threshold -> full liquidation | Borrower collateral loss | Parameter risk unless attacker controls transition | Medium |
| IM-011 | Roll lender realized cash into fresh risk | Repay -> race resting sell offer -> lender withdrawal delayed | Lender exposure | Blackthorn L-15 duplicate unless new route path | Low |
| IM-012 | Create many micro-defaults to flip later branch | Repeat default/touch cycles | Lender material loss | Must exceed dust and gas cost | Medium |
| IM-013 | Exploit token-global fee reserve opacity | Build fee claim in A, liabilities in B/C | Valid exit freezes | Formal solvency may disprove | High-value probe |
| IM-014 | Use stale quote to alter units while target assets stays fixed | Quote -> warp fee breakpoint -> execute assets target | Borrower debt differs | Explicit `maxUnits` may defend | Medium |
| IM-015 | Lock position by activating liveness-hostile collateral before delegated debt | Supply bad collateral -> route debt | Borrower freeze | Need attacker ability without borrower consent | Medium |
| IM-016 | Exploit signed auth ordering to regain revoked capability | Sign grants/revokes -> submit reordered txs -> route | Asset or collateral loss | Nonce likely defends; test distinct authority surfaces | Medium |
| IM-017 | Use zero paths for cheap state activation | Zero repay/supply/route -> creation or approval state | Unexpected later behavior | Likely harmless no-op | Low |
| IM-018 | Create deceptive near-identical markets for indexer | Touch markets differing in gate/oracle/threshold | UI-routed loss | UI-dependent unless core/periphery omits consent tuple | Low |
| IM-019 | Force borrower to retain dust debt and oracle dependency | Repay debt-1 through fee-bearing bundle | Locked collateral | Caller controls fee; likely user error unless relayed scope flaw | Medium |
| IM-020 | Claim continuous fees before all lazy lenders are touched | Accrue -> repay -> claim -> touch fragmented lenders | Lender payout shortfall | Prior one-market probe; aggregate variant remains | Medium |

## Escalation Filter

An incentive strategy is a protocol issue only when the code creates loss beyond accepted market parameters or permits a
realistic actor to impose the risky state on a non-consenting user.
