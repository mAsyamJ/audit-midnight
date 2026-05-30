// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {IMidnightBundles, Take, CollateralSupply, TokenPermit, CollateralWithdrawal, PermitKind} from "../../../src/periphery/interfaces/IMidnightBundles.sol";

contract InvariantBundleNoCrossCallBalanceLeakTest is Config {
    function testInvariant_BundlerLoanBalanceZeroAfterBuyBundle() public {
        Offer memory offer = _basicSellOffer(borrower, market);
        offer.maxUnits = 100;

        collateralize(market, borrower, 100);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: offer, units: 100, ratifierData: hex""});

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            100,
            200,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            lender,
            0,
            address(0)
        );

        _assertBundlerEmpty();
    }

    function testInvariant_BundlerLoanBalanceZeroAfterSellBundle() public {
        Offer memory offer = _basicBuyOffer(lender, market);
        offer.maxUnits = 100;

        collateralize(market, borrower, 100);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: offer, units: 100, ratifierData: hex""});

        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            100, 0, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        _assertBundlerEmpty();
    }
}
