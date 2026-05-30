// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {IRepayCallback} from "../../../src/interfaces/ICallbacks.sol";
import {IMidnight, Market, Offer, CollateralParams} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {
    Take,
    TokenPermit,
    PermitKind,
    CollateralWithdrawal
} from "../../../src/periphery/interfaces/IMidnightBundles.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";
import {TickLib} from "../../../src/libraries/TickLib.sol";
import {CALLBACK_SUCCESS, WAD, LLTV_2, LIQUIDATION_CURSOR_LOW} from "../../../src/libraries/ConstantsLib.sol";

/// @dev Exploratory probes promoted into narrower regressions under test/asyamFindings.
contract PoCDeepValidationQueuesTest is Config {
    using UtilsLib for uint256;

    function testPoC_ReduceOnlyBuyCannotCrossDebtIntoOneWeiCredit() public {
        uint256 makerDebt = 50e18;

        collateralize(market, lender, makerDebt);
        _fundLoanToken(otherLender, makerDebt);

        Offer memory bootstrapOffer = _basicBuyOffer(otherLender, market);
        bootstrapOffer.maxUnits = makerDebt;
        take(makerDebt, lender, bootstrapOffer);

        Offer memory reduceOnlyOffer = _basicBuyOffer(lender, market);
        reduceOnlyOffer.reduceOnly = true;
        reduceOnlyOffer.maxUnits = makerDebt + 1;

        collateralize(market, borrower, makerDebt + 1);

        vm.prank(borrower);
        vm.expectRevert(IMidnight.MakerCreditOrDebtIncreased.selector);
        midnight.take(reduceOnlyOffer, hex"", makerDebt + 1, borrower, borrower, address(0), hex"");

        assertEq(midnight.debtOf(marketId, lender), makerDebt, "failed overfill leaves maker debt unchanged");
        assertEq(midnight.creditOf(marketId, lender), 0, "failed overfill creates no maker credit");
    }

    function testPoC_BuyUnitsReferralBudgetBoundaryRevertsAtomically() public {
        uint256 units = 10e18;
        uint256 referralFeePct = WAD / 10;

        Offer memory offer = _basicSellOffer(borrower, market);
        offer.maxUnits = units;

        uint256 filledBuyerAssets = units.mulDivUp(TickLib.tickToPrice(offer.tick), WAD);
        uint256 referralFeeAssets = filledBuyerAssets.mulDivDown(referralFeePct, WAD - referralFeePct);
        uint256 requiredBudget = filledBuyerAssets + referralFeeAssets;

        collateralize(market, borrower, units);
        _fundLoanToken(lender, requiredBudget);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: offer, units: units, ratifierData: hex""});

        vm.prank(lender);
        vm.expectRevert("Insufficient balance");
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units,
            requiredBudget - 1,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            referralFeePct,
            REFERRAL
        );

        assertEq(midnight.debtOf(marketId, borrower), 0, "failed budget route reverts the fill");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "failed budget route leaves no router residual");

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units,
            requiredBudget,
            lender,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            referralFeePct,
            REFERRAL
        );

        assertEq(midnight.debtOf(marketId, borrower), units, "exact budget fills");
        assertEq(loanToken.balanceOf(REFERRAL), referralFeeAssets, "referral receives exact fee");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "exact budget leaves no router residual");
    }

    function testPoC_SameTokenRepayCallbackKeepsLenderClaimFunded() public {
        Market memory sameTokenMarket = _sameTokenMarket();
        bytes32 sameTokenMarketId = _touchMarket(sameTokenMarket);
        uint256 debt = 77e18;
        uint256 collateral = debt.mulDivUp(WAD, LLTV_2);

        collateralize(sameTokenMarket, borrower, debt);
        _fundLoanToken(lender, debt);

        Offer memory offer = _basicBuyOffer(lender, sameTokenMarket);
        offer.maxUnits = debt;
        take(debt, borrower, offer);

        deal(address(loanToken), borrower, 0);

        AuditRepayFromCollateralCallback callback =
            new AuditRepayFromCollateralCallback(midnight, loanToken, collateral);
        vm.prank(borrower);
        midnight.setIsAuthorized(address(callback), true, borrower);

        vm.prank(borrower);
        midnight.repay(sameTokenMarket, debt, borrower, address(callback), hex"");

        assertEq(midnight.debtOf(sameTokenMarketId, borrower), 0, "borrower debt repaid");
        assertEq(midnight.collateral(sameTokenMarketId, borrower, 0), 0, "callback withdrew same-token collateral");
        assertEq(midnight.withdrawable(sameTokenMarketId), debt, "lender claim remains funded");
        assertEq(loanToken.balanceOf(address(midnight)), debt, "custody equals lender claim after callback unwind");
    }

    function _sameTokenMarket() internal view returns (Market memory sameTokenMarket) {
        CollateralParams[] memory collateralParams = new CollateralParams[](1);
        collateralParams[0] = CollateralParams({
            token: address(loanToken),
            lltv: LLTV_2,
            maxLif: maxLif(LLTV_2, LIQUIDATION_CURSOR_LOW),
            oracle: address(oracle1)
        });
        sameTokenMarket = Market({
            loanToken: address(loanToken),
            collateralParams: collateralParams,
            maturity: block.timestamp + 30 days,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }
}

contract AuditRepayFromCollateralCallback is IRepayCallback {
    Midnight internal immutable MIDNIGHT;
    ERC20 internal immutable TOKEN;
    uint256 internal immutable COLLATERAL_TO_WITHDRAW;

    constructor(Midnight _midnight, ERC20 _token, uint256 _collateralToWithdraw) {
        MIDNIGHT = _midnight;
        TOKEN = _token;
        COLLATERAL_TO_WITHDRAW = _collateralToWithdraw;
    }

    function onRepay(bytes32, Market memory market, uint256 units, address onBehalf, bytes memory)
        external
        returns (bytes32)
    {
        MIDNIGHT.withdrawCollateral(market, 0, COLLATERAL_TO_WITHDRAW, onBehalf, address(this));
        TOKEN.approve(msg.sender, units);
        return CALLBACK_SUCCESS;
    }
}
