// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {AsyamFindingConfig} from "./config.t.sol";
import {IBuyCallback, ISellCallback, IRepayCallback, ILiquidateCallback} from "../../src/interfaces/ICallbacks.sol";
import {IMidnight, Market, Offer} from "../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../src/Midnight.sol";
import {ERC20} from "../erc20s/ERC20.sol";
import {MidnightBundles} from "../../src/periphery/MidnightBundles.sol";
import {Take, CollateralSupply} from "../../src/periphery/interfaces/IMidnightBundles.sol";
import {UtilsLib} from "../../src/libraries/UtilsLib.sol";
import {TickLib} from "../../src/libraries/TickLib.sol";
import {CALLBACK_SUCCESS, WAD, ORACLE_PRICE_SCALE, LLTV_2} from "../../src/libraries/ConstantsLib.sol";

contract ValidationLiveQueuesTest is AsyamFindingConfig {
    using UtilsLib for uint256;

    address internal constant ATTACKER = address(0xA77A);
    address internal constant REFERRER = address(0xFEEE);

    function testValidation_BuyBundleTemporaryBalanceCannotBeStolenBySellerCallback() public {
        Market memory market = _singleCollateralMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 units = 100e18;
        uint256 maxBuyerAssets = 150e18;

        TemporaryBalanceSellCallback callback = new TemporaryBalanceSellCallback(address(midnightBundles), ATTACKER);

        Offer memory offer = _sellOffer(market, borrower, units);
        offer.callback = address(callback);

        collateralize(market, borrower, units);
        deal(address(loanToken), lender, maxBuyerAssets);

        Take[] memory takes = new Take[](1);
        takes[0] = _bundleTake(offer, units);

        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units, maxBuyerAssets, lender, _noPermit(), takes, _emptyWithdrawals(), address(0), 0, address(0)
        );

        assertTrue(callback.attempted(), "seller callback should observe the temporary balance window");
        assertEq(callback.observedBundlerBalance(), maxBuyerAssets - units, "callback observed only the refund float");
        assertEq(callback.extracted(), 0, "callback cannot transferFrom the bundler without allowance");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "attacker gained no loan tokens");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "bundler ends without residual loan tokens");
        assertEq(midnight.creditOf(id, lender), units, "lender received credit");
        assertEq(midnight.debtOf(id, borrower), units, "borrower debt matches the filled sell offer");
        assertTrue(midnight.isHealthy(market, id, borrower), "borrower remains healthy");
    }

    function testValidation_NestedSellBundleCannotSpendOuterAccumulatedProceeds() public {
        Market memory market = _singleCollateralMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 firstOuterUnits = 60e18;
        uint256 secondOuterUnits = 40e18;
        uint256 nestedUnits = 30e18;

        Offer memory nestedOffer = _buyOffer(market, otherLender, nestedUnits);
        nestedOffer.group = keccak256("nested-sell-bundle");

        NestedSellBundleDuringAccumulatedBalanceCallback callback = new NestedSellBundleDuringAccumulatedBalanceCallback(
            midnightBundles, nestedOffer, nestedUnits, otherBorrower, ATTACKER
        );

        vm.prank(otherBorrower);
        midnight.setIsAuthorized(address(callback), true, otherBorrower);
        vm.prank(otherLender);
        loanToken.approve(address(callback), type(uint256).max);

        Offer memory firstOuterOffer = _buyOffer(market, lender, firstOuterUnits);
        firstOuterOffer.group = keccak256("first-outer-sell");
        Offer memory secondOuterOffer = _buyOffer(market, otherLender, secondOuterUnits);
        secondOuterOffer.group = keccak256("second-outer-sell");
        secondOuterOffer.callback = address(callback);

        collateralize(market, borrower, firstOuterUnits + secondOuterUnits);
        collateralize(market, otherBorrower, nestedUnits);
        deal(address(loanToken), lender, firstOuterUnits);
        deal(address(loanToken), otherLender, secondOuterUnits + nestedUnits);

        Take[] memory takes = new Take[](2);
        takes[0] = _bundleTake(firstOuterOffer, firstOuterUnits);
        takes[1] = _bundleTake(secondOuterOffer, secondOuterUnits);

        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            firstOuterUnits + secondOuterUnits, 0, borrower, borrower, _emptySupplies(), takes, 0, address(0)
        );

        assertTrue(callback.nestedSucceeded(), "nested bundle should execute during the outer temporary-balance window");
        assertEq(callback.beforeBundlerBalance(), firstOuterUnits, "callback observes the first outer leg proceeds");
        assertEq(callback.afterBundlerBalance(), firstOuterUnits, "nested bundle preserves the outer proceeds");
        assertEq(loanToken.balanceOf(ATTACKER), nestedUnits, "nested receiver gets only nested proceeds");
        assertEq(
            loanToken.balanceOf(borrower), firstOuterUnits + secondOuterUnits, "outer receiver gets all outer proceeds"
        );
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "bundler ends without residual loan tokens");
        assertEq(
            midnight.debtOf(id, borrower), firstOuterUnits + secondOuterUnits, "outer borrower debt matches outer fills"
        );
        assertEq(midnight.debtOf(id, otherBorrower), nestedUnits, "nested borrower debt matches nested fill");
    }

    function testValidation_NestedTakeDuringBuyCallbackDoesNotBypassSharedCap() public {
        Market memory market = _singleCollateralMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        bytes32 group = keccak256("asyam-nested-take");
        uint256 outerUnits = 60e18;
        uint256 nestedUnits = 40e18;

        NestedTakeBuyCallback callback = new NestedTakeBuyCallback();
        callback.configure(midnight);

        vm.prank(lender);
        midnight.setIsAuthorized(address(callback), true, lender);
        vm.prank(lender);
        loanToken.approve(address(callback), type(uint256).max);
        vm.prank(borrower);
        midnight.setIsAuthorized(address(callback), true, borrower);

        Offer memory outerOffer = _buyOffer(market, lender, outerUnits + nestedUnits);
        outerOffer.group = group;
        outerOffer.callback = address(callback);

        Offer memory nestedOffer = _buyOffer(market, lender, outerUnits + nestedUnits);
        nestedOffer.group = group;
        callback.setNestedTake(nestedOffer, nestedUnits, borrower);

        collateralize(market, borrower, outerUnits + nestedUnits);
        deal(address(loanToken), lender, outerUnits + nestedUnits);

        vm.prank(borrower);
        midnight.take(outerOffer, hex"", outerUnits, borrower, borrower, address(0), hex"");

        assertTrue(callback.reentered(), "callback should have attempted nested take");
        assertEq(midnight.consumed(lender, group), outerUnits + nestedUnits, "shared cap counts both fills");
        assertLe(midnight.consumed(lender, group), outerOffer.maxUnits, "shared cap was not bypassed");
        assertEq(midnight.debtOf(id, borrower), outerUnits + nestedUnits, "borrower debt matches both fills");
        assertTrue(midnight.isHealthy(market, id, borrower), "seller remains healthy after callback reentry");
    }

    function testValidation_ExtremeReferralExactFillLeavesNoBundlerResidual() public {
        Market memory market = _singleCollateralMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 targetBuyerAssets = 100e18;
        uint256 referralFeePct = WAD - 1;
        uint256 expectedFee = targetBuyerAssets.mulDivDown(referralFeePct, WAD);
        uint256 expectedMakerReceipt = targetBuyerAssets - expectedFee;

        Offer memory offer = _sellOffer(market, borrower, expectedMakerReceipt);
        collateralize(market, borrower, expectedMakerReceipt);
        deal(address(loanToken), lender, targetBuyerAssets);

        Take[] memory takes = new Take[](1);
        takes[0] = _bundleTake(offer, expectedMakerReceipt);

        vm.prank(lender);
        midnightBundles.buyWithAssetsTargetAndWithdrawCollateral(
            targetBuyerAssets, 0, lender, _noPermit(), takes, _emptyWithdrawals(), address(0), referralFeePct, REFERRER
        );

        assertEq(loanToken.balanceOf(REFERRER), expectedFee, "referrer receives the exact extreme fee");
        assertEq(loanToken.balanceOf(borrower), expectedMakerReceipt, "maker receives the pre-fee fill");
        assertEq(loanToken.balanceOf(lender), 0, "buyer spent exactly the target assets");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "no bundler residual");
        assertEq(midnight.creditOf(id, lender), expectedMakerReceipt, "buyer credit equals pre-fee fill");
    }

    function testFuzzValidation_BuyUnitsReferralFeeBudgetBoundary(uint96 unitsSeed, uint64 referralFeePctSeed) public {
        Market memory market = _singleCollateralMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 units = bound(uint256(unitsSeed), 1e18, 100e18);
        uint256 referralFeePct = bound(uint256(referralFeePctSeed), 1, WAD - 1);
        uint256 filledBuyerAssets = units.mulDivUp(TickLib.tickToPrice(_sellOffer(market, borrower, units).tick), WAD);
        uint256 referralFeeAssets = filledBuyerAssets.mulDivDown(referralFeePct, WAD - referralFeePct);
        uint256 requiredBudget = filledBuyerAssets + referralFeeAssets;

        Offer memory offer = _sellOffer(market, borrower, units);
        collateralize(market, borrower, units);
        deal(address(loanToken), lender, requiredBudget);

        Take[] memory takes = new Take[](1);
        takes[0] = _bundleTake(offer, units);

        vm.prank(lender);
        vm.expectRevert("Insufficient balance");
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units,
            requiredBudget - 1,
            lender,
            _noPermit(),
            takes,
            _emptyWithdrawals(),
            address(0),
            referralFeePct,
            REFERRER
        );

        assertEq(midnight.debtOf(id, borrower), 0, "insufficient-budget route reverts atomically");
        assertEq(loanToken.balanceOf(lender), requiredBudget, "failed route refunds the full lender balance");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "failed route leaves no bundler residual");

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units, requiredBudget, lender, _noPermit(), takes, _emptyWithdrawals(), address(0), referralFeePct, REFERRER
        );

        assertEq(midnight.debtOf(id, borrower), units, "exact-budget route fills");
        assertEq(loanToken.balanceOf(borrower), filledBuyerAssets, "maker receives filled assets");
        assertEq(loanToken.balanceOf(REFERRER), referralFeeAssets, "referrer receives exact fee");
        assertEq(loanToken.balanceOf(lender), 0, "lender spends exactly the total budget");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "successful route leaves no bundler residual");
    }

    function testValidation_SameLoanAndCollateralTokenRepayFromCollateralIsSolvent() public {
        Market memory market = _sameTokenMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 debt = 77e18;
        uint256 collateral = _collateralForDebt(market, debt, 0);

        collateralize(market, borrower, debt);
        deal(address(loanToken), lender, debt);

        Offer memory offer = _buyOffer(market, lender, debt);
        _take(offer, debt, borrower);

        // Model the borrower having spent the borrowed assets before unwinding through the repay callback.
        deal(address(loanToken), borrower, 0);

        RepayFromCollateralCallback callback = new RepayFromCollateralCallback(midnight, loanToken, collateral);
        vm.prank(borrower);
        midnight.setIsAuthorized(address(callback), true, borrower);

        vm.prank(borrower);
        midnight.repay(market, debt, borrower, address(callback), hex"");

        assertEq(midnight.debtOf(id, borrower), 0, "borrower debt was repaid");
        assertEq(midnight.collateral(id, borrower, 0), 0, "collateral was withdrawn during callback");
        assertEq(midnight.withdrawable(id), debt, "lender withdrawable is fully funded");
        assertEq(loanToken.balanceOf(address(callback)), collateral - debt, "callback keeps only borrower equity");

        vm.prank(lender);
        midnight.withdraw(market, debt, lender, lender);

        assertEq(midnight.withdrawable(id), 0, "lender withdrew all repay proceeds");
        assertEq(loanToken.balanceOf(lender), debt, "lender made whole");
        assertEq(loanToken.balanceOf(address(midnight)), 0, "same-token market remains solvent");
    }

    function testValidation_SameLoanAndCollateralTokenLeverageLoopCanFullyUnwind() public {
        Market memory market = _sameTokenMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 initialCollateral = 100e18;
        uint256 firstDebt = initialCollateral.mulDivDown(LLTV_2, WAD);
        uint256 secondDebt = firstDebt.mulDivDown(LLTV_2, WAD);

        deal(address(loanToken), borrower, initialCollateral);
        vm.prank(borrower);
        midnight.supplyCollateral(market, 0, initialCollateral, borrower);

        deal(address(loanToken), lender, firstDebt);
        _take(_buyOffer(market, lender, firstDebt), firstDebt, borrower);
        vm.prank(borrower);
        midnight.supplyCollateral(market, 0, firstDebt, borrower);

        deal(address(loanToken), otherLender, secondDebt);
        Offer memory secondOffer = _buyOffer(market, otherLender, secondDebt);
        secondOffer.group = keccak256("same-token-second-debt");
        _take(secondOffer, secondDebt, borrower);

        assertTrue(midnight.isHealthy(market, id, borrower), "leveraged same-token borrower remains healthy");

        vm.prank(borrower);
        midnight.repay(market, secondDebt, borrower, address(0), hex"");
        vm.prank(borrower);
        midnight.withdrawCollateral(market, 0, firstDebt, borrower, borrower);
        vm.prank(borrower);
        midnight.repay(market, firstDebt, borrower, address(0), hex"");
        vm.prank(borrower);
        midnight.withdrawCollateral(market, 0, initialCollateral, borrower, borrower);

        vm.prank(lender);
        midnight.withdraw(market, firstDebt, lender, lender);
        vm.prank(otherLender);
        midnight.withdraw(market, secondDebt, otherLender, otherLender);

        assertEq(midnight.debtOf(id, borrower), 0, "borrower fully unwinds debt");
        assertEq(midnight.collateral(id, borrower, 0), 0, "borrower fully withdraws collateral");
        assertEq(midnight.withdrawable(id), 0, "lenders withdraw all repayments");
        assertEq(loanToken.balanceOf(borrower), initialCollateral, "borrower recovers only initial equity");
        assertEq(loanToken.balanceOf(address(midnight)), 0, "same-token leverage loop leaves no custody deficit");
    }

    function testValidation_SameLoanAndCollateralTokenLiquidationCanRepayFromSeizedCollateral() public {
        Market memory market = _sameTokenMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 debt = 77e18;
        uint256 repaidUnits = 10e18;
        uint256 collateral = _collateralForDebt(market, debt, 0);

        collateralize(market, borrower, debt);
        deal(address(loanToken), lender, debt);
        _take(_buyOffer(market, lender, debt), debt, borrower);
        oracle1.setPrice(ORACLE_PRICE_SCALE * 9 / 10);

        LiquidateFromSeizedCollateralCallback callback = new LiquidateFromSeizedCollateralCallback(loanToken);

        vm.prank(liquidator);
        (uint256 seizedAssets, uint256 repaidAssets) =
            midnight.liquidate(market, 0, 0, repaidUnits, borrower, false, address(callback), address(callback), hex"");

        assertEq(repaidAssets, repaidUnits, "liquidation repays the requested units");
        assertGt(seizedAssets, repaidUnits, "callback retains only the liquidation incentive");
        assertEq(loanToken.balanceOf(address(callback)), seizedAssets - repaidUnits, "liquidator keeps incentive");
        assertEq(midnight.debtOf(id, borrower), debt - repaidUnits, "borrower debt decreases");
        assertEq(midnight.collateral(id, borrower, 0), collateral - seizedAssets, "borrower collateral decreases");
        assertEq(midnight.withdrawable(id), repaidUnits, "lender repayment is withdrawable");
        assertEq(
            loanToken.balanceOf(address(midnight)),
            midnight.collateral(id, borrower, 0) + midnight.withdrawable(id),
            "custody backs remaining collateral and lender claim"
        );

        vm.prank(lender);
        midnight.withdraw(market, repaidUnits, lender, lender);
        assertEq(
            loanToken.balanceOf(address(midnight)),
            midnight.collateral(id, borrower, 0),
            "remaining custody matches remaining same-token collateral"
        );
    }

    function testValidation_ReduceOnlyBuyOfferCannotIncreaseMakerCreditByOneWei() public {
        Market memory market = _singleCollateralMarket();
        bytes32 id = _touchWithZeroSettlementFees(market);
        uint256 makerDebt = 50e18;

        collateralize(market, lender, makerDebt);
        deal(address(loanToken), otherLender, makerDebt);

        Offer memory bootstrapOffer = _buyOffer(market, otherLender, makerDebt);
        _take(bootstrapOffer, makerDebt, lender);
        assertEq(midnight.debtOf(id, lender), makerDebt, "test precondition: reduce-only maker has debt");

        Offer memory reduceOnlyOffer = _buyOffer(market, lender, makerDebt);
        reduceOnlyOffer.reduceOnly = true;

        collateralize(market, borrower, makerDebt);
        deal(address(loanToken), lender, makerDebt);

        _take(reduceOnlyOffer, makerDebt, borrower);
        assertEq(midnight.debtOf(id, lender), 0, "reduce-only fill can only reduce maker debt");
        assertEq(midnight.creditOf(id, lender), 0, "reduce-only fill does not create maker credit");

        Offer memory overfillOffer = _buyOffer(market, lender, makerDebt + 1);
        overfillOffer.reduceOnly = true;
        overfillOffer.group = keccak256("fresh-reduce-only-overfill");

        vm.prank(borrower);
        vm.expectRevert(IMidnight.MakerCreditOrDebtIncreased.selector);
        midnight.take(overfillOffer, hex"", makerDebt + 1, borrower, borrower, address(0), hex"");
    }
}

