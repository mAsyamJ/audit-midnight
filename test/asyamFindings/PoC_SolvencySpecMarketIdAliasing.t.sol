// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {AsyamFindingConfig} from "./config.t.sol";
import {Market} from "../../src/interfaces/IMidnight.sol";

/// @notice Stable validation for the Solvency.spec market-ID aliasing model gap.
contract PoCSolvencySpecMarketIdAliasingTest is AsyamFindingConfig {
    function testValidation_SolvencySpecSummaryAliasesDistinctProductionMarkets() public {
        Market memory marketA = _singleCollateralMarket();
        Market memory marketB = _singleCollateralMarket();
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

    /// @dev Solvency.spec uses an uninterpreted ghost hash with exactly this input tuple.
    /// Equal tuple inputs necessarily return the same modeled ID, so keccak256 is only a readable stand-in.
    function _solvencySpecSummaryKey(Market memory market_) internal view returns (bytes32) {
        return keccak256(abi.encode(market_.loanToken, market_.maturity, midnight.INITIAL_CHAIN_ID(), address(midnight)));
    }
}
