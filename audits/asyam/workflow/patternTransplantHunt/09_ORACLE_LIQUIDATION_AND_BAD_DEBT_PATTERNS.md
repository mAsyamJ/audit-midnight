# Oracle Liquidation And Bad Debt Patterns

These entries are attack-planning prompts. They are not findings and must pass the local proof and dedup gates.

### OLB-001 - Route Exposes Victim To Unchosen Oracle Through IOracle
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `route exposes victim to unchosen oracle` when `IOracle` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-002 - Gate Liveness Blocks Time-Sensitive Protective Exit Through IGate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `gate liveness blocks time-sensitive protective exit` when `IGate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-003 - Collateral Order Changes Recovery Under Asymmetric Prices Through liquidate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `collateral order changes recovery under asymmetric prices` when `liquidate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-004 - Maturity Changes Liquidation Mode After Quote Through withdrawCollateral
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `maturity changes liquidation mode after quote` when `withdrawCollateral` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-005 - Bad Debt Realizes Before All Recoverability Paths Through repay
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `bad debt realizes before all recoverability paths` when `repay` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-006 - Lender Loss Allocates Before Lazy Update Through _updatePosition
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `lender loss allocates before lazy update` when `_updatePosition` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-007 - Oracle Liveness Freezes Withdrawal Into Liquidation Through MidnightBundles
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `oracle liveness freezes withdrawal into liquidation` when `MidnightBundles` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-008 - Gate Liveness Plus Maturity Escalates Loss Through IOracle
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `gate liveness plus maturity escalates loss` when `IOracle` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-009 - Multi-Collateral Price Asymmetry Favors Toxic Basket Through IGate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `multi-collateral price asymmetry favors toxic basket` when `IGate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-010 - Maxlif Boundary Changes Private Gain Through liquidate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `maxLif boundary changes private gain` when `liquidate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-011 - Lltv One-Wei Boundary Changes Solvency Through withdrawCollateral
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `LLTV one-wei boundary changes solvency` when `withdrawCollateral` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-012 - Rcf Threshold Combines With Collateral Order Through repay
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `RCF threshold combines with collateral order` when `repay` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-013 - Zero Collateral Branch Changes Bitmap Through _updatePosition
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `zero collateral branch changes bitmap` when `_updatePosition` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-014 - Zero Repay Branch Alters Later Recovery Through MidnightBundles
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `zero repay branch alters later recovery` when `MidnightBundles` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-015 - Liquidation Callback Observes Intermediate State Through IOracle
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `liquidation callback observes intermediate state` when `IOracle` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-016 - Route Exposes Victim To Unchosen Oracle Through IGate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `route exposes victim to unchosen oracle` when `IGate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-017 - Gate Liveness Blocks Time-Sensitive Protective Exit Through liquidate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `gate liveness blocks time-sensitive protective exit` when `liquidate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-018 - Collateral Order Changes Recovery Under Asymmetric Prices Through withdrawCollateral
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `collateral order changes recovery under asymmetric prices` when `withdrawCollateral` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-019 - Maturity Changes Liquidation Mode After Quote Through repay
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `maturity changes liquidation mode after quote` when `repay` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-020 - Bad Debt Realizes Before All Recoverability Paths Through _updatePosition
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `bad debt realizes before all recoverability paths` when `_updatePosition` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-021 - Lender Loss Allocates Before Lazy Update Through MidnightBundles
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `lender loss allocates before lazy update` when `MidnightBundles` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-022 - Oracle Liveness Freezes Withdrawal Into Liquidation Through IOracle
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `oracle liveness freezes withdrawal into liquidation` when `IOracle` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-023 - Gate Liveness Plus Maturity Escalates Loss Through IGate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `gate liveness plus maturity escalates loss` when `IGate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-024 - Multi-Collateral Price Asymmetry Favors Toxic Basket Through liquidate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `multi-collateral price asymmetry favors toxic basket` when `liquidate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-025 - Maxlif Boundary Changes Private Gain Through withdrawCollateral
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `maxLif boundary changes private gain` when `withdrawCollateral` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-026 - Lltv One-Wei Boundary Changes Solvency Through repay
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `LLTV one-wei boundary changes solvency` when `repay` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-027 - Rcf Threshold Combines With Collateral Order Through _updatePosition
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `RCF threshold combines with collateral order` when `_updatePosition` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-028 - Zero Collateral Branch Changes Bitmap Through MidnightBundles
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `zero collateral branch changes bitmap` when `MidnightBundles` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-029 - Zero Repay Branch Alters Later Recovery Through IOracle
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `zero repay branch alters later recovery` when `IOracle` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### OLB-030 - Liquidation Callback Observes Intermediate State Through IGate
- Status: `hypothesis_only`.
- Why not already closed: Only pursue `liquidation callback observes intermediate state` when `IGate` adds an involuntary consent boundary, ordering effect, or material threshold flip beyond direct chosen-market risk.
- PoC plan: Construct control and adversarial multi-collateral states, execute the full recovery path, and compare liquidator proceeds, remaining collateral, `lossFactor`, and lender claims.
- False-positive filter: Reject documented market risk, simple malicious oracle behavior, and direct bad-debt duplicates.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.
