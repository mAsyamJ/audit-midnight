// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {UtilsLib} from "../../../../src/libraries/UtilsLib.sol";
import {ORACLE_PRICE_SCALE, WAD} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev BB-POC-002 — non-zero oracle loss realization must not exceed the unrecoverable debt formula.
contract PoCBlackboxBadDebtRecoverabilityTest is Config {
    using UtilsLib for uint256;

    uint256 internal constant UNITS = 100e18;

    function testBlackbox_NonZeroPriceSocializesOnlyFormulaBoundedUnrecoverableDebt() public {
        _openBorrowerDebt(UNITS);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 2);

        uint256 debtBefore = midnight.debtOf(marketId, borrower);
        uint256 recoverable = _recoverableDebtAtMaxLif();
        uint256 expectedBadDebt = debtBefore.zeroFloorSub(recoverable);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);

        assertGt(expectedBadDebt, 0, "test setup has bounded bad debt");
        assertGt(recoverable, 0, "test uses non-zero recoverability");

        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertEq(totalUnitsBefore - midnight.totalUnits(marketId), expectedBadDebt, "slash equals unrecoverable debt");
        assertEq(midnight.debtOf(marketId, borrower), recoverable, "recoverable debt remains borrower debt");

        uint256 unitsBeforeSecondRealization = midnight.totalUnits(marketId);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
        assertEq(
            midnight.totalUnits(marketId), unitsBeforeSecondRealization, "no second slash while debt is recoverable"
        );
    }

    function _recoverableDebtAtMaxLif() internal view returns (uint256) {
        uint256 collateral = midnight.collateral(marketId, borrower, 0);
        uint256 price = Oracle(market.collateralParams[0].oracle).price();
        return collateral.mulDivUp(price, ORACLE_PRICE_SCALE).mulDivUp(WAD, market.collateralParams[0].maxLif);
    }
}