contract TemporaryBalanceSellCallback is ISellCallback {
    address internal immutable BUNDLER;
    address internal immutable BENEFICIARY;

    bool public attempted;
    uint256 public observedBundlerBalance;
    uint256 public extracted;

    constructor(address _bundler, address _beneficiary) {
        BUNDLER = _bundler;
        BENEFICIARY = _beneficiary;
    }

    function onSell(bytes32, Market memory market, uint256, uint256, uint256, address, address, bytes memory)
        external
        returns (bytes32)
    {
        attempted = true;
        ERC20 token = ERC20(market.loanToken);
        observedBundlerBalance = token.balanceOf(BUNDLER);

        if (observedBundlerBalance > 0) {
            try token.transferFrom(BUNDLER, BENEFICIARY, observedBundlerBalance) returns (bool ok) {
                if (ok) extracted = observedBundlerBalance;
            } catch {}
        }

        return CALLBACK_SUCCESS;
    }
}

contract NestedSellBundleDuringAccumulatedBalanceCallback is IBuyCallback {
    MidnightBundles internal immutable BUNDLER;
    Offer internal nestedOffer;
    uint256 internal immutable NESTED_UNITS;
    address internal immutable NESTED_TAKER;
    address internal immutable NESTED_RECEIVER;

    bool public nestedSucceeded;
    uint256 public beforeBundlerBalance;
    uint256 public afterBundlerBalance;

    constructor(
        MidnightBundles _bundler,
        Offer memory _nestedOffer,
        uint256 _nestedUnits,
        address _nestedTaker,
        address _nestedReceiver
    ) {
        BUNDLER = _bundler;
        nestedOffer = _nestedOffer;
        NESTED_UNITS = _nestedUnits;
        NESTED_TAKER = _nestedTaker;
        NESTED_RECEIVER = _nestedReceiver;
    }

    function onBuy(bytes32, Market memory market, uint256 buyerAssets, uint256, uint256, address buyer, bytes memory)
        external
        returns (bytes32)
    {
        ERC20 token = ERC20(market.loanToken);
        beforeBundlerBalance = token.balanceOf(address(BUNDLER));

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: nestedOffer, units: NESTED_UNITS, ratifierData: hex""});
        CollateralSupply[] memory supplies = new CollateralSupply[](0);
        try BUNDLER.supplyCollateralAndSellWithUnitsTarget(
            NESTED_UNITS, 0, NESTED_TAKER, NESTED_RECEIVER, supplies, takes, 0, address(0)
        ) {
            nestedSucceeded = true;
        } catch {}

        afterBundlerBalance = token.balanceOf(address(BUNDLER));
        require(token.transferFrom(buyer, address(this), buyerAssets), "TRANSFER_FROM_FAILED");
        token.approve(msg.sender, buyerAssets);
        return CALLBACK_SUCCESS;
    }
}

