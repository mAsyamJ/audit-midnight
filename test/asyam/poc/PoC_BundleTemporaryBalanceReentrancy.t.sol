// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {IMidnightBundles, Take, CollateralSupply, TokenPermit} from "../../../src/periphery/interfaces/IMidnightBundles.sol";
import {BundleReentrantAttacker} from "../mocks/BundleReentrantAttacker.sol";

/// @dev MIDNIGHT-CAND-026 — periphery temporary loan-token balance theft via callback reentry.
contract PoCBundleTemporaryBalanceReentrancyTest is Config {
    function testPoC_BundlerBalanceNotStealableViaMaliciousBuyCallback() public {
        BundleReentrantAttacker attackerCb = new BundleReentrantAttacker();
        attackerCb.configure(midnightBundles, ATTACKER);

        vm.prank(lender);
        midnight.setIsAuthorized(address(attackerCb), true, lender);
        vm.prank(lender);
        loanToken.approve(address(attackerCb), type(uint256).max);

        uint256 targetUnits = 100;

        Offer memory offer = _basicBuyOffer(lender, market);
        offer.maxUnits = targetUnits;
        offer.callback = address(attackerCb);

        collateralize(market, borrower, targetUnits);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: offer, units: targetUnits, ratifierData: hex""});

        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);

        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            targetUnits, 0, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        assertTrue(attackerCb.attemptedReentry(), "callback should have run");
        assertEq(attackerCb.extracted(), 0, "attacker cannot transferFrom bundler without approval");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "attacker profit");
        assertEq(midnight.debtOf(marketId, borrower), targetUnits, "borrower debt");
        _assertBundlerEmpty();
    }

    function testPoC_BundlerDoesNotRetainLoanTokensAfterSellBundle() public {
        uint256 units = 100;
        Offer memory offer = _basicBuyOffer(lender, market);
        offer.maxUnits = units;

        collateralize(market, borrower, units);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: offer, units: units, ratifierData: hex""});

        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            units, 0, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        _assertBundlerEmpty();
    }
}
