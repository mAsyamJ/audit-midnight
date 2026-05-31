// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {IMidnight, Market, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {UtilsLib} from "../../../../src/libraries/UtilsLib.sol";
import {ORACLE_PRICE_SCALE, WAD} from "../../../../src/libraries/ConstantsLib.sol";

import {console2} from "forge-std/console2.sol";

/// @dev HPH-POC-002 — small collateral top-ups must not turn the RCF boundary into material lender loss.
contract PoCHistRcfTopUpLiquidationGriefTest is Config {
    using UtilsLib for uint256;

    uint256 internal constant UNITS = 100e18;
    uint256 internal constant LIQUIDATION_PRICE = ORACLE_PRICE_SCALE * 9 / 10;

    function testHist_SmallTopUpFlipsFullCloseToRcfButAdaptivePartialLiquidationRecoversHealth() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC 1: Small collateral top-up flips full-close liquidation into RCF");
        console2.log("======================================================================");

        console2.log("[1] Opening boundary borrower position");
        (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();

        console2.log("    market id:");
        console2.logBytes32(id);
        console2.log("    borrower:", borrower);
        console2.log("    lender:", lender);
        console2.log("    liquidator:", LIQUIDATOR_ACTOR);
        console2.log("    rcfThreshold:", threshold);
        console2.log("    loanToken:", rcfMarket.loanToken);
        console2.log("    collateral token:", rcfMarket.collateralParams[0].token);
        console2.log("    collateral oracle:", rcfMarket.collateralParams[0].oracle);
        console2.log("    lltv:", rcfMarket.collateralParams[0].lltv);
        console2.log("    maxLif:", rcfMarket.collateralParams[0].maxLif);
        console2.log("    borrower collateral:", midnight.collateral(id, borrower, 0));
        console2.log("    borrower debt:", midnight.debtOf(id, borrower));
        console2.log("    borrower healthy:", midnight.isHealthy(rcfMarket, id, borrower));
        console2.log("    lossFactor:", midnight.lossFactor(id));

        console2.log("[2] Funding liquidator with loan tokens");
        _fundLoanToken(LIQUIDATOR_ACTOR, UNITS);
        console2.log("    liquidator balance:", IERC20Like(rcfMarket.loanToken).balanceOf(LIQUIDATOR_ACTOR));
        console2.log("    liquidation full-close units:", UNITS);

        console2.log("[3] Taking snapshot before control full-close liquidation");
        uint256 snapshot = vm.snapshotState();
        console2.log("    snapshot id:", snapshot);

        console2.log("[4] Control path: full-close liquidation before top-up");
        console2.log("    borrower debt before control:", midnight.debtOf(id, borrower));
        console2.log("    borrower collateral before control:", midnight.collateral(id, borrower, 0));

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(
            rcfMarket,
            0,
            0,
            UNITS,
            borrower,
            false,
            LIQUIDATOR_ACTOR,
            address(0),
            hex""
        );

        console2.log("    borrower debt after control:", midnight.debtOf(id, borrower));
        console2.log("    lossFactor after control:", midnight.lossFactor(id));
        console2.log("    withdrawable after control:", midnight.withdrawable(id));

        assertEq(
            midnight.debtOf(id, borrower),
            0,
            "control full-close liquidation succeeds below RCF threshold"
        );
        console2.log("    OK: control full-close liquidation succeeds");

        assertEq(
            midnight.lossFactor(id),
            0,
            "control liquidation realizes no bad debt"
        );
        console2.log("    OK: control liquidation realizes no bad debt");

        console2.log("[5] Reverting to snapshot");
        vm.revertToState(snapshot);

        console2.log("    borrower debt after revert:", midnight.debtOf(id, borrower));
        console2.log("    borrower collateral after revert:", midnight.collateral(id, borrower, 0));
        console2.log("    lossFactor after revert:", midnight.lossFactor(id));

        console2.log("[6] Calculating minimal borrower collateral top-up");
        uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);

        console2.log("    minimal topUpAssets:", topUpAssets);
        console2.log("    expected topUpAssets:", uint256(2));

        console2.log("[7] Borrower supplies minimal top-up");
        _supplyTopUp(rcfMarket, topUpAssets);

        console2.log("    borrower collateral after top-up:", midnight.collateral(id, borrower, 0));
        console2.log("    borrower debt after top-up:", midnight.debtOf(id, borrower));
        console2.log("    borrower healthy after top-up:", midnight.isHealthy(rcfMarket, id, borrower));

        uint256 maxRepaidAfterTopUpPreview = _maxRepaid(rcfMarket, id);
        uint256 remainingAfterTopUpPreview = _remainingRepayable(
            rcfMarket,
            midnight.collateral(id, borrower, 0),
            maxRepaidAfterTopUpPreview
        );

        console2.log("    maxRepaid after top-up:", maxRepaidAfterTopUpPreview);
        console2.log("    remaining repayable after top-up:", remainingAfterTopUpPreview);
        console2.log("    rcfThreshold:", threshold);

        console2.log("[8] Stale full-close liquidation tries old UNITS amount");
        console2.log("    stale repaidUnits:", UNITS);
        console2.log("    current valid maxRepaid:", maxRepaidAfterTopUpPreview);
        console2.log("    expected revert: RecoveryCloseFactorConditionsViolated");

        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert(IMidnight.RecoveryCloseFactorConditionsViolated.selector);
        midnight.liquidate(
            rcfMarket,
            0,
            0,
            UNITS,
            borrower,
            false,
            LIQUIDATOR_ACTOR,
            address(0),
            hex""
        );

        console2.log("    OK: stale full-close liquidation reverted");

        console2.log("[9] Adaptive retry: recompute maxRepaid and liquidate current RCF amount");
        uint256 maxRepaid = _maxRepaid(rcfMarket, id);

        console2.log("    adaptive maxRepaid:", maxRepaid);
        console2.log("    borrower debt before adaptive liquidation:", midnight.debtOf(id, borrower));
        console2.log("    borrower collateral before adaptive liquidation:", midnight.collateral(id, borrower, 0));

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(
            rcfMarket,
            0,
            0,
            maxRepaid,
            borrower,
            false,
            LIQUIDATOR_ACTOR,
            address(0),
            hex""
        );

        console2.log("    borrower debt after adaptive liquidation:", midnight.debtOf(id, borrower));
        console2.log("    borrower collateral after adaptive liquidation:", midnight.collateral(id, borrower, 0));
        console2.log("    borrower healthy after adaptive liquidation:", midnight.isHealthy(rcfMarket, id, borrower));
        console2.log("    lossFactor after adaptive liquidation:", midnight.lossFactor(id));
        console2.log("    withdrawable after adaptive liquidation:", midnight.withdrawable(id));

        assertEq(topUpAssets, 2, "two collateral wei cross the RCF threshold");
        console2.log("    OK: two collateral wei crossed the RCF threshold");

        assertGt(
            midnight.debtOf(id, borrower),
            0,
            "RCF leaves a healthy residual position"
        );
        console2.log("    OK: RCF leaves residual debt instead of full close");

        assertTrue(
            midnight.isHealthy(rcfMarket, id, borrower),
            "adaptive RCF liquidation restores health"
        );
        console2.log("    OK: adaptive RCF liquidation restores health");

        assertEq(
            midnight.lossFactor(id),
            0,
            "small top-up does not create socialized loss"
        );
        console2.log("    OK: small top-up does not create socialized loss");

        assertEq(
            midnight.withdrawable(id),
            maxRepaid,
            "lenders receive exactly the adaptive repayment"
        );
        console2.log("    OK: lenders receive exactly the adaptive repayment");

        console2.log("[10] RESULT");
        console2.log("    Borrower top-up invalidates stale full-close liquidation.");
        console2.log("    Adaptive RCF-sized liquidation succeeds.");
        console2.log("    Position becomes healthy.");
        console2.log("    No bad debt or lender slash is created.");
        console2.log("======================================================================");
        console2.log("");
    }

    function testHist_SmallTopUpCannotIncreaseBadDebtAtIdenticalPrice() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC 2: Small top-up cannot increase bad debt at identical price");
        console2.log("======================================================================");

        console2.log("[1] Opening boundary borrower position");
        (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();

        uint256 debtBefore = midnight.debtOf(id, borrower);
        uint256 totalUnitsBefore = midnight.totalUnits(id);
        uint256 lossFactorBefore = midnight.lossFactor(id);

        console2.log("    market id:");
        console2.logBytes32(id);
        console2.log("    rcfThreshold:", threshold);
        console2.log("    borrower debt before:", debtBefore);
        console2.log("    borrower collateral before:", midnight.collateral(id, borrower, 0));
        console2.log("    totalUnits before:", totalUnitsBefore);
        console2.log("    lossFactor before:", lossFactorBefore);
        console2.log("    borrower healthy before:", midnight.isHealthy(rcfMarket, id, borrower));

        console2.log("[2] Calculating and supplying minimal top-up");
        uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);

        console2.log("    topUpAssets:", topUpAssets);
        _supplyTopUp(rcfMarket, topUpAssets);

        console2.log("    borrower debt after top-up:", midnight.debtOf(id, borrower));
        console2.log("    borrower collateral after top-up:", midnight.collateral(id, borrower, 0));
        console2.log("    totalUnits after top-up:", midnight.totalUnits(id));
        console2.log("    lossFactor after top-up:", midnight.lossFactor(id));

        console2.log("[3] Attempting zero-repay liquidation at identical liquidation price");
        console2.log("    repaidUnits:", uint256(0));
        console2.log("    expected: no bad debt because boundary position is solvent after top-up");

        midnight.liquidate(
            rcfMarket,
            0,
            0,
            0,
            borrower,
            false,
            address(0),
            address(0),
            hex""
        );

        console2.log("    borrower debt after liquidation:", midnight.debtOf(id, borrower));
        console2.log("    totalUnits after liquidation:", midnight.totalUnits(id));
        console2.log("    lossFactor after liquidation:", midnight.lossFactor(id));

        assertEq(
            midnight.debtOf(id, borrower),
            debtBefore,
            "solvent boundary position realizes no bad debt"
        );
        console2.log("    OK: borrower debt unchanged, no bad debt realized");

        assertEq(
            midnight.totalUnits(id),
            totalUnitsBefore,
            "small collateral top-up cannot slash lenders"
        );
        console2.log("    OK: totalUnits unchanged, lenders are not slashed");

        assertEq(
            midnight.lossFactor(id),
            0,
            "loss factor remains unchanged"
        );
        console2.log("    OK: lossFactor remains zero");

        console2.log("[4] RESULT");
        console2.log("    Small collateral top-up does not increase bad debt.");
        console2.log("    Small collateral top-up does not slash lender units.");
        console2.log("======================================================================");
        console2.log("");
    }

    function testHist_UnauthorizedThirdPartyCannotTopUpBorrowerToFlipRcf() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC 3: Unauthorized third party cannot top-up borrower collateral");
        console2.log("======================================================================");

        console2.log("[1] Opening boundary borrower position");
        (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();

        console2.log("    market id:");
        console2.logBytes32(id);
        console2.log("    borrower:", borrower);
        console2.log("    attacker:", ATTACKER);
        console2.log("    rcfThreshold:", threshold);
        console2.log("    borrower collateral:", midnight.collateral(id, borrower, 0));
        console2.log("    borrower debt:", midnight.debtOf(id, borrower));

        console2.log("[2] Calculating minimal top-up amount");
        uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);

        console2.log("    topUpAssets:", topUpAssets);

        console2.log("[3] Funding attacker with collateral token");
        deal(rcfMarket.collateralParams[0].token, ATTACKER, topUpAssets);
        console2.log("    attacker collateral balance:", IERC20Like(rcfMarket.collateralParams[0].token).balanceOf(ATTACKER));

        console2.log("[4] Attacker attempts to top-up borrower collateral");
        console2.log("    expected revert: IMidnight.Unauthorized");

        vm.startPrank(ATTACKER);
        collateralToken1.approve(address(midnight), topUpAssets);
        vm.expectRevert(IMidnight.Unauthorized.selector);
        midnight.supplyCollateral(rcfMarket, 0, topUpAssets, borrower);
        vm.stopPrank();

        console2.log("    OK: unauthorized top-up reverted");

        console2.log("[5] Validating borrower state unchanged");
        console2.log("    borrower collateral after failed attacker top-up:", midnight.collateral(id, borrower, 0));
        console2.log("    borrower debt after failed attacker top-up:", midnight.debtOf(id, borrower));

        console2.log("[6] RESULT");
        console2.log("    Third party cannot mutate borrower collateral to flip RCF.");
        console2.log("    The griefing action requires the borrower or authorized operator.");
        console2.log("======================================================================");
        console2.log("");
    }

    function _openBoundaryPosition() internal returns (Market memory rcfMarket, bytes32 id, uint256 threshold) {
        console2.log("    [_openBoundaryPosition] Building default market");
        rcfMarket = _defaultMarket();

        console2.log("    [_openBoundaryPosition] Calculating initial collateral");
        uint256 initialCollateral = UNITS.mulDivUp(WAD, rcfMarket.collateralParams[0].lltv);

        console2.log("    [_openBoundaryPosition] initialCollateral:", initialCollateral);
        console2.log("    [_openBoundaryPosition] liquidation price:", LIQUIDATION_PRICE);

        uint256 maxRepaid = _maxRepaid(rcfMarket, initialCollateral, UNITS);
        uint256 remainingRepayable = _remainingRepayable(rcfMarket, initialCollateral, maxRepaid);

        console2.log("    [_openBoundaryPosition] computed maxRepaid:", maxRepaid);
        console2.log("    [_openBoundaryPosition] remainingRepayable:", remainingRepayable);

        threshold = remainingRepayable + 1;
        rcfMarket.rcfThreshold = threshold;

        console2.log("    [_openBoundaryPosition] rcfThreshold set to:", threshold);

        id = _touchMarket(rcfMarket);

        console2.log("    [_openBoundaryPosition] touched market id:");
        console2.logBytes32(id);

        console2.log("    [_openBoundaryPosition] Collateralizing borrower");
        collateralize(rcfMarket, borrower, UNITS);

        console2.log("    [_openBoundaryPosition] borrower collateral after collateralize:", midnight.collateral(id, borrower, 0));

        console2.log("    [_openBoundaryPosition] Creating borrower sell offer");
        Offer memory sellOffer = _basicSellOffer(borrower, rcfMarket);
        sellOffer.maxUnits = UNITS;

        console2.log("    [_openBoundaryPosition] sellOffer.maxUnits:", sellOffer.maxUnits);

        console2.log("    [_openBoundaryPosition] Lender takes sell offer to open borrower debt");
        vm.prank(lender);
        midnight.take(
            sellOffer,
            hex"",
            UNITS,
            lender,
            borrower,
            address(0),
            hex""
        );

        console2.log("    [_openBoundaryPosition] borrower debt after take:", midnight.debtOf(id, borrower));
        console2.log("    [_openBoundaryPosition] lender credit after take:", midnight.creditOf(id, lender));
        console2.log("    [_openBoundaryPosition] totalUnits after take:", midnight.totalUnits(id));

        console2.log("    [_openBoundaryPosition] Lowering oracle price to liquidation price");
        Oracle(rcfMarket.collateralParams[0].oracle).setPrice(LIQUIDATION_PRICE);

        console2.log("    [_openBoundaryPosition] borrower healthy after price drop:", midnight.isHealthy(rcfMarket, id, borrower));
        console2.log("    [_openBoundaryPosition] lossFactor:", midnight.lossFactor(id));

        assertFalse(midnight.isHealthy(rcfMarket, id, borrower), "boundary setup is liquidatable");
        assertEq(midnight.lossFactor(id), 0, "boundary setup has no socialized loss");
    }

    function _minimalTopUpToActivateRcf(Market memory rcfMarket, bytes32 id, uint256 threshold)
        internal
        view
        returns (uint256 topUpAssets)
    {
        uint256 collateral = midnight.collateral(id, borrower, 0);
        uint256 debt = midnight.debtOf(id, borrower);

        console2.log("    [_minimalTopUpToActivateRcf] current collateral:", collateral);
        console2.log("    [_minimalTopUpToActivateRcf] current debt:", debt);
        console2.log("    [_minimalTopUpToActivateRcf] threshold:", threshold);

        for (topUpAssets = 1; topUpAssets <= 3; topUpAssets++) {
            uint256 candidateCollateral = collateral + topUpAssets;
            uint256 maxRepaid = _maxRepaid(rcfMarket, candidateCollateral, debt);
            uint256 remaining = _remainingRepayable(rcfMarket, candidateCollateral, maxRepaid);

            console2.log("    [_minimalTopUpToActivateRcf] candidate topUpAssets:", topUpAssets);
            console2.log("    [_minimalTopUpToActivateRcf] candidate collateral:", candidateCollateral);
            console2.log("    [_minimalTopUpToActivateRcf] candidate maxRepaid:", maxRepaid);
            console2.log("    [_minimalTopUpToActivateRcf] candidate remaining:", remaining);

            if (remaining >= threshold) {
                console2.log("    [_minimalTopUpToActivateRcf] selected topUpAssets:", topUpAssets);
                return topUpAssets;
            }
        }

        revert("small collateral top-up did not activate RCF");
    }

    function _supplyTopUp(Market memory rcfMarket, uint256 topUpAssets) internal {
        console2.log("    [_supplyTopUp] Dealing collateral to borrower");
        deal(rcfMarket.collateralParams[0].token, borrower, topUpAssets);

        console2.log("    [_supplyTopUp] borrower collateral token balance:", IERC20Like(rcfMarket.collateralParams[0].token).balanceOf(borrower));
        console2.log("    [_supplyTopUp] approving Midnight for topUpAssets:", topUpAssets);

        vm.startPrank(borrower);
        collateralToken1.approve(address(midnight), topUpAssets);

        console2.log("    [_supplyTopUp] supplying collateral top-up");
        midnight.supplyCollateral(rcfMarket, 0, topUpAssets, borrower);
        vm.stopPrank();

        console2.log("    [_supplyTopUp] top-up complete");
    }

    function _maxRepaid(Market memory rcfMarket, bytes32 id) internal view returns (uint256) {
        return _maxRepaid(rcfMarket, midnight.collateral(id, borrower, 0), midnight.debtOf(id, borrower));
    }

    function _maxRepaid(Market memory rcfMarket, uint256 collateral, uint256 debt) internal pure returns (uint256) {
        uint256 lltv = rcfMarket.collateralParams[0].lltv;
        uint256 lif = rcfMarket.collateralParams[0].maxLif;
        uint256 maxDebt = collateral.mulDivDown(LIQUIDATION_PRICE, ORACLE_PRICE_SCALE).mulDivDown(lltv, WAD);
        return (debt - maxDebt).mulDivUp(WAD * WAD, WAD * WAD - lif * lltv);
    }

    function _remainingRepayable(Market memory rcfMarket, uint256 collateral, uint256 maxRepaid)
        internal
        pure
        returns (uint256)
    {
        return collateral.mulDivDown(LIQUIDATION_PRICE, ORACLE_PRICE_SCALE)
            .mulDivDown(WAD, rcfMarket.collateralParams[0].maxLif).zeroFloorSub(maxRepaid);
    }
}

interface IERC20Like {
    function balanceOf(address account) external view returns (uint256);
}