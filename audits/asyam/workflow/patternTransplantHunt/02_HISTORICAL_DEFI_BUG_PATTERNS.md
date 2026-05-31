# Historical DeFi Bug Patterns

These are mechanism prompts, not Midnight findings. Each candidate still requires local source reasoning, dedup, and a compiling Foundry PoC.

## Lending Market Accounting

### PATTERN-001 - Lazy Borrower Index Update Before Withdrawal
- Source inspiration: Solodit
- Generic mechanism: A historically recurring lending market accounting assumption fails when `lazy borrower index update before withdrawal` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: lending market accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `lazy borrower index update before withdrawal` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-002 - First Depositor Or Empty-Market Conversion Discontinuity
- Source inspiration: Code4rena reports
- Generic mechanism: A historically recurring lending market accounting assumption fails when `first depositor or empty-market conversion discontinuity` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: lending market accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `first depositor or empty-market conversion discontinuity` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-003 - Shared Custody Counted Twice Across Markets
- Source inspiration: Sherlock public audits
- Generic mechanism: A historically recurring lending market accounting assumption fails when `shared custody counted twice across markets` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: lending market accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `shared custody counted twice across markets` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-004 - Credit And Debt Unit Conversion Ordering
- Source inspiration: Cantina competitions
- Generic mechanism: A historically recurring lending market accounting assumption fails when `credit and debt unit conversion ordering` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: lending market accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `credit and debt unit conversion ordering` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-005 - Withdrawal After Partial Debt Repayment
- Source inspiration: Immunefi blog
- Generic mechanism: A historically recurring lending market accounting assumption fails when `withdrawal after partial debt repayment` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: lending market accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `withdrawal after partial debt repayment` as a local Foundry sequence and assert aggregate backing after the final transition.

## Liquidation And Bad Debt

### PATTERN-006 - Liquidator-Selected Collateral Order Socializes Avoidable Loss
- Source inspiration: DeFiHackLabs
- Generic mechanism: A historically recurring liquidation and bad debt assumption fails when `liquidator-selected collateral order socializes avoidable loss` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: liquidation and bad debt.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `liquidator-selected collateral order socializes avoidable loss` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-007 - Partial Liquidation Leaves Worse Basket
- Source inspiration: SWC Registry
- Generic mechanism: A historically recurring liquidation and bad debt assumption fails when `partial liquidation leaves worse basket` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: liquidation and bad debt.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `partial liquidation leaves worse basket` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-008 - Recoverability Checked Before Final Collateral Seizure
- Source inspiration: SmartBugs
- Generic mechanism: A historically recurring liquidation and bad debt assumption fails when `recoverability checked before final collateral seizure` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: liquidation and bad debt.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `recoverability checked before final collateral seizure` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-009 - Close-Factor Threshold Changes Incentive
- Source inspiration: SmartBugs Curated
- Generic mechanism: A historically recurring liquidation and bad debt assumption fails when `close-factor threshold changes incentive` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: liquidation and bad debt.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `close-factor threshold changes incentive` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-010 - Self-Liquidation Extracts Socialized Value
- Source inspiration: DAppSCAN
- Generic mechanism: A historically recurring liquidation and bad debt assumption fails when `self-liquidation extracts socialized value` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: liquidation and bad debt.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `self-liquidation extracts socialized value` as a local Foundry sequence and assert aggregate backing after the final transition.

## Fixed-Rate / Maturity / Epoch Systems

