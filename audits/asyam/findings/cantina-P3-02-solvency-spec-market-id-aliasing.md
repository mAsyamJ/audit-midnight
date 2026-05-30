# Cantina Submission - P3-02

## Cantina UI Fields

| Field | Value |
|---|---|
| **Finding Title** | `Solvency.spec` aliases distinct production markets and can prune valid multi-market traces |
| **Likelihood** | Medium |
| **Impact** | Low |
| **Severity** | Informational / P3 formal-assurance gap |
| **PoC location** | `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol` |
| **PoC type** | Local Foundry model-mismatch validation (no fork required) |

---

## Summary

The `Solvency.spec` summary for `IdLib.toId` derives a modeled market ID from only `loanToken`, `maturity`, `chainId`, and the Midnight address. Production `IdLib.toId` derives the ID from the entire `Market` configuration. As a result, the CVL model aliases valid production markets that share a loan token and maturity but differ in collateral configuration, gates, or recovery-close-factor threshold.

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

## Impact Explanation

**Impact: Low / formal-assurance gap**

This does not demonstrate a production insolvency exploit. It means the current CVL proof does not establish its advertised solvency invariant across all supported multi-market configurations. A future accounting regression that manifests only across aliased market configurations could remain undetected by this proof.

## Likelihood Explanation

**Likelihood: Medium**

The protocol intentionally supports multiple markets with the same loan token and maturity. Changing collateral configuration, gates, or `rcfThreshold` is sufficient to produce a distinct production market while preserving the reduced CVL key.

## Proof of Concept

Run:

```bash
forge test --match-path test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol -vvvv
```

The test creates two valid markets with the same loan token and maturity but different collateral tokens. It then proves:

- `Midnight.toId` returns different production IDs.
- both production markets are created successfully.
- a deterministic stand-in for the CVL ghost-hash input tuple returns the same key for both markets.

The stand-in does not need to reproduce the ghost hash implementation. An uninterpreted function must return the same result for identical arguments.

## Recommendation

Key the solvency summary by the full encoded market configuration. The existing `certora/helpers/Utils.sol` already exposes `hashMarket`:

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

Add `certora/helpers/Utils.sol` to `certora/confs/Solvency.conf` and rerun the solvency proof with sanity checks.
