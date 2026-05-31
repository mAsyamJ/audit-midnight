# Callback, Gate, and Oracle Trust Boundaries

Date: 2026-05-30

## Why callbacks exist

Source liquidity at settlement, enable atomic price/inventory checks, and compose with periphery—without escrowed offer capital.

## Callback invocation points

| Function | Callbacks | Order vs transfer |
|---|---|---|
| `take` | `onBuy`, `onSell` | After state update; buy before transfers; sell after |
| `repay` | `onRepay` | Before `transferFrom` |
| `liquidate` | `onLiquidate` | After collateral out; before loan pull |
| `flashLoan` | `onFlashLoan` | Send → callback → pull |

## Magic return values

Must return `CALLBACK_SUCCESS` constant or revert.

## Reentrancy assumptions

- **Token:** exact, non-reentrant ERC20 (core + Certora).
- **Callbacks:** untrusted; seller liquidation lock during sell callback in `take`.
- **Certora Solvency:** `onBuy`/`onSell` often `NONDET` — proofs do **not** cover reentrant take composition.

## Gates

| Gate | Hook |
|---|---|
| `enterGate` | `canIncreaseCredit`, `canIncreaseDebt` on take |
| `liquidatorGate` | `canLiquidate` on liquidate |

Market creator selects contracts — **INTENDED** policy surface.

## Oracle

- `IOracle.price()` — used in `liquidate` and `isHealthy` (withdraw path).
- Liveness/freshness = market risk.

## Boundary table

| Boundary | Trusted party | Untrusted input | Path | Intended guarantee | Bug if |
|---|---|---|---|---|---|
| core → callback | Protocol | Arbitrary code | take/repay/liquidate/flash | No value leak / accounting break | Profit or corrupt state |
| core → token | Protocol | ERC20 behavior | all transfers | Exact balance delta | Reentrant drain |
| core → oracle | Market creator | price() | health/liquidate | Consistent valuation | Forced on victim |
| core → gate | Market creator | bool hooks | take/liquidate | Policy enforcement | Forced on victim |
| periphery → token | User + router | ERC20 | pullToken | Pull only from msg.sender | Third-party drain |
| periphery → Midnight | Router | calldata | take/repay/... | Same as direct calls | Extra accounting |
| ratifier → Midnight | Maker auth | proofs | isRatified | Only valid offers | Unauthorized fill |
| user → delegate | Maker | operator addr | authorized ops | Delegated scope | Exceeds intent |
| maker → order tree | Maker | off-chain | signatures/Merkle | Binding economics | Field not bound |
| liquidator → borrower | Liquidator | seize/repay params | liquidate | Bounded seizure | Over-seize |

## Cross-links

- [11_INTENDED_BEHAVIORS_NOT_BUGS.md](11_INTENDED_BEHAVIORS_NOT_BUGS.md)
- C-14: [../POC_RESULTS.md](../POC_RESULTS.md)