contract NestedTakeBuyCallback is IBuyCallback {
    Midnight internal midnight;
    Offer internal nestedOffer;
    uint256 internal nestedUnits;
    address internal nestedTaker;

    bool public reentered;

    function configure(Midnight _midnight) external {
        midnight = _midnight;
    }

    function setNestedTake(Offer memory offer, uint256 units, address taker) external {
        nestedOffer = offer;
        nestedUnits = units;
        nestedTaker = taker;
    }

    function onBuy(bytes32, Market memory market, uint256 buyerAssets, uint256, uint256, address buyer, bytes memory)
        external
        returns (bytes32)
    {
        if (!reentered) {
            reentered = true;
            try midnight.take(nestedOffer, hex"", nestedUnits, nestedTaker, nestedTaker, address(0), hex"") {} catch {}
        }

        ERC20 token = ERC20(market.loanToken);
        require(token.transferFrom(buyer, address(this), buyerAssets), "TRANSFER_FROM_FAILED");
        token.approve(msg.sender, buyerAssets);
        return CALLBACK_SUCCESS;
    }
}

contract RepayFromCollateralCallback is IRepayCallback {
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

contract LiquidateFromSeizedCollateralCallback is ILiquidateCallback {
    ERC20 internal immutable TOKEN;

    constructor(ERC20 _token) {
        TOKEN = _token;
    }

    function onLiquidate(
        address,
        bytes32,
        Market memory,
        uint256,
        uint256,
        uint256 repaidUnits,
        address,
        address,
        bytes memory,
        uint256
    ) external returns (bytes32) {
        TOKEN.approve(msg.sender, repaidUnits);
        return CALLBACK_SUCCESS;
    }
}
