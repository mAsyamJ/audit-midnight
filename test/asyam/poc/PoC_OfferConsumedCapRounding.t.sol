// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {TickLib, MAX_TICK} from "../../../src/libraries/TickLib.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";
import {WAD} from "../../../src/libraries/ConstantsLib.sol";

/// @dev MIDNIGHT-CAND-005 — grouped offers shared cap (Blackthorn L-5 dedup check).
contract PoCOfferConsumedCapRoundingTest is Config {
    using UtilsLib for uint256;

    function testPoC_GroupedMaxAssetsCapNotExceededAcrossTwoOffers() public {
        bytes32 sharedGroup = keccak256("asset-cap");
        uint256 tick = MAX_TICK;
        uint256 price = TickLib.tickToPrice(tick);
        uint256 maxAssets = 1000e18;

        Offer memory offerA = _basicBuyOffer(lender, market);
        offerA.group = sharedGroup;
        offerA.maxAssets = maxAssets;
        offerA.maxUnits = 0;
        offerA.tick = tick;

        Offer memory offerB = _basicBuyOffer(lender, market);
        offerB.group = sharedGroup;
        offerB.maxAssets = maxAssets;
        offerB.maxUnits = 0;
        offerB.tick = tick;

        uint256 unitsA = maxAssets.mulDivDown(WAD, price);
        uint256 unitsB = unitsA / 2;
        vm.assume(unitsA > 10 && unitsB > 0);

        collateralize(market, borrower, unitsA + unitsB);

        vm.startPrank(borrower);
        midnight.take(offerA, hex"", unitsA, borrower, borrower, address(0), hex"");

        uint256 consumedAfterA = midnight.consumed(lender, sharedGroup);
        assertLe(consumedAfterA, maxAssets, "consumed after first fill");

        uint256 remainingAssets = maxAssets - consumedAfterA;
        if (remainingAssets > 0) {
            uint256 maxUnitsB = remainingAssets.mulDivDown(WAD, price);
            if (maxUnitsB > 0) {
                midnight.take(offerB, hex"", maxUnitsB, borrower, borrower, address(0), hex"");
            }
        }
        vm.stopPrank();

        assertLe(midnight.consumed(lender, sharedGroup), maxAssets, "shared maxAssets cap never exceeded");
    }

    function testPoC_GroupedMaxUnitsCapNotExceeded() public {
        bytes32 sharedGroup = keccak256("units-cap");
        uint256 maxUnits = 500;

        Offer memory offerA = _basicBuyOffer(lender, market);
        offerA.group = sharedGroup;
        offerA.maxUnits = maxUnits;

        Offer memory offerB = _basicBuyOffer(lender, market);
        offerB.group = sharedGroup;
        offerB.maxUnits = maxUnits;

        collateralize(market, borrower, maxUnits);

        vm.startPrank(borrower);
        midnight.take(offerA, hex"", 300, borrower, borrower, address(0), hex"");
        vm.expectRevert();
        midnight.take(offerB, hex"", 250, borrower, borrower, address(0), hex"");
        vm.stopPrank();

        assertEq(midnight.consumed(lender, sharedGroup), 300, "consumed units tracked");
        _assertConsumedCap(lender, sharedGroup, maxUnits);
    }
}
