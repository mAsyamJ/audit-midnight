# Cantina Submission - P3-02

## Cantina UI Fields

| Field | Value |
|---|---|
| **Finding Title** | CVL market-ID summaries alias distinct production markets and can prune valid traces |
| **Likelihood** | Medium |
| **Impact** | Low |
| **Severity** | Informational / P3 formal-assurance gap |
| **PoC location** | `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol` |
| **PoC type** | Local Foundry model-mismatch validation (no fork required) |
| **Submission status** | Recommended for manual submission as Informational only |

---

## Summary

Two CVL summaries for `IdLib.toId` do not preserve the complete production market identity:

- `Solvency.spec` derives a modeled ID from only `loanToken`, `maturity`, `chainId`, and the Midnight address.
- `NoDivisionByZero.spec` identifies a global market by comparing only the first three collateral entries even though production supports up to 128.

Production `IdLib.toId` derives the ID from the entire `Market` configuration. The incomplete summaries can therefore alias valid production-distinct markets and prune or collapse supported traces.

## Finding Description

Production includes the complete encoded market configuration in the ID:

```solidity
function toId(Market memory market, uint256 chainId, address midnight) internal pure returns (bytes32) {
    return keccak256(
        abi.encodePacked(
            uint8(0xff), midnight, chainId, keccak256(abi.encodePacked(SSTORE2_PREFIX, abi.encode(market)))
        )
    );
}
```

The solvency model omits all fields except the loan token and maturity:

```cvl
ghost hash(address, uint256, uint256, address) returns bytes32;

function CVL_toId(Midnight.Market market, uint256 chainId, address midnight) returns bytes32 {
    bytes32 id = hash(market.loanToken, market.maturity, chainId, midnight);
    require(loantoken[id] == market.loanToken), "remember the loan token of the market";
    require(forall uint128 collateralIndex. collateralIndex < market.collateralParams.length =>
        collateralToken[id][collateralIndex] == market.collateralParams[collateralIndex].token),
        "remember the collateral tokens of the market";
    return id;
}
```

For two valid production markets with the same `loanToken` and `maturity` but different collateral tokens:

1. Production computes distinct IDs and creates both markets.
2. `Solvency.spec` calls `hash` with identical arguments and necessarily receives the same modeled ID.
3. The `collateralToken[id][0]` requirements become contradictory.
4. Valid traces involving both markets can be pruned rather than checked against `tokenBalanceCorrect`.

The same modeled-ID alias also collapses accounting buckets if the omitted fields differ without producing contradictory token requirements, such as differing gates or `rcfThreshold`.

`NoDivisionByZero.spec` has a sibling identity-summary gap. Its global-market predicate compares the array length but inspects only collateral entries `0`, `1`, and `2`:

```cvl
function equalsGlobalMarket(Midnight.Market market) returns (bool) {
    return market.loanToken == globalMarketLoanToken
        && market.collateralParams.length == globalMarketCollateralLength
        && collateralMatches(market, 0)
        && collateralMatches(market, 1)
        && collateralMatches(market, 2)
        && market.maturity == globalMarketMaturity
        && market.rcfThreshold == globalMarketRcfThreshold
        && market.enterGate == globalMarketEnterGate
        && market.liquidatorGate == globalMarketLiquidatorGate;
}
```

The relevant rules do not constrain `globalMarketCollateralLength <= 3`. Two valid four-collateral markets with equal entries `0..2` but different entry `3` satisfy the same model predicate while production computes distinct IDs.

## Impact Explanation

**Impact: Low / formal-assurance gap**

This does not demonstrate a production insolvency exploit. It means the current CVL proofs do not establish their advertised properties across all supported market configurations. A future regression that manifests only across aliased configurations could remain undetected.

### Why this is not High or Medium

Production `IdLib.toId` remains distinct across the tested market
configurations. The PoC demonstrates an assurance-layer blind spot, not a
runtime exploit or present user-fund loss.

### Why this is still useful

Fixing the summaries restores the advertised breadth of the formal model and
reduces the chance that future multi-market regressions are silently pruned.

## Likelihood Explanation

**Likelihood: Medium**

The protocol intentionally supports multiple markets with the same loan token and maturity and permits up to 128 collateral entries. Changing collateral configuration, gates, or `rcfThreshold` is sufficient to produce a distinct production market while preserving an incomplete CVL identity.

## Proof of Concept

Run:

```bash
forge test --match-path test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol -vvvv
```

The tests prove two model mismatches:

- Two valid single-collateral markets have distinct production IDs but the same `Solvency.spec` reduced tuple.
- Two valid four-collateral markets differing only at collateral index `3` have distinct production IDs but satisfy the same `NoDivisionByZero.spec` global-market predicate.

The stand-in does not need to reproduce the ghost hash implementation. An uninterpreted function must return the same result for identical arguments.

## Recommendation

Key both summaries by the full encoded market configuration. The existing `certora/helpers/Utils.sol` already exposes `hashMarket`:

```cvl
using Utils as Utils;

methods {
    function Utils.hashMarket(Midnight.Market) external returns (bytes32) envfree;
}

ghost hash(bytes32, uint256, address) returns bytes32;

function CVL_toId(Midnight.Market market, uint256 chainId, address midnight) returns bytes32 {
    bytes32 id = hash(Utils.hashMarket(market), chainId, midnight);
    // Preserve the existing loan-token and collateral-token mirror requirements.
    return id;
}
```

Add `certora/helpers/Utils.sol` to the affected configurations, replace prefix-only equality with full market identity, and rerun the proofs with sanity checks.