### PATTERN-011 - Quote Survives Lifecycle Transition
- Source inspiration: AutoMESC
- Generic mechanism: A historically recurring fixed-rate / maturity / epoch systems assumption fails when `quote survives lifecycle transition` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fixed-rate / maturity / epoch systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `quote survives lifecycle transition` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-012 - Exact-Boundary Action Uses Inconsistent Rule
- Source inspiration: ScrawlD
- Generic mechanism: A historically recurring fixed-rate / maturity / epoch systems assumption fails when `exact-boundary action uses inconsistent rule` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fixed-rate / maturity / epoch systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `exact-boundary action uses inconsistent rule` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-013 - Late Updater Bears Accrued State
- Source inspiration: ReEVMBench
- Generic mechanism: A historically recurring fixed-rate / maturity / epoch systems assumption fails when `late updater bears accrued state` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fixed-rate / maturity / epoch systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `late updater bears accrued state` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-014 - Maturity Disables Protective Action Before Settlement
- Source inspiration: Trail of Bits Building Secure Contracts
- Generic mechanism: A historically recurring fixed-rate / maturity / epoch systems assumption fails when `maturity disables protective action before settlement` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fixed-rate / maturity / epoch systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `maturity disables protective action before settlement` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-015 - Epoch Rollover Reuses Stale Accounting Context
- Source inspiration: Local Cyfrin-derived skills
- Generic mechanism: A historically recurring fixed-rate / maturity / epoch systems assumption fails when `epoch rollover reuses stale accounting context` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fixed-rate / maturity / epoch systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `epoch rollover reuses stale accounting context` as a local Foundry sequence and assert aggregate backing after the final transition.

## Offer / Order-Book Systems

### PATTERN-016 - Non-Escrowed Maker Liquidity Disappears After Route Planning
- Source inspiration: Local Slither output
- Generic mechanism: A historically recurring offer / order-book systems assumption fails when `non-escrowed maker liquidity disappears after route planning` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: offer / order-book systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.setConsumed; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `non-escrowed maker liquidity disappears after route planning` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-017 - Partial Fill Consumes A Broader Group Than Intended
- Source inspiration: Solodit
- Generic mechanism: A historically recurring offer / order-book systems assumption fails when `partial fill consumes a broader group than intended` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: offer / order-book systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.setConsumed; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `partial fill consumes a broader group than intended` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-018 - Root Replacement Changes Order-Family Meaning
- Source inspiration: Code4rena reports
- Generic mechanism: A historically recurring offer / order-book systems assumption fails when `root replacement changes order-family meaning` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: offer / order-book systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.setConsumed; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `root replacement changes order-family meaning` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-019 - Failed Order Leg Changes Fallback Economics
- Source inspiration: Sherlock public audits
- Generic mechanism: A historically recurring offer / order-book systems assumption fails when `failed order leg changes fallback economics` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: offer / order-book systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.setConsumed; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `failed order leg changes fallback economics` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-020 - Maker Callback Alters Later Order Execution
- Source inspiration: Cantina competitions
- Generic mechanism: A historically recurring offer / order-book systems assumption fails when `maker callback alters later order execution` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: offer / order-book systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.setConsumed; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `maker callback alters later order execution` as a local Foundry sequence and assert aggregate backing after the final transition.

## Router / Aggregator Systems

### PATTERN-021 - Partial-Success Poison Leg
- Source inspiration: Immunefi blog
- Generic mechanism: A historically recurring router / aggregator systems assumption fails when `partial-success poison leg` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: router / aggregator systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `partial-success poison leg` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-022 - Final Balance Used Instead Of Route Delta
- Source inspiration: DeFiHackLabs
- Generic mechanism: A historically recurring router / aggregator systems assumption fails when `final balance used instead of route delta` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: router / aggregator systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `final balance used instead of route delta` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-023 - Approval Residue Changes Later Route
- Source inspiration: SWC Registry
- Generic mechanism: A historically recurring router / aggregator systems assumption fails when `approval residue changes later route` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: router / aggregator systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `approval residue changes later route` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-024 - Mixed-Market Route Crosses Consent Boundary
- Source inspiration: SmartBugs
- Generic mechanism: A historically recurring router / aggregator systems assumption fails when `mixed-market route crosses consent boundary` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: router / aggregator systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `mixed-market route crosses consent boundary` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-025 - Multicall Combines Individually Safe State Transitions
- Source inspiration: SmartBugs Curated
- Generic mechanism: A historically recurring router / aggregator systems assumption fails when `multicall combines individually safe state transitions` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: router / aggregator systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `multicall combines individually safe state transitions` as a local Foundry sequence and assert aggregate backing after the final transition.

