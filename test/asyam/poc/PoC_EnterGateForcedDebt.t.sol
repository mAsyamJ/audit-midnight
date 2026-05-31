// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Market, Offer, CollateralParams} from "../../../src/interfaces/IMidnight.sol";
import {RevertingEnterGate} from "../mocks/RevertingGate.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";

/// @dev AP-018 / POC-INTENT-018 — enter gate must block non-consenting seller debt increases.
contract PoCEnterGateForcedDebtTest is Config {
    RevertingEnterGate internal enterGate;

    function setUp() public override {
        super.setUp();
        enterGate = new RevertingEnterGate();
        enterGate.setBlocks(false, true);
    }

    function testPoC_EnterGateBlocksSellerDebtIncrease() public {
        Market memory gated = _gatedMarket();
        bytes32 gatedId = _touchMarket(gated);

        uint256 units = 50e18;
        collateralize(gated, borrower, units);
        _fundLoanToken(lender, units);

        Offer memory sellOffer = _basicSellOffer(borrower, gated);
        sellOffer.maxUnits = units;

        vm.prank(lender);
        vm.expectRevert();
        midnight.take(sellOffer, hex"", units, lender, borrower, address(0), hex"");

        assertEq(midnight.debtOf(gatedId, borrower), 0, "seller debt not forced");
    }

    function testPoC_EnterGateAllowsDebtWhenConfigured() public {
        enterGate.setBlocks(false, false);

        Market memory gated = _gatedMarket();
        bytes32 gatedId = _touchMarket(gated);

        uint256 units = 40e18;
        collateralize(gated, borrower, units);
        _fundLoanToken(lender, units);

        Offer memory sellOffer = _basicSellOffer(borrower, gated);
        sellOffer.maxUnits = units;

        vm.prank(lender);
        midnight.take(sellOffer, hex"", units, lender, borrower, address(0), hex"");

        assertEq(midnight.debtOf(gatedId, borrower), units, "debt allowed when gate permits");
    }

    function _gatedMarket() internal view returns (Market memory m) {
        CollateralParams[] memory collateralParams = new CollateralParams[](1);
        collateralParams[0] = market.collateralParams[0];
        m = Market({
            loanToken: address(loanToken),
            collateralParams: collateralParams,
            maturity: vm.getBlockTimestamp() + 200 days,
            rcfThreshold: 0,
            enterGate: address(enterGate),
            liquidatorGate: address(0)
        });
    }
}
