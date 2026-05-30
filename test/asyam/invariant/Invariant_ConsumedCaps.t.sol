// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";

contract InvariantConsumedCapsTest is Config {
    function testInvariant_ConsumedMonotonicAndWithinCap() public {
        bytes32 group = keccak256("invariant-cap");
        uint256 maxUnits = 1000;

        Offer memory offer = _basicBuyOffer(lender, market);
        offer.group = group;
        offer.maxUnits = maxUnits;

        collateralize(market, borrower, maxUnits);

        vm.startPrank(borrower);
        midnight.take(offer, hex"", 100, borrower, borrower, address(0), hex"");
        midnight.take(offer, hex"", 200, borrower, borrower, address(0), hex"");
        vm.expectRevert();
        midnight.take(offer, hex"", 800, borrower, borrower, address(0), hex"");
        vm.stopPrank();

        _assertConsumedCap(lender, group, maxUnits);
    }
}
