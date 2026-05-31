// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {IMidnight, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {SetterRatifier} from "../../../../src/ratifiers/SetterRatifier.sol";
import {HashLib} from "../../../../src/ratifiers/libraries/HashLib.sol";
import {RatifierRootBuyCallback} from "../../mocks/RatifierRootBuyCallback.sol";

/// @dev COMP-008 / COMP-015 / COMP-027 — callback root changes must observe outer transient consumption.
contract PoCCompCallbackRatifierRootTest is Config {
    bytes32 internal constant GROUP = keccak256("callback-ratifier-shared-group");

    function testComp_CallbackRatifiesNestedRootButSharedConsumedCapStillBinds() public {
        uint256 outerUnits = 60e18;
        uint256 nestedUnits = 40e18;
        uint256 cap = outerUnits + nestedUnits;

        SetterRatifier setterRatifier = new SetterRatifier(address(midnight));
        RatifierRootBuyCallback callback = new RatifierRootBuyCallback(midnight, setterRatifier);

        vm.startPrank(borrower);
        midnight.setIsAuthorized(address(setterRatifier), true, borrower);
        midnight.setIsAuthorized(address(callback), true, borrower);
        vm.stopPrank();

        collateralize(market, borrower, cap);
        Offer memory outerOffer = _setterSellOffer(setterRatifier, "outer", cap);
        Offer memory nestedOffer = _setterSellOffer(setterRatifier, "nested", cap);
        bytes32 outerRoot = HashLib.hashOffer(outerOffer);
        bytes32 nestedRoot = HashLib.hashOffer(nestedOffer);
        bytes memory outerData = _setterData(outerRoot);
        bytes memory nestedData = _setterData(nestedRoot);

        vm.prank(borrower);
        setterRatifier.setIsRootRatified(borrower, outerRoot, true);
        assertFalse(setterRatifier.isRootRatified(borrower, nestedRoot), "nested root starts disabled");

        deal(address(loanToken), address(callback), cap);
        callback.configure(nestedOffer, nestedData, nestedRoot, nestedUnits);
        callback.execute(outerOffer, outerData, outerUnits);

        assertTrue(callback.entered(), "outer buy callback ratified and filled nested offer");
        assertTrue(setterRatifier.isRootRatified(borrower, nestedRoot), "nested root change persists");
        assertEq(midnight.consumed(borrower, GROUP), cap, "outer and nested offers share one cap");
        assertEq(midnight.debtOf(marketId, borrower), cap, "borrower debt increases only by capped amount");
        assertEq(midnight.creditOf(marketId, address(callback)), cap, "callback receives corresponding lender credit");
        assertEq(loanToken.balanceOf(address(callback)), 0, "callback retains no payment float");

        vm.prank(lender);
        vm.expectRevert(IMidnight.ConsumedUnits.selector);
        midnight.take(nestedOffer, nestedData, 1, lender, borrower, address(0), hex"");

        _assertPositionHealthy(marketId, market, borrower);
        _assertMarketAccounting(marketId);
    }

    function _setterSellOffer(SetterRatifier setterRatifier, bytes memory marker, uint256 cap)
        internal
        view
        returns (Offer memory offer)
    {
        offer = _basicSellOffer(borrower, market);
        offer.ratifier = address(setterRatifier);
        offer.group = GROUP;
        offer.maxUnits = cap;
        offer.callbackData = marker;
    }

    function _setterData(bytes32 root) internal pure returns (bytes memory) {
        return abi.encode(root, uint256(0), new bytes32[](0));
    }
}
