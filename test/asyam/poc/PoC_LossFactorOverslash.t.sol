// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {IOracle} from "../../../src/interfaces/IOracle.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";
import {ORACLE_PRICE_SCALE, WAD} from "../../../src/libraries/ConstantsLib.sol";

/// @dev AP-008 / POC-INTENT-008 — bad-debt `lossFactor` must not slash lenders beyond socialized loss bounds.
contract PoCLossFactorOverslashTest is Config {
    using UtilsLib for uint256;
    using UtilsLib for uint128;

    function testPoC_LenderSlashMatchesBadDebtSocialization() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);

        uint256 creditBefore = midnight.creditOf(marketId, lender);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);

        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(units));
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        uint256 badDebt = _computeBadDebt();
        uint256 totalUnitsAfter = midnight.totalUnits(marketId);
        assertApproxEqAbs(totalUnitsAfter, totalUnitsBefore - badDebt, 1, "totalUnits drops by realized bad debt");

        midnight.updatePosition(market, lender);
        uint256 creditAfter = midnight.creditOf(marketId, lender);

        assertLt(creditAfter, creditBefore, "lender is slashed after bad debt");
        assertApproxEqAbs(creditAfter, totalUnitsAfter, 2, "slashed credit tracks remaining totalUnits");
        assertLe(creditAfter, creditBefore, "slash cannot increase lender credit");
        _assertMarketAccounting(marketId);
    }

    function testPoC_UpdatePositionWithoutBadDebtDoesNotSlashLender() public {
        uint256 units = 80e18;
        _openBorrowerDebt(units);

        uint256 creditBefore = midnight.creditOf(marketId, lender);
        uint128 lossFactorBefore = midnight.lossFactor(marketId);

        midnight.updatePosition(market, lender);

        assertEq(midnight.lossFactor(marketId), lossFactorBefore, "lossFactor unchanged");
        assertGe(midnight.creditOf(marketId, lender), creditBefore - 1, "no material slash without bad debt");
    }

    function testPoC_LenderCannotWithdrawMoreThanSlashedCredit() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);

        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(units));
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        midnight.updatePosition(market, lender);
        uint256 creditAfter = midnight.creditOf(marketId, lender);
        uint256 withdrawable = midnight.withdrawable(marketId);
        uint256 amount = creditAfter < withdrawable ? creditAfter : withdrawable;

        if (amount > 0) {
            vm.prank(lender);
            midnight.withdraw(market, amount, lender, lender);
        }

        vm.prank(lender);
        vm.expectRevert();
        midnight.withdraw(market, 1, lender, lender);
    }

    function testPoC_RepeatedBadDebtDoesNotOvershootTotalUnits() public {
        uint256 units = 120e18;
        _openBorrowerDebt(units);

        uint256 totalStart = midnight.totalUnits(marketId);
        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(units));

        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
        uint256 afterFirst = midnight.totalUnits(marketId);

        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
        assertEq(midnight.totalUnits(marketId), afterFirst, "second zero-liquidation does not shrink totalUnits again");
        assertLe(afterFirst, totalStart, "totalUnits monotonic");
    }

    function _badDebtPriceDown(uint256 units) internal view returns (uint256) {
        uint256 lltv = market.collateralParams[0].lltv;
        uint256 maxLif = market.collateralParams[0].maxLif;
        uint256 collateral = units.mulDivUp(WAD, lltv);
        return (units - 1).mulDivDown(maxLif, WAD).mulDivDown(ORACLE_PRICE_SCALE, collateral);
    }

    function _computeBadDebt() internal view returns (uint256 badDebt) {
        badDebt = midnight.debtOf(marketId, borrower);
        uint128 bitmap = midnight.collateralBitmap(marketId, borrower);
        while (bitmap != 0) {
            uint256 i = UtilsLib.msb(bitmap);
            uint256 price = IOracle(market.collateralParams[i].oracle).price();
            uint256 maxLif = market.collateralParams[i].maxLif;
            badDebt = badDebt.zeroFloorSub(
                uint256(midnight.collateral(marketId, borrower, i)).mulDivUp(price, ORACLE_PRICE_SCALE)
                    .mulDivUp(WAD, maxLif)
            );
            bitmap = bitmap.clearBit(i);
        }
    }
}
