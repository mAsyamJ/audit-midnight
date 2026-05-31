// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer, Market} from "../../../src/interfaces/IMidnight.sol";
import {PermitKind} from "../../../src/periphery/interfaces/IMidnightBundles.sol";
import {TakeAmountsLib} from "../../../src/periphery/TakeAmountsLib.sol";
import {TickLib} from "../../../src/libraries/TickLib.sol";
import {WAD} from "../../../src/libraries/ConstantsLib.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";
import {Take, TokenPermit, CollateralWithdrawal} from "../../../src/periphery/interfaces/IMidnightBundles.sol";

/// @dev AP-015 / POC-INTENT-015 — `TakeAmountsLib` units must match bundle `buyWithUnitsTarget` settlement.
contract PoCBundleExactFillAlignmentTest is Config {
    using UtilsLib for uint256;
    function testPoC_UnitsFromLibMatchesBundleFill() public {
        uint256 units = 25e18;
        Offer memory offer = _basicSellOffer(borrower, market);
        offer.tick = TickLib.priceToTick(WAD / 2, 1);
        offer.maxUnits = units;

        collateralize(market, borrower, units);
        _fundLoanToken(lender, units * 2);

        uint256 targetBuyerAssets = units.mulDivUp(TickLib.tickToPrice(offer.tick) + midnight.settlementFee(marketId, market.maturity - block.timestamp), WAD);
        uint256 libUnits = TakeAmountsLib.buyerAssetsToUnits(address(midnight), marketId, offer, targetBuyerAssets);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: offer, units: libUnits, ratifierData: hex""});

        uint256 lenderBefore = loanToken.balanceOf(lender);
        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            libUnits,
            targetBuyerAssets + 1e18,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.debtOf(marketId, borrower), libUnits, "filled units match lib conversion");
        assertLe(loanToken.balanceOf(lender), lenderBefore - targetBuyerAssets + 1, "spender pays bounded buyer assets");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "no bundler residual");
        _assertMarketAccounting(marketId);
    }

    function testPoC_BundleRejectsInconsistentMarketInBatch() public {
        Market memory other = market;
        other.maturity = block.timestamp + 400 days;
        _touchMarket(other);

        Offer memory offer0 = _basicSellOffer(borrower, market);
        Offer memory offer1 = _basicSellOffer(borrower, other);
        offer0.maxUnits = 1e18;
        offer1.maxUnits = 1e18;
        collateralize(market, borrower, 2e18);
        _fundLoanToken(lender, 10e18);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: offer0, units: 1e18, ratifierData: hex""});
        takes[1] = Take({offer: offer1, units: 1e18, ratifierData: hex""});

        vm.prank(lender);
        vm.expectRevert();
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            2e18,
            type(uint256).max,
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
