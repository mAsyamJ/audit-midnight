// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Market, CollateralParams} from "../../../src/interfaces/IMidnight.sol";

/// @notice Demonstrates that Solvency.spec aliases production-distinct markets.
contract PoCSolvencySpecMarketIdAliasingTest is Config {
    function testPoC_SolvencySpecSummaryAliasesDistinctProductionMarkets() public {
        Market memory marketA = _defaultMarket();
        Market memory marketB = _defaultMarket();
        marketB.collateralParams[0].token = address(collateralToken2);
        marketB.collateralParams[0].oracle = address(oracle2);

        bytes32 productionIdA = midnight.touchMarket(marketA);
        bytes32 productionIdB = midnight.touchMarket(marketB);

        assertNotEq(productionIdA, productionIdB, "production ids include the full market configuration");
        assertGt(midnight.tickSpacing(productionIdA), 0, "first production market is valid");
        assertGt(midnight.tickSpacing(productionIdB), 0, "second production market is valid");

        assertEq(
            _solvencySpecSummaryKey(marketA),
            _solvencySpecSummaryKey(marketB),
            "Solvency.spec aliases markets that production separates"
        );
    }

    function testPoC_NoDivisionByZeroSpecSummaryAliasesMarketsDifferingAfterThirdCollateral() public {
        Market memory marketA = _fourCollateralMarket(address(0x1004));
        Market memory marketB = _fourCollateralMarket(address(0x1005));

        bytes32 productionIdA = midnight.touchMarket(marketA);
        bytes32 productionIdB = midnight.touchMarket(marketB);

        assertNotEq(productionIdA, productionIdB, "production ids include every collateral parameter");
        assertGt(midnight.tickSpacing(productionIdA), 0, "first four-collateral market is valid");
        assertGt(midnight.tickSpacing(productionIdB), 0, "second four-collateral market is valid");
        assertTrue(
            _noDivisionByZeroSpecEqualsGlobalMarket(marketA, marketB),
            "NoDivisionByZero.spec aliases markets that differ after collateral index 2"
        );
    }

    /// @dev Solvency.spec uses an uninterpreted ghost hash with exactly this input tuple.
    /// Equal tuple inputs necessarily return the same modeled ID, so keccak256 is only a readable stand-in.
    function _solvencySpecSummaryKey(Market memory market_) internal view returns (bytes32) {
        return keccak256(abi.encode(market_.loanToken, market_.maturity, midnight.INITIAL_CHAIN_ID(), address(midnight)));
    }

    function _fourCollateralMarket(address finalCollateralToken) internal view returns (Market memory market_) {
        market_ = _defaultMarket();
        CollateralParams memory template = market_.collateralParams[0];
        market_.collateralParams = new CollateralParams[](4);
        market_.collateralParams[0] = _withToken(template, address(0x1001));
        market_.collateralParams[1] = _withToken(template, address(0x1002));
        market_.collateralParams[2] = _withToken(template, address(0x1003));
        market_.collateralParams[3] = _withToken(template, finalCollateralToken);
    }

    function _withToken(CollateralParams memory params, address token) internal pure returns (CollateralParams memory) {
        return CollateralParams({token: token, lltv: params.lltv, maxLif: params.maxLif, oracle: params.oracle});
    }

    /// @dev Mirrors NoDivisionByZero.spec::equalsGlobalMarket, which only compares collateral indexes 0..2.
    function _noDivisionByZeroSpecEqualsGlobalMarket(Market memory globalMarket, Market memory candidate)
        internal
        pure
        returns (bool)
    {
        return globalMarket.loanToken == candidate.loanToken
            && globalMarket.collateralParams.length == candidate.collateralParams.length
            && _collateralParamsEqual(globalMarket.collateralParams[0], candidate.collateralParams[0])
            && _collateralParamsEqual(globalMarket.collateralParams[1], candidate.collateralParams[1])
            && _collateralParamsEqual(globalMarket.collateralParams[2], candidate.collateralParams[2])
            && globalMarket.maturity == candidate.maturity && globalMarket.rcfThreshold == candidate.rcfThreshold
            && globalMarket.enterGate == candidate.enterGate && globalMarket.liquidatorGate == candidate.liquidatorGate;
    }

    function _collateralParamsEqual(CollateralParams memory a, CollateralParams memory b)
        internal
        pure
        returns (bool)
    {
        return a.token == b.token && a.lltv == b.lltv && a.maxLif == b.maxLif && a.oracle == b.oracle;
    }
}
