# Protocol Assumption Inversion

Date: 2026-05-31

| ID | Assumption | Inversion | Affected path | Validity hurdle | PoC idea |
|---|---|---|---|---|---|
| AI-001 | Stored credit is an adequate user-facing claim | Effective credit differs until touch | `creditOf`, `updatePositionView` | Docs disclose stale getters | Prove material later decision flip |
| AI-002 | Socialized loss is unrecoverable debt | Sequence socializes debt before all recovery options settle | `liquidate` | Avoid Blackthorn L-10 duplicate | Partial-liquidation recoverability PoC |
| AI-003 | Per-market solvency implies protocol solvency | Shared token custody couples isolated markets | claims, withdrawals | Formal strong invariant may defend | Aggregate runtime invariant |
| AI-004 | Global fee bucket is harmless aggregation | Fee claim competes with local lender claims | `claimableSettlementFee` | Must show deficit | Same-token claim ordering |
| AI-005 | Bundle max spend expresses user intent | Collateral withdrawal or debt profile matters too | bundle buy | User authorizes route | Bound-compliant side-effect test |
| AI-006 | Bundle min receive expresses borrower intent | Same receive may open materially different debt | bundle sell | `maxUnits` likely defends | Fallback route test |
| AI-007 | Referral fee is only value split | Referral rounding changes route target and units | bundles | Existing referral tests | Threshold route test |
| AI-008 | Failed route legs are interchangeable skips | Skip selects materially worse valid exposure | loops | Docs disclose skip | Require missing explicit bound |
| AI-009 | Users choose safe markets | Relayer or fallback selects bad market | `touchMarket`, bundles | Same-market route check may defend | Consent boundary test |
| AI-010 | Bad oracle risk is market-local | Shared component propagates lock or deficit | health/liquidate | Need non-consenting party | Cross-market boundary |
| AI-011 | Bad gate risk is selected by participants | Delegate routes user into gated market | bundles | Broad auth may be consent | Scope PoC |
| AI-012 | Authorization is one relationship | Other contracts reuse mapping as ambient capability | core, ratifiers, authorizer | Explicit NatSpec warns users | Prove authority without action |
| AI-013 | Revoking a delegate ends its effects | Previously signed independent intent remains usable | authorizer, ratifier | Could be intended signature semantics | Ordering PoC |
| AI-014 | Root cancellation is sufficient order kill switch | Another authority path activates distinct root family | ratifiers | Different root may be legitimate | Chained intent test |
| AI-015 | Maturity is one state transition | Fee, debt increase, and liquidation mode switch separately | `take`, `liquidate` | Direct maturity covered | Multi-route temporal matrix |
| AI-016 | RCF threshold only mitigates gas-cost positions | One wei permits full liquidation | `liquidate` | Intended threshold policy | Quantify non-dust collateral difference |
| AI-017 | Multi-collateral improves flexibility | Liquidator ordering creates avoidable social loss | `liquidate` | Preference documented | Compare order outcomes |
| AI-018 | Debt-zero collateral exit is simple | Bundle fee leaves dust debt and oracle lock | bundle repay | Caller-selected fee | Relayer scope test |
| AI-019 | Permissionless `updatePosition` is benign | Third party crystallizes a timing-sensitive state | update | Accrual economics likely intended | Compare forced and delayed touch |
| AI-020 | Events reconstruct storage | Lazy effective state requires off-chain recomputation | events | P3 unless loss path | Replay event mirror |
| AI-021 | Similar markets remain distinguishable | Indexer may collapse risk parameters | `MarketCreated`, UI | Core full ID safe | Replay complete tuple |
| AI-022 | Bitmap optimization only saves gas | Bitmap bit controls liveness and oracle loop | bitmap, health | Lifecycle tests strong | Zero/nonzero sequence fuzz |
| AI-023 | No-op calls have no economic effect | No-op creates market or approval precondition | touch/route | Usually harmless | Zero-path state diff |
| AI-024 | Standard ERC20 eliminates custody surprises | Valid cross-market ordering can still starve claims | transfers | Solvency invariant likely defends | Runtime aggregate check |
| AI-025 | Market creator parameters affect only that market | Shared token-global fee bucket crosses markets | global fee | Need actual deficit | Fee ordering |
| AI-026 | Quote staleness only causes revert | Valid fallback changes economic side effect | routes | Explicit bounds likely defend | Quote-settlement PoC |
| AI-027 | Exact-fill route arithmetic captures all value | Route state changes between helper and core leg | helpers/core | Each call synchronous | Multi-leg state-changing callback only if new root |
| AI-028 | Cap families are maker-controlled | Mixed groups produce ambiguous intent | consumed | Docs warn makers | User-error filter |
| AI-029 | Formal proof covers runtime composition | Summaries exclude callbacks, periphery, and identities | Certora | Formal gap alone is P3 | Map executable runtime test |
| AI-030 | Disclosed races remain bounded | Rational attacker combines race with threshold flip | take/withdraw/fees | Duplicate if simple rollover | Threshold-to-loss PoC |
