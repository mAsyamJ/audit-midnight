# 02 Hashlock Validation

Date: 2026-05-30

Hashlock material is treated as AI-generated hypothesis input only. None of the items below is a finding without a compiling Foundry PoC or a precise proof against current code.

## Ratifier / Authorization Scan

| Hashlock item | Current validation | Status |
|---|---|---|
| M-01 cancel/root ratification front-running | Technically possible as ordinary order-cancellation MEV, but this is not protocol-specific unless a stronger guarantee is documented. | Park |
| M-02 unbounded `collateralParams` in `hashMarket` | `Midnight.take` calls `touchMarket` before ratifier validation; `touchMarket` bounds collateral count. Direct ratifier calls are guarded by `msg.sender == MIDNIGHT`. | Likely false positive |
| M-03 authorized delegate can cancel/de-ratify roots | True under broad Midnight authorization semantics, but Spearbit/Blackthorn already cover excessive delegated authority / ratifier scope. | Duplicate/accepted risk |
| L-01 signature malleability | `ecrecover` is used without low-s normalization. `test/asyamFindings/PoC_SignatureMalleability.t.sol` proves both ratifier and authorizer accept high-s malleated signatures. | Validated Low/P3 |
| L-02 setter proof length not capped | Setter roots can represent arbitrary proof heights, but caller pays gas and Ecrecover now uses `proof.length` in current code. | Low/gas only |
| L-03 irreversible cancelRoot | Design/operational risk. | Park |
| L-04 zero maker | `address(0)` cannot authorize a ratifier through normal `setIsAuthorized`, and Certora has a `addressZeroCantAuthorize` invariant. | Likely false positive |

## Periphery Bundle Scan

| Hashlock item | Current validation | Status |
|---|---|---|
| High-01 malicious/ERC777 token reentrancy | Core and periphery comments inherit exact/non-reentrant token assumptions. Only useful if the competition treats token hooks as in scope or the path uses normal callbacks rather than malicious token behavior. | Park unless non-token callback path exists |
| High-02 accumulated loan-token balance cross-function reentrancy | Audit probes confirm transient balance visibility, but fixed-amount transfers prevent extraction. A nested sell bundle also preserves outer first-leg proceeds parked in the router. Malicious token-hook behavior remains outside the standard-token assumption. | Disproven under stated assumptions |
| Medium-01 referral fee underflow in buy units | `maxBuyerAssets` is intentionally the total buyer budget. `requiredBudget - 1` reverts atomically during referral payment; exact `requiredBudget` succeeds without router residual. | Invalid |
| Medium-02 inverse math precision mismatch | Same family as Blackthorn L-6/L-7 and current tests. | Duplicate-risk |
| Medium-03 referral fee reduces actual debt repayment | Existing bundle comments define fee and units repaid as `assets - fee`; tests include full debt inversion. | Likely intended |
| Medium-04 `ConsumableUnitsLib` zero when both caps zero | Core empty-offer behavior is covered by Certora/Foundry; zero caps likely represent an empty offer. | Weak |
| Medium-05 `buyerAssetsToUnits` reverts when buyer price > WAD | Library documents this. Bundler reverting on unreachable exact asset targets is likely intended. | Weak |
| Medium-06 seller price zero division | Overlaps Blackthorn L-24 tick zero / zero price behavior. | Duplicate |
| Low-02 empty `takes[]` out-of-bounds | Real revert surface, no value loss by itself. | Low/test gap |
| Low-04 reverting referral recipient DoS | User-supplied recipient; mainly self-DoS unless a third party controls the value path. | Low |
| Low-05 settlement fee staleness during execution | Fee changes require fee setter and are already in audited slippage/stale fee documentation. | Duplicate-risk |
| Low-07 Permit2 replay across functions | Permit2 signature transfer has nonce/deadline semantics. Every router pull also fixes `from = msg.sender`, while Permit2 binds token, amount, bundler spender, nonce, deadline, and router recipient. A third party cannot consume a victim's signature through an attacker-owned bundle call. | Invalid for implemented routes |

## Interfaces / Core Scan

| Hashlock item | Current validation | Status |
|---|---|---|
| Callback reentrancy | Valid research direction, but must be distinct from Blackthorn callback actor-binding / zero-unit replay / liquidator allowance issues. | Live queue |
| Gate/oracle liveness | Gates/oracles are market-chosen. Reverting and zero oracle behavior is covered in tests/CVL. | Usually accepted risk |
| Ratifier root griefing | Duplicate of delegated authority/root control issues. | Duplicate-risk |
| Exact fill rounding failures | Duplicate-risk with Blackthorn helper/core issues. | Live only if current-code divergence proven |

## Working Rule

Hashlock is useful for test queue generation, not submission material. Any candidate from Hashlock must pass all of:

- current code path confirmed
- audited JSON dedup check passed
- impact is more than caller self-DoS or gas grief
- Foundry PoC compiles and demonstrates a concrete invariant break
