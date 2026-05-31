// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {IMidnight, Market, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {UtilsLib} from "../../../../src/libraries/UtilsLib.sol";
import {ORACLE_PRICE_SCALE, WAD} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev HPH-POC-002 — small collateral top-ups must not turn the RCF boundary into material lender loss.
contract PoCHistRcfTopUpLiquidationGriefTest is Config {
    using UtilsLib for uint256;

    uint256 internal constant UNITS = 100e18;
    uint256 internal constant LIQUIDATION_PRICE = ORACLE_PRICE_SCALE * 9 / 10;

    function testHist_SmallTopUpFlipsFullCloseToRcfButAdaptivePartialLiquidationRecoversHealth() public {
        (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();
        _fundLoanToken(LIQUIDATOR_ACTOR, UNITS);

        uint256 snapshot = vm.snapshotState();

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(rcfMarket, 0, 0, UNITS, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");
        assertEq(midnight.debtOf(id, borrower), 0, "control full-close liquidation succeeds below RCF threshold");
        assertEq(midnight.lossFactor(id), 0, "control liquidation realizes no bad debt");

        vm.revertToState(snapshot);

        uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);
        _supplyTopUp(rcfMarket, topUpAssets);

        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert(IMidnight.RecoveryCloseFactorConditionsViolated.selector);
        midnight.liquidate(rcfMarket, 0, 0, UNITS, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");

        uint256 maxRepaid = _maxRepaid(rcfMarket, id);
        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(rcfMarket, 0, 0, maxRepaid, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");

        assertEq(topUpAssets, 2, "two collateral wei cross the RCF threshold");
        assertGt(midnight.debtOf(id, borrower), 0, "RCF leaves a healthy residual position");
        assertTrue(midnight.isHealthy(rcfMarket, id, borrower), "adaptive RCF liquidation restores health");
        assertEq(midnight.lossFactor(id), 0, "small top-up does not create socialized loss");
        assertEq(midnight.withdrawable(id), maxRepaid, "lenders receive exactly the adaptive repayment");
    }

    function testHist_SmallTopUpCannotIncreaseBadDebtAtIdenticalPrice() public {
        (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();
        uint256 debtBefore = midnight.debtOf(id, borrower);
        uint256 totalUnitsBefore = midnight.totalUnits(id);

        uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);
        _supplyTopUp(rcfMarket, topUpAssets);

        midnight.liquidate(rcfMarket, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertEq(midnight.debtOf(id, borrower), debtBefore, "solvent boundary position realizes no bad debt");
        assertEq(midnight.totalUnits(id), totalUnitsBefore, "small collateral top-up cannot slash lenders");
        assertEq(midnight.lossFactor(id), 0, "loss factor remains unchanged");
    }

    function testHist_UnauthorizedThirdPartyCannotTopUpBorrowerToFlipRcf() public {
        (Market memory rcfMarket, bytes32 id, uint256 threshold) = _openBoundaryPosition();
        uint256 topUpAssets = _minimalTopUpToActivateRcf(rcfMarket, id, threshold);

        deal(rcfMarket.collateralParams[0].token, ATTACKER, topUpAssets);
        vm.startPrank(ATTACKER);
        collateralToken1.approve(address(midnight), topUpAssets);
        vm.expectRevert(IMidnight.Unauthorized.selector);
        midnight.supplyCollateral(rcfMarket, 0, topUpAssets, borrower);
        vm.stopPrank();
    }

    function _openBoundaryPosition() internal returns (Market memory rcfMarket, bytes32 id, uint256 threshold) {
        rcfMarket = _defaultMarket();
        uint256 initialCollateral = UNITS.mulDivUp(WAD, rcfMarket.collateralParams[0].lltv);
        uint256 maxRepaid = _maxRepaid(rcfMarket, initialCollateral, UNITS);
        threshold = _remainingRepayable(rcfMarket, initialCollateral, maxRepaid) + 1;
        rcfMarket.rcfThreshold = threshold;
        id = _touchMarket(rcfMarket);

        collateralize(rcfMarket, borrower, UNITS);
        Offer memory sellOffer = _basicSellOffer(borrower, rcfMarket);
        sellOffer.maxUnits = UNITS;
        vm.prank(lender);
        midnight.take(sellOffer, hex"", UNITS, lender, borrower, address(0), hex"");
        Oracle(rcfMarket.collateralParams[0].oracle).setPrice(LIQUIDATION_PRICE);

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
        for (topUpAssets = 1; topUpAssets <= 3; topUpAssets++) {
            uint256 maxRepaid = _maxRepaid(rcfMarket, collateral + topUpAssets, debt);
            if (_remainingRepayable(rcfMarket, collateral + topUpAssets, maxRepaid) >= threshold) return topUpAssets;
        }
        revert("small collateral top-up did not activate RCF");
    }

    function _supplyTopUp(Market memory rcfMarket, uint256 topUpAssets) internal {
        deal(rcfMarket.collateralParams[0].token, borrower, topUpAssets);
        vm.startPrank(borrower);
        collateralToken1.approve(address(midnight), topUpAssets);
        midnight.supplyCollateral(rcfMarket, 0, topUpAssets, borrower);
        vm.stopPrank();
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