## Permits And Delegated Authorization

### PATTERN-026 - Signed Grant Survives Mental-Model Revocation
- Source inspiration: DAppSCAN
- Generic mechanism: A historically recurring permits and delegated authorization assumption fails when `signed grant survives mental-model revocation` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: permits and delegated authorization.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `signed grant survives mental-model revocation` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-027 - Signature Reused In A Different Operation Context
- Source inspiration: AutoMESC
- Generic mechanism: A historically recurring permits and delegated authorization assumption fails when `signature reused in a different operation context` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: permits and delegated authorization.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `signature reused in a different operation context` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-028 - Relayer Substitutes Receiver Or Referral
- Source inspiration: ScrawlD
- Generic mechanism: A historically recurring permits and delegated authorization assumption fails when `relayer substitutes receiver or referral` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: permits and delegated authorization.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `relayer substitutes receiver or referral` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-029 - Delegate Combines Harmless Powers
- Source inspiration: ReEVMBench
- Generic mechanism: A historically recurring permits and delegated authorization assumption fails when `delegate combines harmless powers` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: permits and delegated authorization.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `delegate combines harmless powers` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-030 - Permit Front-Run Changes Route Context
- Source inspiration: Trail of Bits Building Secure Contracts
- Generic mechanism: A historically recurring permits and delegated authorization assumption fails when `permit front-run changes route context` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: permits and delegated authorization.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: MidnightBundles; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `permit front-run changes route context` as a local Foundry sequence and assert aggregate backing after the final transition.

## Oracle / Gate Systems

### PATTERN-031 - Liveness Fault Blocks Time-Sensitive Exit
- Source inspiration: Local Cyfrin-derived skills
- Generic mechanism: A historically recurring oracle / gate systems assumption fails when `liveness fault blocks time-sensitive exit` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: oracle / gate systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.withdrawCollateral; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `liveness fault blocks time-sensitive exit` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-032 - Multi-Collateral Price Asymmetry Changes Seizure Order
- Source inspiration: Local Slither output
- Generic mechanism: A historically recurring oracle / gate systems assumption fails when `multi-collateral price asymmetry changes seizure order` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: oracle / gate systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.withdrawCollateral; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `multi-collateral price asymmetry changes seizure order` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-033 - Bad Market Oracle Contaminates Indirect Route
- Source inspiration: Solodit
- Generic mechanism: A historically recurring oracle / gate systems assumption fails when `bad market oracle contaminates indirect route` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: oracle / gate systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.withdrawCollateral; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `bad market oracle contaminates indirect route` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-034 - Gate Changes After Debt Entry
- Source inspiration: Code4rena reports
- Generic mechanism: A historically recurring oracle / gate systems assumption fails when `gate changes after debt entry` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: oracle / gate systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.withdrawCollateral; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `gate changes after debt entry` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-035 - Oracle Callback Observes Intermediate State
- Source inspiration: Sherlock public audits
- Generic mechanism: A historically recurring oracle / gate systems assumption fails when `oracle callback observes intermediate state` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: oracle / gate systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.withdrawCollateral; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `oracle callback observes intermediate state` as a local Foundry sequence and assert aggregate backing after the final transition.

## Callbacks And Hooks

