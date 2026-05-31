# State Machine And Accounting Patterns

These entries are attack-planning prompts. They are not findings and must pass the local proof and dedup gates.

### SAP-001 - State Changed Before Transfer Through take
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `state changed before transfer`.
- Midnight state variables: Inspect `take` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `state changed before transfer` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-002 - Transfer Before State Changed Through liquidate
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `transfer before state changed`.
- Midnight state variables: Inspect `liquidate` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `transfer before state changed` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-003 - External Call Between Coupled Updates Through repay
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `external call between coupled updates`.
- Midnight state variables: Inspect `repay` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `external call between coupled updates` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-004 - View Uses Lazy Position Through withdraw
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `view uses lazy position`.
- Midnight state variables: Inspect `withdraw` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `view uses lazy position` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-005 - Position Touch Skipped In One Path Through withdrawCollateral
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `position touch skipped in one path`.
- Midnight state variables: Inspect `withdrawCollateral` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `position touch skipped in one path` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-006 - Lossfactor Applied Twice Or Omitted Through flashLoan
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `lossFactor applied twice or omitted`.
- Midnight state variables: Inspect `flashLoan` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `lossFactor applied twice or omitted` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-007 - Pendingfee Direction Differs By Order Through multicall
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `pendingFee direction differs by order`.
- Midnight state variables: Inspect `multicall` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `pendingFee direction differs by order` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-008 - Withdrawable Updated On One Branch Only Through claimContinuousFee
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `withdrawable updated on one branch only`.
- Midnight state variables: Inspect `claimContinuousFee` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `withdrawable updated on one branch only` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-009 - Bitmap And Collateral Amount Diverge Through setConsumed
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `bitmap and collateral amount diverge`.
- Midnight state variables: Inspect `setConsumed` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `bitmap and collateral amount diverge` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-010 - Consumed Updates Before Economic Settlement Through _updatePosition
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `consumed updates before economic settlement`.
- Midnight state variables: Inspect `_updatePosition` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `consumed updates before economic settlement` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-011 - Fee Claim Executes After Loss Context Change Through take
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `fee claim executes after loss context change`.
- Midnight state variables: Inspect `take` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `fee claim executes after loss context change` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-012 - Baddebt And Totalunits Ordering Diverge Through liquidate
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `badDebt and totalUnits ordering diverge`.
- Midnight state variables: Inspect `liquidate` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `badDebt and totalUnits ordering diverge` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-013 - Duplicate Array Entry Reuses Obligation Through repay
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `duplicate array entry reuses obligation`.
- Midnight state variables: Inspect `repay` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `duplicate array entry reuses obligation` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-014 - Multicall Compresses Expected Observation Boundary Through withdraw
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `multicall compresses expected observation boundary`.
- Midnight state variables: Inspect `withdraw` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `multicall compresses expected observation boundary` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-015 - Event Reconstruction Lags Storage Through withdrawCollateral
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `event reconstruction lags storage`.
- Midnight state variables: Inspect `withdrawCollateral` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `event reconstruction lags storage` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-016 - State Changed Before Transfer Through flashLoan
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `state changed before transfer`.
- Midnight state variables: Inspect `flashLoan` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `state changed before transfer` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-017 - Transfer Before State Changed Through multicall
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `transfer before state changed`.
- Midnight state variables: Inspect `multicall` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `transfer before state changed` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-018 - External Call Between Coupled Updates Through claimContinuousFee
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `external call between coupled updates`.
- Midnight state variables: Inspect `claimContinuousFee` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `external call between coupled updates` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-019 - View Uses Lazy Position Through setConsumed
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `view uses lazy position`.
- Midnight state variables: Inspect `setConsumed` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `view uses lazy position` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-020 - Position Touch Skipped In One Path Through _updatePosition
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `position touch skipped in one path`.
- Midnight state variables: Inspect `_updatePosition` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `position touch skipped in one path` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-021 - Lossfactor Applied Twice Or Omitted Through take
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `lossFactor applied twice or omitted`.
- Midnight state variables: Inspect `take` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `lossFactor applied twice or omitted` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-022 - Pendingfee Direction Differs By Order Through liquidate
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `pendingFee direction differs by order`.
- Midnight state variables: Inspect `liquidate` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `pendingFee direction differs by order` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-023 - Withdrawable Updated On One Branch Only Through repay
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `withdrawable updated on one branch only`.
- Midnight state variables: Inspect `repay` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `withdrawable updated on one branch only` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-024 - Bitmap And Collateral Amount Diverge Through withdraw
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `bitmap and collateral amount diverge`.
- Midnight state variables: Inspect `withdraw` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `bitmap and collateral amount diverge` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-025 - Consumed Updates Before Economic Settlement Through withdrawCollateral
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `consumed updates before economic settlement`.
- Midnight state variables: Inspect `withdrawCollateral` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `consumed updates before economic settlement` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-026 - Fee Claim Executes After Loss Context Change Through flashLoan
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `fee claim executes after loss context change`.
- Midnight state variables: Inspect `flashLoan` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `fee claim executes after loss context change` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-027 - Baddebt And Totalunits Ordering Diverge Through multicall
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `badDebt and totalUnits ordering diverge`.
- Midnight state variables: Inspect `multicall` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `badDebt and totalUnits ordering diverge` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-028 - Duplicate Array Entry Reuses Obligation Through claimContinuousFee
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `duplicate array entry reuses obligation`.
- Midnight state variables: Inspect `claimContinuousFee` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `duplicate array entry reuses obligation` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-029 - Multicall Compresses Expected Observation Boundary Through setConsumed
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `multicall compresses expected observation boundary`.
- Midnight state variables: Inspect `setConsumed` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `multicall compresses expected observation boundary` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### SAP-030 - Event Reconstruction Lags Storage Through _updatePosition
- Status: `hypothesis_only`.
- Source pattern: Historical state-desynchronization class: `event reconstruction lags storage`.
- Midnight state variables: Inspect `_updatePosition` updates to `position`, `marketState`, `withdrawable`, `lossFactor`, `pendingFee`, `consumed`, bitmap fields, and custody.
- Transition sequence: Execute the suspected `event reconstruction lags storage` ordering, then the next economically sensitive transition.
- Expected assertion: Adversarial and eager-control executions reconcile to the same backed aggregate value unless documented incentives explain the delta.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.
