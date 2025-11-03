// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {WAD} from "../src/libraries/ConstantsLib.sol";
import {MathLib} from "../src/libraries/MathLib.sol";
import {Obligation, Offer, Collateral} from "../src/interfaces/IMorphoV2.sol";

import {BaseTest, MAX_TEST_AMOUNT} from "./BaseTest.sol";

contract TradingFeeTest is BaseTest {
    using MathLib for uint256;

    Obligation internal obligation;
    bytes32 internal id;
    Offer internal lenderOffer;
    Offer internal borrowerOffer;
    address internal feeRecipient = makeAddr("feeRecipient");

    function setUp() public override {
        super.setUp();

        obligation.chainId = block.chainid;
        obligation.loanToken = address(loanToken);
        obligation.maturity = block.timestamp + 100;
        obligation.collaterals
            .push(Collateral({token: address(collateralToken1), lltv: 0.75e18, oracle: address(oracle1)}));
        obligation.collaterals
            .push(Collateral({token: address(collateralToken2), lltv: 0.75e18, oracle: address(oracle2)}));
        obligation.collaterals = sortCollaterals(obligation.collaterals);

        id = keccak256(abi.encode(obligation));

        lenderOffer.obligation = obligation;
        lenderOffer.buy = true;
        lenderOffer.maker = lender;
        lenderOffer.assets = type(uint256).max;
        lenderOffer.start = block.timestamp;
        lenderOffer.expiry = block.timestamp + 200;
        lenderOffer.startPrice = 1 ether;
        lenderOffer.expiryPrice = 1 ether;

        borrowerOffer.obligation = obligation;
        borrowerOffer.buy = false;
        borrowerOffer.maker = borrower;
        borrowerOffer.assets = type(uint256).max;
        borrowerOffer.expiry = block.timestamp + 200;
        borrowerOffer.startPrice = 1 ether;
        borrowerOffer.expiryPrice = 1 ether;

        deal(address(loanToken), address(lender), MAX_TEST_AMOUNT * 2);

        morphoV2.setTradingFeeRecipient(feeRecipient);
    }

    // Normal trading fee. Proportional to amount traded.

    function testBuyerAssetsLendProportional(uint256 tradingFee, uint256 sellerPrice, uint256 buyerAssets) public {
        buyerAssets = bound(buyerAssets, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        tradingFee = bound(tradingFee, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, tradingFee, WAD);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedSellerAssets = buyerAssets.mulDivDown(WAD, WAD + tradingFee);
        uint256 expectedFee = expectedSellerAssets.mulDivDown(tradingFee, WAD);
        uint256 expectedUnits = expectedSellerAssets.mulDivUp(WAD, sellerPrice);

        collateralize(obligation, borrower, (expectedUnits + 1) * 10); // todo: why
        take(buyerAssets, 0, 0, 0, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, buyerAssets / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testBuyerAssetsBorrowProportional(uint256 tradingFee, uint256 price, uint256 buyerAssets) public {
    //     buyerAssets = bound(buyerAssets, 0, MAX_TEST_AMOUNT);
    //     price = bound(price, 0.5e18, WAD);
    //     tradingFee = bound(tradingFee, 0, (WAD - price) / 2);
    //     morphoV2.setTradingFee(id, tradingFee, WAD);
    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedSellerAssets = buyerAssets.mulDivDown(WAD, WAD + tradingFee);
    //     uint256 expectedFee = expectedSellerAssets.mulDivDown(tradingFee, WAD);
    //     uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);

    //     collateralize(obligation, borrower, expectedUnits);
    //     take(buyerAssets, 0, 0, 0, borrower, lenderOffer);

    //     assertApproxEqAbs(
    //         loanToken.balanceOf(feeRecipient), expectedFee, buyerAssets / 1e6 + 100, "fee recipient balance"
    //     );
    // }

    function testSellerAssetsLendProportional(uint256 tradingFee, uint256 sellerPrice, uint256 sellerAssets) public {
        sellerAssets = bound(sellerAssets, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        tradingFee = bound(tradingFee, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, tradingFee, WAD);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedFee = sellerAssets.mulDivDown(tradingFee, WAD);

        collateralize(obligation, borrower, sellerAssets.mulDivDown(WAD, sellerPrice));
        take(0, sellerAssets, 0, 0, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, sellerAssets / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testSellerAssetsBorrowProportional(uint256 tradingFee, uint256 price, uint256 sellerAssets) public {
    //     sellerAssets = bound(sellerAssets, 0, MAX_TEST_AMOUNT);
    //     price = bound(price, 0.5e18, WAD);
    //     tradingFee = bound(tradingFee, 0, (WAD - price) / 2);
    //     morphoV2.setTradingFee(id, tradingFee, WAD);
    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedFee = sellerAssets.mulDivDown(tradingFee, WAD);

    //     collateralize(obligation, borrower, sellerAssets.mulDivDown(WAD, price));
    //     take(0, sellerAssets, 0, 0, borrower, lenderOffer);

    //     assertApproxEqAbs(
    //         loanToken.balanceOf(feeRecipient), expectedFee, sellerAssets / 1e6 + 100, "fee recipient balance"
    //     );
    // }

    function testObligationUnitsLendProportional(uint256 tradingFee, uint256 sellerPrice, uint256 obligationUnits)
        public
    {
        obligationUnits = bound(obligationUnits, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        tradingFee = bound(tradingFee, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, tradingFee, WAD);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedSellerAssets = obligationUnits.mulDivDown(sellerPrice, WAD);
        uint256 expectedFee = expectedSellerAssets.mulDivDown(tradingFee, WAD);

        collateralize(obligation, borrower, obligationUnits);
        take(0, 0, obligationUnits, 0, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, obligationUnits / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testObligationUnitsBorrowProportional(uint256 tradingFee, uint256 price, uint256 obligationUnits) public
    // { obligationUnits = bound(obligationUnits, 0, MAX_TEST_AMOUNT);
    //     price = bound(price, 0.5e18, WAD);
    //     tradingFee = bound(tradingFee, 0, (WAD - price) / 2);
    //     morphoV2.setTradingFee(id, tradingFee, WAD);
    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedBuyerAssets = obligationUnits.mulDivDown(WAD, price);
    //     uint256 expectedSellerAssets = expectedBuyerAssets.mulDivDown(WAD, WAD + tradingFee);
    //     uint256 expectedFee = expectedSellerAssets.mulDivDown(tradingFee, WAD);

    //     collateralize(obligation, borrower, obligationUnits);
    //     take(0, 0, obligationUnits, 0, borrower, lenderOffer);

    //     assertApproxEqAbs(
    //         loanToken.balanceOf(feeRecipient), expectedFee, obligationUnits / 1e6 + 100, "fee recipient balance"
    //     );
    // }

    function testObligationSharesLendProportional(uint256 tradingFee, uint256 sellerPrice, uint256 obligationShares)
        public
    {
        obligationShares = bound(obligationShares, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        tradingFee = bound(tradingFee, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, tradingFee, WAD);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedSellerAssets = obligationShares.mulDivDown(sellerPrice, WAD);
        uint256 expectedFee = expectedSellerAssets.mulDivDown(tradingFee, WAD);

        collateralize(obligation, borrower, obligationShares);
        take(0, 0, 0, obligationShares, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, obligationShares / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testObligationSharesBorrowProportional(uint256 tradingFee, uint256 price, uint256 obligationShares)
    //     public
    // {
    //     obligationShares = bound(obligationShares, 0, MAX_TEST_AMOUNT);
    //     price = bound(price, 0.5e18, WAD);
    //     tradingFee = bound(tradingFee, 0, (WAD - price) / 2);
    //     morphoV2.setTradingFee(id, tradingFee, WAD);
    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedBuyerAssets = obligationShares.mulDivDown(WAD, price);
    //     uint256 expectedSellerAssets = expectedBuyerAssets.mulDivDown(WAD, WAD + tradingFee);
    //     uint256 expectedFee = expectedSellerAssets.mulDivDown(tradingFee, WAD);

    //     collateralize(obligation, borrower, obligationShares);
    //     take(0, 0, 0, obligationShares, borrower, lenderOffer);

    //     assertApproxEqAbs(
    //         loanToken.balanceOf(feeRecipient), expectedFee, obligationShares / 1e6 + 100, "fee recipient balance"
    //     );
    // }

    // Interst cut limit. Proportional to interest.

    function testBuyerAssetsLendInterestCutLimit(uint256 interestCutLimit, uint256 sellerPrice, uint256 buyerAssets)
        public
    {
        buyerAssets = bound(buyerAssets, 0, MAX_TEST_AMOUNT);
        interestCutLimit = bound(interestCutLimit, 0, WAD);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        morphoV2.setTradingFee(id, WAD, interestCutLimit);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedSellerAssets =
            buyerAssets.mulDivDown(WAD, WAD + interestCutLimit.mulDivDown(WAD - sellerPrice, sellerPrice));
        uint256 expectedUnits = expectedSellerAssets.mulDivUp(WAD, sellerPrice);
        uint256 expectedFee = (expectedUnits - expectedSellerAssets).mulDivDown(interestCutLimit, WAD);

        collateralize(obligation, borrower, (expectedUnits + 1) * 10); // todo: why
        take(buyerAssets, 0, 0, 0, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, buyerAssets / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testBuyerAssetsBorrowInterestCutLimit(uint256 interestCutLimit, uint256 price, uint256 buyerAssets)
    // public { morphoV2.setTradingFee(id, WAD, 0.05e18);
    //     uint256 buyerAssets = 100 ether;
    //     uint256 price = 0.9 ether;
    //     uint256 fee = 0.05e18;

    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
    //     uint256 expectedSellerAssets = (buyerAssets - fee.mulDivDown(expectedUnits, WAD)).mulDivDown(WAD, WAD -
    // fee); uint256 expectedFee = buyerAssets - expectedSellerAssets;

    //     collateralize(obligation, borrower, expectedUnits);
    //     take(buyerAssets, 0, 0, 0, borrower, lenderOffer);

    //     assertApproxEqAbs(loanToken.balanceOf(feeRecipient), expectedFee, 100, "fee recipient balance");
    // }

    function testSellerAssetsLendInterestCutLimit(uint256 interestCutLimit, uint256 sellerPrice, uint256 sellerAssets)
        public
    {
        sellerAssets = bound(sellerAssets, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        interestCutLimit = bound(interestCutLimit, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, WAD, interestCutLimit);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedUnits = sellerAssets.mulDivDown(WAD, sellerPrice);
        uint256 expectedFee = (expectedUnits - sellerAssets).mulDivDown(interestCutLimit, WAD);

        collateralize(obligation, borrower, expectedUnits);
        take(0, sellerAssets, 0, 0, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, sellerAssets / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testSellerAssetsBorrow() public {
    //     morphoV2.setTradingFee(id, WAD, 0.05e18);
    //     uint256 sellerAssets = 90 ether;
    //     uint256 price = 0.9 ether;
    //     uint256 fee = 0.05e18;

    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedBuyerAssets =
    //         (sellerAssets.mulDivDown(WAD - fee, WAD)).mulDivDown(WAD, WAD - fee.mulDivDown(WAD, price));
    //     uint256 expectedFee = expectedBuyerAssets - sellerAssets;

    //     collateralize(obligation, borrower, expectedUnits);
    //     take(0, sellerAssets, 0, 0, borrower, lenderOffer);

    //     assertApproxEqAbs(loanToken.balanceOf(feeRecipient), expectedFee, 200, "fee recipient balance");
    // }

    function testObligationUnitsLendInterestCutLimit(
        uint256 interestCutLimit,
        uint256 sellerPrice,
        uint256 obligationUnits
    ) public {
        obligationUnits = bound(obligationUnits, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        interestCutLimit = bound(interestCutLimit, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, WAD, interestCutLimit);

        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedSellerAssets = obligationUnits.mulDivDown(sellerPrice, WAD);
        uint256 expectedFee = (obligationUnits - expectedSellerAssets).mulDivDown(interestCutLimit, WAD);

        collateralize(obligation, borrower, obligationUnits);
        take(0, 0, obligationUnits, 0, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, obligationUnits / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testObligationUnitsBorrow() public {
    //     morphoV2.setTradingFee(id, WAD, 0.05e18);
    //     uint256 obligationUnits = 100 ether;
    //     uint256 price = 0.9 ether;
    //     uint256 fee = 0.05e18;

    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedBuyerAssets = obligationUnits * price / WAD;
    //     uint256 expectedSellerAssets =
    //         (expectedBuyerAssets - fee.mulDivDown(obligationUnits, WAD)).mulDivDown(WAD, WAD - fee);
    //     uint256 expectedFee = expectedBuyerAssets - expectedSellerAssets;

    //     collateralize(obligation, borrower, expectedUnits);
    //     take(0, 0, obligationUnits, 0, borrower, lenderOffer);

    //     assertApproxEqAbs(loanToken.balanceOf(feeRecipient), expectedFee, 100, "fee recipient balance");
    // }

    function testObligationSharesLendInterestCutLimit(
        uint256 interestCutLimit,
        uint256 sellerPrice,
        uint256 obligationShares
    ) public {
        obligationShares = bound(obligationShares, 0, MAX_TEST_AMOUNT);
        sellerPrice = bound(sellerPrice, 0.5e18, WAD);
        interestCutLimit = bound(interestCutLimit, 0, (WAD - sellerPrice) / 2);
        morphoV2.setTradingFee(id, WAD, interestCutLimit);
        borrowerOffer.startPrice = sellerPrice;
        borrowerOffer.expiryPrice = sellerPrice;

        uint256 expectedSellerAssets = obligationShares.mulDivDown(sellerPrice, WAD);
        uint256 expectedFee = (obligationShares - expectedSellerAssets).mulDivDown(interestCutLimit, WAD);

        collateralize(obligation, borrower, obligationShares);
        take(0, 0, 0, obligationShares, lender, borrowerOffer);

        assertApproxEqAbs(
            loanToken.balanceOf(feeRecipient), expectedFee, obligationShares / 1e6 + 100, "fee recipient balance"
        );
    }

    // function testObligationSharesBorrowInterestCutLimit(
    //     uint256 interestCutLimit,
    //     uint256 price,
    //     uint256 obligationShares
    // ) public {
    //     obligationShares = bound(obligationShares, 0, MAX_TEST_AMOUNT);
    //     price = bound(price, 0.5e18, WAD);
    //     interestCutLimit = bound(interestCutLimit, 0, (WAD - price) / 2);
    //     morphoV2.setTradingFee(id, WAD, interestCutLimit);
    //     lenderOffer.startPrice = price;
    //     lenderOffer.expiryPrice = price;

    //     uint256 expectedSellerAssets = obligationShares.mulDivDown(price, WAD);
    //     uint256 expectedFee = (obligationShares - expectedSellerAssets).mulDivDown(interestCutLimit, WAD);

    //     collateralize(obligation, borrower, obligationShares);
    //     take(0, 0, 0, obligationShares, borrower, lenderOffer);

    //     assertApproxEqAbs(
    //         loanToken.balanceOf(feeRecipient), expectedFee, obligationShares / 1e6 + 100, "fee recipient balance"
    //     );
    // }
}