### PATTERN-036 - Cross-Function Observation Of Transient State
- Source inspiration: Cantina competitions
- Generic mechanism: A historically recurring callbacks and hooks assumption fails when `cross-function observation of transient state` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: callbacks and hooks.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.flashLoan; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `cross-function observation of transient state` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-037 - Duplicate Callback Settlement Obligation
- Source inspiration: Immunefi blog
- Generic mechanism: A historically recurring callbacks and hooks assumption fails when `duplicate callback settlement obligation` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: callbacks and hooks.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.flashLoan; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `duplicate callback settlement obligation` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-038 - Callback Alters Later Route Leg
- Source inspiration: DeFiHackLabs
- Generic mechanism: A historically recurring callbacks and hooks assumption fails when `callback alters later route leg` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: callbacks and hooks.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.flashLoan; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `callback alters later route leg` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-039 - Gas Or Return-Data Grief After Earlier Effect
- Source inspiration: SWC Registry
- Generic mechanism: A historically recurring callbacks and hooks assumption fails when `gas or return-data grief after earlier effect` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: callbacks and hooks.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.flashLoan; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `gas or return-data grief after earlier effect` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-040 - Hook Composes With Maturity Transition
- Source inspiration: SmartBugs
- Generic mechanism: A historically recurring callbacks and hooks assumption fails when `hook composes with maturity transition` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: callbacks and hooks.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.flashLoan; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `hook composes with maturity transition` as a local Foundry sequence and assert aggregate backing after the final transition.

## Fee / Reward Accounting

### PATTERN-041 - Claim Before Lazy Positions Settle
- Source inspiration: SmartBugs Curated
- Generic mechanism: A historically recurring fee / reward accounting assumption fails when `claim before lazy positions settle` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fee / reward accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `claim before lazy positions settle` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-042 - Fee Claim Context Changes After Socialized Loss
- Source inspiration: DAppSCAN
- Generic mechanism: A historically recurring fee / reward accounting assumption fails when `fee claim context changes after socialized loss` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fee / reward accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `fee claim context changes after socialized loss` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-043 - Settlement Fee Custody Overlaps Another Market
- Source inspiration: AutoMESC
- Generic mechanism: A historically recurring fee / reward accounting assumption fails when `settlement fee custody overlaps another market` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fee / reward accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `settlement fee custody overlaps another market` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-044 - Rounding Remainder Crosses Later Threshold
- Source inspiration: ScrawlD
- Generic mechanism: A historically recurring fee / reward accounting assumption fails when `rounding remainder crosses later threshold` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fee / reward accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `rounding remainder crosses later threshold` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-045 - Fee Update Invalidates Route Economics
- Source inspiration: ReEVMBench
- Generic mechanism: A historically recurring fee / reward accounting assumption fails when `fee update invalidates route economics` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: fee / reward accounting.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight.liquidate; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `fee update invalidates route economics` as a local Foundry sequence and assert aggregate backing after the final transition.

## Share / Unit Conversions

### PATTERN-046 - Rounding Direction Differs Across Inverse Operation
- Source inspiration: Trail of Bits Building Secure Contracts
- Generic mechanism: A historically recurring share / unit conversions assumption fails when `rounding direction differs across inverse operation` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: share / unit conversions.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `rounding direction differs across inverse operation` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-047 - One-Wei Value Flips Health Branch
- Source inspiration: Local Cyfrin-derived skills
- Generic mechanism: A historically recurring share / unit conversions assumption fails when `one-wei value flips health branch` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: share / unit conversions.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `one-wei value flips health branch` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-048 - Division-Before-Multiplication Compounds Loss
- Source inspiration: Local Slither output
- Generic mechanism: A historically recurring share / unit conversions assumption fails when `division-before-multiplication compounds loss` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: share / unit conversions.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `division-before-multiplication compounds loss` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-049 - Zero-To-Nonzero Supply Changes Conversion
- Source inspiration: Solodit
- Generic mechanism: A historically recurring share / unit conversions assumption fails when `zero-to-nonzero supply changes conversion` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: share / unit conversions.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `zero-to-nonzero supply changes conversion` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-050 - Narrow Representation Aliases Economic State
- Source inspiration: Code4rena reports
- Generic mechanism: A historically recurring share / unit conversions assumption fails when `narrow representation aliases economic state` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: share / unit conversions.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `narrow representation aliases economic state` as a local Foundry sequence and assert aggregate backing after the final transition.

