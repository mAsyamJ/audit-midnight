// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {IMidnight, Market, Offer, CollateralParams} from "../../../../src/interfaces/IMidnight.sol";
import {RevertingLiquidatorGate} from "../../mocks/RevertingGate.sol";
import {ToggleOracle} from "../../mocks/ToggleOracle.sol";

/// @dev COMP-006 / COMP-020 — active oracle reverts and liquidator gates intentionally bound multi-collateral unwind
/// liveness.
contract PoCCompMultiCollateralOracleGateTest is Config {
    function testComp_ActivatedOracleRevertBlocksUnwindUntilOracleAndGateRecover() public {
        uint256 debtUnits = 100e18;
        uint256 repayUnits = 10e18;
        ToggleOracle toggleOracle = new ToggleOracle();
        RevertingLiquidatorGate liquidatorGate = new RevertingLiquidatorGate();
        (Market memory gatedMarket, uint256 stableIndex, uint256 toggleIndex) =
            _multiCollateralMarket(toggleOracle, liquidatorGate);
        bytes32 gatedId = _touchMarket(gatedMarket);

        collateralize(gatedMarket, borrower, debtUnits / 2, stableIndex);
        collateralize(gatedMarket, borrower, debtUnits / 2, toggleIndex);
        Offer memory debtOffer = _basicSellOffer(borrower, gatedMarket);
        debtOffer.maxUnits = debtUnits;
        vm.prank(lender);
        midnight.take(debtOffer, hex"", debtUnits, lender, borrower, address(0), hex"");
        vm.warp(gatedMarket.maturity + 1);

        toggleOracle.setShouldRevert(true);
        vm.expectRevert("oracle unavailable");
        midnight.liquidate(gatedMarket, stableIndex, 0, repayUnits, borrower, true, address(this), address(0), hex"");
        vm.prank(borrower);
        vm.expectRevert("oracle unavailable");
        midnight.withdrawCollateral(gatedMarket, stableIndex, 1, borrower, borrower);
        assertEq(midnight.debtOf(gatedId, borrower), debtUnits, "oracle liveness failure changes no debt");

        toggleOracle.setShouldRevert(false);
        liquidatorGate.setBlocked(true);
        vm.expectRevert(IMidnight.LiquidatorGatedFromLiquidating.selector);
        midnight.liquidate(gatedMarket, stableIndex, 0, repayUnits, borrower, true, address(this), address(0), hex"");

        liquidatorGate.setBlocked(false);
        deal(address(loanToken), address(this), repayUnits);
        midnight.liquidate(gatedMarket, stableIndex, 0, repayUnits, borrower, true, address(this), address(0), hex"");

        assertEq(midnight.debtOf(gatedId, borrower), debtUnits - repayUnits, "recovered oracle and gate allow unwind");
        _assertMarketAccounting(gatedId);
    }

    function _multiCollateralMarket(ToggleOracle toggleOracle, RevertingLiquidatorGate liquidatorGate)
        internal
        view
        returns (Market memory gatedMarket, uint256 stableIndex, uint256 toggleIndex)
    {
        CollateralParams memory stable = market.collateralParams[0];
        CollateralParams memory toggled = CollateralParams({
            token: address(collateralToken2), lltv: stable.lltv, maxLif: stable.maxLif, oracle: address(toggleOracle)
        });
        CollateralParams[] memory params = new CollateralParams[](2);
        if (stable.token < toggled.token) {
            params[0] = stable;
            params[1] = toggled;
            stableIndex = 0;
            toggleIndex = 1;
        } else {
            params[0] = toggled;
            params[1] = stable;
            stableIndex = 1;
            toggleIndex = 0;
        }
        gatedMarket = Market({
            loanToken: address(loanToken),
            collateralParams: params,
            maturity: block.timestamp + 100,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(liquidatorGate)
        });
    }
}
