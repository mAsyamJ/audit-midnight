# State Machine Breakpoints

Date: 2026-05-30

| Breakpoint | State before | Transition function | External-call window | State after | Expected invariant | Possible composition | Closed AP components | New test idea |
|---|---|---|---|---|---|---|---|---|
| `_updatePosition` entry/exit | stale credit, pending fee, lossFactor | `_updatePosition` | none internally | credit/pendingFee synced | fee-credit consistency | slash -> repay -> stale exit | AP-008/010 | COMP-003/011 |
| consumed update | cap headroom | `take` | ratifier before; callbacks after | `consumed += units/assets` | cap monotonic and bounded | nested route/direct consume | AP-002 | COMP-001/022 |
| loan token transfer | position already changed | `take` | buyer callback precedes pull | custody receives fee, receiver receives sale | state delta backed by transfers | callback root mutation | AP-001/026 | COMP-008 |
| callback entry/exit | seller locked, deltas committed | `take` callbacks | arbitrary callback | lock restored, health checked | no monetized temporary state | maturity repay nesting | AP-001/021/026 | COMP-015 |
| seller health check | outer transfers done | `take` | callbacks already returned | seller healthy or transient lock | `INV-013` | nested collateral mutation | AP-007/026 | COMP-027 |
| collateral bitmap update | slot reaches zero/nonzero | `supplyCollateral`, `withdrawCollateral`, `liquidate` | transfers after state write | bit set/cleared | bitmap mirrors nonzero slots | oracle cleanup deadlock | AP-007/018 | COMP-020 |
| oracle price read | active bitmap snapshot | `liquidate`, `isHealthy` | oracle call | maxDebt/badDebt accumulated | liveness classified, math safe | multi-collateral revert | AP-004/007 | COMP-006 |
| bad debt loop exit | original debt and bitmap | `liquidate` | oracle calls in loop | badDebt computed | slash <= unrecoverable debt | gate delay plus maturity | AP-004/008 | COMP-019 |
| lossFactor update | positive badDebt | `liquidate` | callback later | socialized scale updated | proportional slash | fee-claim ordering | AP-008/010 | COMP-003 |
| withdrawable update | repayment determined | `repay`, `liquidate` | repay/liquidate callback before pull | cash claim credited | credited inflow eventually paid | nested withdraw before pull | AP-009/021/026 | COMP-014 |
| ratifier validation | authorized ratifier | `take -> isRatified` | external ratifier view | offer accepted/reverted | valid current authority only | stale root route fallback | AP-011/013 | COMP-001/029 |
| root state update | root enabled/canceled | `cancelRoot`, `setIsRootRatified` | none | future ratifier result changes | canceled root unusable | callback toggles later root | AP-011 | COMP-008/016 |
| periphery `pullToken` | caller approved/permitted | `pullToken` | ERC2612/Permit2/token call | router funded | only caller funds charged | delegate/payer separation | AP-017 | COMP-005/017 |
| periphery approval | router holds assets | `forceApproveMax` | token approve calls | Midnight allowance max | no route residue extraction | shared-token nested route | AP-014 | COMP-007 |
| periphery take loop | route local totals | bundle route | core take and callbacks | actual totals accumulate | min/max/target holds | caught root failure fallback | AP-014/015 | COMP-002 |
| periphery refund/final transfer | loop targets satisfied | bundle route tail | token transfers | no router float | distribute only route assets | referral fallback split | AP-023 | COMP-002 |
| maturity transition | time relative to maturity | `take`, `liquidate`, fee view | oracle/gate/callback as applicable | debt and LIF branch selected | no new debt after maturity | flash-liquidation boundary | AP-006/020 | COMP-004/015 |