## Multi-Collateral Systems

### PATTERN-051 - Bitmap And Balance Transition Disagree
- Source inspiration: Sherlock public audits
- Generic mechanism: A historically recurring multi-collateral systems assumption fails when `bitmap and balance transition disagree` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: multi-collateral systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `bitmap and balance transition disagree` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-052 - Collateral-Index Boundary Selects Wrong Asset
- Source inspiration: Cantina competitions
- Generic mechanism: A historically recurring multi-collateral systems assumption fails when `collateral-index boundary selects wrong asset` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: multi-collateral systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `collateral-index boundary selects wrong asset` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-053 - Seizure Order Preserves Toxic Basket
- Source inspiration: Immunefi blog
- Generic mechanism: A historically recurring multi-collateral systems assumption fails when `seizure order preserves toxic basket` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: multi-collateral systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `seizure order preserves toxic basket` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-054 - Zero Withdrawal Mutates Activation State
- Source inspiration: DeFiHackLabs
- Generic mechanism: A historically recurring multi-collateral systems assumption fails when `zero withdrawal mutates activation state` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: multi-collateral systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `zero withdrawal mutates activation state` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-055 - One Collateral Liveness Fault Blocks Basket Recovery
- Source inspiration: SWC Registry
- Generic mechanism: A historically recurring multi-collateral systems assumption fails when `one collateral liveness fault blocks basket recovery` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: multi-collateral systems.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `one collateral liveness fault blocks basket recovery` as a local Foundry sequence and assert aggregate backing after the final transition.

## Invariant / Model Mismatch

### PATTERN-056 - Formal Alias Writes One Market And Proves Another
- Source inspiration: SmartBugs
- Generic mechanism: A historically recurring invariant / model mismatch assumption fails when `formal alias writes one market and proves another` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: invariant / model mismatch.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `formal alias writes one market and proves another` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-057 - External Call Summary Excludes Callback Effect
- Source inspiration: SmartBugs Curated
- Generic mechanism: A historically recurring invariant / model mismatch assumption fails when `external call summary excludes callback effect` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: invariant / model mismatch.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `external call summary excludes callback effect` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-058 - Filtered Method Omits Periphery Composition
- Source inspiration: DAppSCAN
- Generic mechanism: A historically recurring invariant / model mismatch assumption fails when `filtered method omits periphery composition` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: invariant / model mismatch.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `filtered method omits periphery composition` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-059 - Revert Pruning Hides Rollback-Dependent Property
- Source inspiration: AutoMESC
- Generic mechanism: A historically recurring invariant / model mismatch assumption fails when `revert pruning hides rollback-dependent property` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: invariant / model mismatch.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `revert pruning hides rollback-dependent property` as a local Foundry sequence and assert aggregate backing after the final transition.

### PATTERN-060 - Event Reconstruction Diverges From Storage
- Source inspiration: ScrawlD
- Generic mechanism: A historically recurring invariant / model mismatch assumption fails when `event reconstruction diverges from storage` is composed with an adjacent state transition.
- DeFi semantic: Local correctness does not guarantee aggregate economic correctness.
- Attacker capability: Use public entrypoints, a valid role, or a locally controlled callback within the authorized harness.
- Victim impact: Potential non-dust loss, frozen funds, or accounting corruption only if a non-consenting party is affected.
- Typical affected components: invariant / model mismatch.
- Common proof style: Compare an adversarial sequence against an equivalent control execution and reconcile token custody plus liabilities.
- Common false positive: The behavior is documented market risk, user-authorized behavior, dust-only drift, or a prior audited class.
- Midnight analog: Midnight core and periphery state transitions; inspect the closest core, ratifier, and periphery path.
- Candidate PoC idea: Encode `event reconstruction diverges from storage` as a local Foundry sequence and assert aggregate backing after the final transition.
