// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {IMidnightBundles} from "../../../src/periphery/interfaces/IMidnightBundles.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";
import {Take, TokenPermit, CollateralWithdrawal, PermitKind} from "../../../src/periphery/interfaces/IMidnightBundles.sol";

/// @dev AP-016 / POC-INTENT-016 — bundle skip semantics vs documented helper-revert behavior.
contract PoCBundleHelperRevertSemanticsTest is Config {
    function testPoC_BundleSkipsFailingTakeAndFillsSecondOffer() public {
        uint256 goodUnits = 30e18;

        Offer memory expired = _basicSellOffer(borrower, market);
        expired.expiry = block.timestamp - 1;
        expired.maxUnits = 10e18;

        Offer memory good = _basicSellOffer(borrower, market);
        good.maxUnits = goodUnits;

        collateralize(market, borrower, goodUnits);
        _fundLoanToken(lender, goodUnits);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: expired, units: 10e18, ratifierData: hex""});
        takes[1] = Take({offer: good, units: goodUnits, ratifierData: hex""});

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            goodUnits,
            goodUnits,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.debtOf(marketId, borrower), goodUnits, "only good offer filled");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "no bundler residual");
    }

    function testPoC_ConsumableUnitsLibRevertAbortsWholeBundle() public {
        Offer memory badTick = _basicSellOffer(borrower, market);
        badTick.tick = 0;
        badTick.maxUnits = 0;
        badTick.maxAssets = 1;

        Offer memory good = _basicSellOffer(borrower, market);
        good.maxUnits = 20e18;

        collateralize(market, borrower, 20e18);
        _fundLoanToken(lender, 30e18);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: badTick, units: 1, ratifierData: hex""});
        takes[1] = Take({offer: good, units: 20e18, ratifierData: hex""});

        vm.prank(lender);
        vm.expectRevert();
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            20e18,
            30e18,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.debtOf(marketId, borrower), 0, "bundle aborted before any fill");
    }

    function testPoC_DocumentedHelperRevertIsNotTakeSkip() public {
        Offer memory bad = _basicSellOffer(borrower, market);
        bad.tick = 0;
        bad.maxUnits = 0;
        bad.maxAssets = 1;

        Offer memory good = _basicSellOffer(borrower, market);
        good.maxUnits = 15e18;

        collateralize(market, borrower, 15e18);
        _fundLoanToken(lender, 20e18);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: bad, units: 1, ratifierData: hex""});
        takes[1] = Take({offer: good, units: 15e18, ratifierData: hex""});

        vm.prank(lender);
        vm.expectRevert();
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            15e18,
            20e18,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.debtOf(marketId, borrower), 0, "helper revert aborts bundle; take skip does not apply");
    }

    function testPoC_OutOfOffersWhenSkipsCannotReachTarget() public {
        Offer memory expired = _basicSellOffer(borrower, market);
        expired.expiry = block.timestamp - 1;
        expired.maxUnits = 50e18;

        collateralize(market, borrower, 50e18);
        _fundLoanToken(lender, 50e18);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: expired, units: 50e18, ratifierData: hex""});

        vm.prank(lender);
        vm.expectRevert(IMidnightBundles.OutOfOffers.selector);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            50e18,
            50e18,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );
    }
}
