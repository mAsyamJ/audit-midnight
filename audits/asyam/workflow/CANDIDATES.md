# Candidates

Date: 2026-05-30

No item below is a final finding. Dedup status is assigned before any PoC work, per `03_DEDUP_MAP.md`.

## Status Legend

- Duplicate-known: covered by audited Spearbit/Blackthorn JSON.
- Fixed-known: covered by audited JSON and visibly fixed in current code.
- Hashlock-only: AI/hypothesis material; needs validation.
- False-positive likely: current code or documented model appears to block it.
- Live queue: worth PoC work if impact can be made concrete and non-duplicate.
- Park: likely accepted risk, design choice, self-DoS, gas-only, or too weak for submission.

## Candidate Table

| ID | Candidate | Anchor | Dedup status | Next action |
|---|---|---|---|---|
| C-01 | Zero oracle price permits bad liquidation / bad debt behavior | `SOL-Defi-Oracle-2` | Duplicate-known: Spearbit Medium | Do not PoC unless materially different from zero-price finding |
| C-02 | Market created before default fees are configured | `SOL-Defi-General-4` | Duplicate-known: Spearbit Medium | Do not PoC |
| C-03 | Pending/continuous fee rounding dust can be amplified | `SOL-Heuristics-10` | Duplicate-known: Spearbit Low, Blackthorn L-9 | Only revisit if profit/corruption exceeds known dust |
| C-04 | Near-maturity fill creates unconsented seller debt | `SOL-AM-FrA-3` | Duplicate-known: Blackthorn M-2 | Do not PoC |
| C-05 | Grouped offer shared cap can be overfilled | `SOL-Heuristics-17` | Duplicate-known: Blackthorn L-5 | Do not PoC |
| C-06 | Terminal loss factor slashes fresh lender principal | `SOL-Defi-Lending-12` | Duplicate-known: Blackthorn M-1, Spearbit lossIndex | Do not PoC |
| C-07 | Hardfork changes market/obligation IDs | `SOL-Signature-1` | Duplicate-known: Spearbit, Blackthorn L-1 | Do not PoC |
| C-08 | Foreign/delegated ratifier authority is too broad | `SOL-Basics-AC-1` | Duplicate-known: Spearbit, Blackthorn L-16 | Only use as context |
| C-09 | Approval/ratifier replay across deployments | `SOL-Signature-1` | Duplicate-known or legacy path | Verify current code only if a different ratifier exists |
| C-10 | Callback actor binding drains third-party callback funds | `SOL-EC-14` | Duplicate-known: Blackthorn L-19 | Do not PoC unless path differs from buy/sell actor binding |
| C-11 | Zero-unit `take()` replays callbacks | `SOL-Heuristics-12` | Duplicate-known: Blackthorn L-20 | Do not PoC |
| C-12 | Liquidation bad-debt socialization can be triggered optimistically | `SOL-Defi-Lending-1` | Duplicate-known: Blackthorn L-10; Spearbit related info | Only revisit with non-oracle, non-duplicate root cause |
| C-13 | Helper/core `TakeAmountsLib` mismatch | `SOL-Heuristics-1` | Duplicate-known: Blackthorn L-6/L-7 | Fuzz only if current code differs materially |
| C-14 | `TickLib.tickToPrice(0) == 0` enables extreme fills/division paths | `SOL-Basics-Function-5` | Duplicate-known: Blackthorn L-24 | Do not PoC |
| C-15 | `LLTV == WAD` removes post-maturity liquidation incentive | `SOL-Defi-Lending-11` | Duplicate-known: Blackthorn L-4 | Do not PoC |
| C-16 | Missing initiator/receiver context in flash/liquidate callbacks | `SOL-EC-14` | Fixed-known or duplicate: Blackthorn L-14/L-25 | Current `onLiquidate` includes caller and receiver; check flash only if new impact |
| C-17 | Liquidator callback allowance exposure after callback-before-pull | `SOL-EC-13` | Duplicate-known: Blackthorn L-26 | Do not PoC |
| C-18 | Existing offers break after fee updates | `SOL-AM-GA-1` | Duplicate-known: Blackthorn L-13/Spearbit stale fee | Do not PoC |
| C-19 | Compromised operator cannot be quickly disabled everywhere | `SOL-Basics-AC-5` | Duplicate-known: Blackthorn L-17 | Do not PoC |
| C-20 | Zero-amount liquidation fails on tokens that revert on zero transfer | `SOL-Token-FE-10` | Duplicate-known: Blackthorn L-18 | Park unless weird-token issues are in scope |
| C-21 | `MidnightBundles` mutable midnight phishing | `SOL-EC-5` | Fixed-known: current code uses immutable `MIDNIGHT` | No action |
| C-22 | Ecrecover ratifier explicit height mismatch | `SOL-HMT-4` | Fixed-known: current code uses `proof.length` | No action |
| C-23 | Constructor can avoid reading storage for roleSetter | `SOL-Basics-Function-4` | Fixed-known: current constructor uses `msg.sender` | No action |
| C-24 | Test `testReturnJumps` checks wrong ratio direction | Tests | Duplicate-known: Blackthorn L-2 | Do not repeat unless finding broader test weakness |
| C-25 | Callback reentrancy into a different core entry point during state-before-transfer | `SOL-EC-1`, `SOL-EC-13` | Live queue, high duplicate-risk | Build PoC only if distinct from L-19/L-20/L-26 and shows value/accounting impact |
| C-26 | Periphery temporary loan-token balance can be stolen or misdirected through reentrant bundle composition | `SOL-AM-DA-1`, `SOL-EC-1` | Live queue / Hashlock-only | Highest-priority periphery PoC queue |
| C-27 | ERC777 or malicious ERC20 reentrancy through bundle collateral pulls | `SOL-Token-FE-7` | Park: token behavior likely out of core assumptions | Only revive if normal callback path can reproduce |
| C-28 | Permit2 signature replay across bundle functions | `SOL-Signature-1` | False-positive likely / Hashlock-only | Validate Permit2 nonce semantics before PoC |
| C-29 | ERC2612 permit front-run causes unexpected third-party impact | `SOL-Token-FE-11` | Weak / Hashlock-only | Current code tolerates permit revert then requires transferFrom; low priority |
| C-30 | Referral fee exact-fill boundary breaks user min/max guarantees | `SOL-Heuristics-10` | Live queue, duplicate-risk | Boundary fuzz current code; must exceed existing bundle tests |
| C-31 | Stateful gate or oracle changes intra-transaction through callback to trap exits/liquidations | `SOL-Defi-Oracle-3`, `SOL-AM-GA-1` | Park/live depending path | Needs non-malicious-market impact; otherwise accepted risk |
| C-32 | Setter proof length above 20 creates gas griefing/asymmetry vs Ecrecover | `SOL-HMT-4` | Hashlock-only, low/gas | Park |
| C-33 | Zero-maker offer reaches ratifier | `SOL-HMT-5` | False-positive likely | `address(0)` cannot authorize ratifier through normal core path |
| C-34 | Oversized `collateralParams` reaches ratifier hash before bounds | `SOL-Basics-AL-9` | False-positive likely | `touchMarket` validates before ratifier call |
| C-35 | Events are insufficient to reconstruct all lazy position/market state | `SOL-Basics-Event-1` | Live P3 queue | Build indexer replay test if low/info findings are desired |
| C-36 | Loan token also used as collateral creates same-asset borrow/liquidation loop | `SOL-Defi-Lending-10` | Live queue | Model same-token market and check solvency/self-liquidation invariants |
| C-37 | `multicall` delegatecall sequencing bypasses single-call assumptions | `SOL-EC-2` | Park | CVL argues sound for invariants; no ETH/msg.value usage |
| C-38 | Reverting referral fee recipient causes bundle self-DoS after fills | `SOL-EC-7` | Hashlock-only, weak | Only relevant if third party can choose recipient |
| C-39 | Current tests log 100% max relative tick-price error without assertion | Tests/readability | Live P3 queue | Inspect whether this is expected at tiny prices or test masking |
| C-40 | One-step role transfer can lock roles to wrong address | `SOL-Basics-AC-4` | Validated P3 / accepted-risk candidate | PoC: `test/asyamFindings/PoC_RoleSetterBricking.t.sol` |
| C-41 | Ecrecover ratifier and authorizer accept high-s malleated signatures | `SOL-Signature-1` | Validated Low/P3 | PoC: `test/asyamFindings/PoC_SignatureMalleability.t.sol` |

## Prioritized Live Queues

1. C-26 periphery temporary-balance leakage.
2. C-25 callback reentrancy with a materially new state/accounting path.
3. C-30 referral/exact-fill boundary fuzzing.
4. C-36 same loan/collateral token market behavior.
5. C-35 event reconstructibility and C-39 test weakness for P3 coverage.

## PoC Gate

No final Cantina finding should be written from this file alone. A candidate graduates only after:

- it is not duplicate-known/fixed-known/false-positive likely
- a Foundry PoC compiles
- the PoC demonstrates concrete impact
- the root cause and impact are materially different from Spearbit, Blackthorn, Hashlock hypotheses, Certora docs, and accepted assumptions
