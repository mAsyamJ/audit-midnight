// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {AsyamFindingConfig} from "./config.t.sol";
import {Market} from "../../src/interfaces/IMidnight.sol";

import {console2} from "forge-std/console2.sol";

/// @notice Stable validation for the Solvency.spec market-ID aliasing model gap.
contract PoCSolvencySpecMarketIdAliasingTest is AsyamFindingConfig {
    function testValidation_SolvencySpecSummaryAliasesDistinctProductionMarkets() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC: Solvency.spec aliases distinct production markets");
        console2.log("======================================================================");

        console2.log("[1] Creating Market A from default single-collateral helper");
        Market memory marketA = _singleCollateralMarket();

        console2.log("    Market A loanToken:", marketA.loanToken);
        console2.log("    Market A maturity:", marketA.maturity);
        console2.log("    Market A rcfThreshold:", marketA.rcfThreshold);
        console2.log("    Market A enterGate:", marketA.enterGate);
        console2.log("    Market A liquidatorGate:", marketA.liquidatorGate);
        console2.log("    Market A collateral token[0]:", marketA.collateralParams[0].token);
        console2.log("    Market A collateral oracle[0]:", marketA.collateralParams[0].oracle);
        console2.log("    Market A collateral lltv[0]:", marketA.collateralParams[0].lltv);
        console2.log("    Market A collateral maxLif[0]:", marketA.collateralParams[0].maxLif);

        console2.log("[2] Creating Market B from same helper");
        Market memory marketB = _singleCollateralMarket();

        console2.log("    Before mutation:");
        console2.log("    Market B loanToken:", marketB.loanToken);
        console2.log("    Market B maturity:", marketB.maturity);
        console2.log("    Market B collateral token[0]:", marketB.collateralParams[0].token);
        console2.log("    Market B collateral oracle[0]:", marketB.collateralParams[0].oracle);

        console2.log("[3] Mutating Market B collateral configuration");
        console2.log("    Market B keeps same loanToken and maturity");
        console2.log("    Market B changes collateral token and oracle");

        marketB.collateralParams[0].token = address(collateralToken2);
        marketB.collateralParams[0].oracle = address(oracle2);

        console2.log("    After mutation:");
        console2.log("    Market B loanToken:", marketB.loanToken);
        console2.log("    Market B maturity:", marketB.maturity);
        console2.log("    Market B rcfThreshold:", marketB.rcfThreshold);
        console2.log("    Market B enterGate:", marketB.enterGate);
        console2.log("    Market B liquidatorGate:", marketB.liquidatorGate);
        console2.log("    Market B collateral token[0]:", marketB.collateralParams[0].token);
        console2.log("    Market B collateral oracle[0]:", marketB.collateralParams[0].oracle);
        console2.log("    Market B collateral lltv[0]:", marketB.collateralParams[0].lltv);
        console2.log("    Market B collateral maxLif[0]:", marketB.collateralParams[0].maxLif);

        console2.log("[4] Sanity check: markets share the reduced Solvency.spec key fields");
        console2.log("    Same loanToken:", marketA.loanToken == marketB.loanToken);
        console2.log("    Same maturity:", marketA.maturity == marketB.maturity);
        console2.log("    Same chainId used by Midnight:", midnight.INITIAL_CHAIN_ID());
        console2.log("    Same Midnight address:", address(midnight));

        console2.log("[5] Sanity check: markets differ in full production configuration");
        console2.log("    Different collateral token[0]:", marketA.collateralParams[0].token != marketB.collateralParams[0].token);
        console2.log("    Different collateral oracle[0]:", marketA.collateralParams[0].oracle != marketB.collateralParams[0].oracle);

        console2.log("[6] Creating / touching Market A in production Midnight");
        bytes32 productionIdA = midnight.touchMarket(marketA);

        console2.log("    productionIdA:");
        console2.logBytes32(productionIdA);
        console2.log("    tickSpacing(productionIdA):", midnight.tickSpacing(productionIdA));

        console2.log("[7] Creating / touching Market B in production Midnight");
        bytes32 productionIdB = midnight.touchMarket(marketB);

        console2.log("    productionIdB:");
        console2.logBytes32(productionIdB);
        console2.log("    tickSpacing(productionIdB):", midnight.tickSpacing(productionIdB));

        console2.log("[8] Validating production behavior");
        console2.log("    Production IdLib.toId includes full Market configuration");
        console2.log("    Therefore Market A and Market B should have different IDs");

        assertNotEq(
            productionIdA,
            productionIdB,
            "production ids include the full market configuration"
        );

        console2.log("    OK: productionIdA != productionIdB");

        assertGt(
            midnight.tickSpacing(productionIdA),
            0,
            "first production market is valid"
        );

        console2.log("    OK: first production market is valid");

        assertGt(
            midnight.tickSpacing(productionIdB),
            0,
            "second production market is valid"
        );

        console2.log("    OK: second production market is valid");

        console2.log("[9] Computing Solvency.spec modeled summary keys");
        console2.log("    Solvency.spec key fields:");
        console2.log("      - loanToken");
        console2.log("      - maturity");
        console2.log("      - chainId");
        console2.log("      - Midnight address");
        console2.log("    Omitted production fields include:");
        console2.log("      - collateral token");
        console2.log("      - collateral oracle");
        console2.log("      - collateral LLTV");
        console2.log("      - collateral maxLif");
        console2.log("      - gates");
        console2.log("      - rcfThreshold");

        bytes32 solvencyKeyA = _solvencySpecSummaryKey(marketA);
        bytes32 solvencyKeyB = _solvencySpecSummaryKey(marketB);

        console2.log("    solvencyKeyA:");
        console2.logBytes32(solvencyKeyA);

        console2.log("    solvencyKeyB:");
        console2.logBytes32(solvencyKeyB);

        console2.log("[10] Validating CVL model aliasing");
        console2.log("    Because the reduced input tuple is identical, the modeled key aliases");

        assertEq(
            solvencyKeyA,
            solvencyKeyB,
            "Solvency.spec aliases markets that production separates"
        );

        console2.log("    OK: solvencyKeyA == solvencyKeyB");
        console2.log("");
        console2.log("[11] RESULT");
        console2.log("    Production separates the two markets:");
        console2.log("      productionIdA != productionIdB");
        console2.log("    Solvency.spec summary aliases the two markets:");
        console2.log("      solvencyKeyA == solvencyKeyB");
        console2.log("");
        console2.log("    This proves a formal-assurance model mismatch:");
        console2.log("    valid multi-market production traces can be collapsed or pruned");
        console2.log("    by the reduced CVL market-ID summary.");
        console2.log("======================================================================");
        console2.log("");
    }

    /// @dev Solvency.spec uses an uninterpreted ghost hash with exactly this input tuple.
    /// Equal tuple inputs necessarily return the same modeled ID, so keccak256 is only a readable stand-in.
    function _solvencySpecSummaryKey(Market memory market_) internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                market_.loanToken,
                market_.maturity,
                midnight.INITIAL_CHAIN_ID(),
                address(midnight)
            )
        );
    }
}