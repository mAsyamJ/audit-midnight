// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {Obligation, Offer, Signature, Collateral, Seizure} from "../src/interfaces/IMorphoV2.sol";
import {MorphoV2} from "../src/MorphoV2.sol";
import {ORACLE_PRICE_SCALE, WAD} from "../src/libraries/ConstantsLib.sol";
import {MathLib} from "../src/libraries/MathLib.sol";
import {ICallbacks} from "../src/interfaces/ICallbacks.sol";

import {BaseTest} from "./BaseTest.sol";
import {ERC20} from "./helpers/ERC20.sol";
import {Oracle} from "./helpers/Oracle.sol";

contract TakeTest is BaseTest {
    using MathLib for uint256;

    Obligation internal obligation;
    bytes32 internal id;
    Offer internal lenderOffer;
    Offer internal borrowerOffer;
    Offer internal otherLenderOffer;
    Offer internal otherBorrowerOffer;

    uint256 internal maxAssets = 1e36; // to refine.

    function setUp() public override {
        super.setUp();

        obligation.chainId = block.chainid;
        obligation.loanToken = address(loanToken);
        obligation.maturity = block.timestamp + 100;
        obligation.collaterals
            .push(Collateral({token: address(collateralToken1), lltv: 0.75e18, oracle: address(oracle)}));
        obligation.collaterals
            .push(Collateral({token: address(collateralToken2), lltv: 0.75e18, oracle: address(oracle)}));
        obligation.collaterals = sortCollaterals(obligation.collaterals);

        id = keccak256(abi.encode(obligation));

        lenderOffer.buy = true;
        lenderOffer.maker = lender;
        lenderOffer.assets = 100;
        lenderOffer.obligation = obligation;
        lenderOffer.expiry = block.timestamp + 200;
        lenderOffer.startPrice = 0.99 ether;
        lenderOffer.expiryPrice = 0.99 ether;

        otherLenderOffer.buy = false;
        otherLenderOffer.maker = otherLender;
        otherLenderOffer.obligation = obligation;
        otherLenderOffer.expiry = block.timestamp + 200;

        borrowerOffer.buy = false;
        borrowerOffer.maker = borrower;
        borrowerOffer.assets = 100;
        borrowerOffer.obligation = obligation;
        borrowerOffer.expiry = block.timestamp + 200;
        borrowerOffer.startPrice = 0.99 ether;
        borrowerOffer.expiryPrice = 0.99 ether;

        otherBorrowerOffer.buy = true;
        otherBorrowerOffer.maker = otherBorrower;
        otherBorrowerOffer.obligation = obligation;
        otherBorrowerOffer.expiry = block.timestamp + 200;

        deal(address(loanToken), address(this), 100);
        deal(address(loanToken), address(lender), 100);
        deal(address(obligation.collaterals[0].token), address(this), type(uint256).max);

        morphoV2.supplyCollateral(obligation, obligation.collaterals[0].token, 135, borrower);
    }

    // tests.

    // path 1: Lender enters + borrower enters.

    function testBuyAssetsInput1(uint256 buyerAssets, uint256 price) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        borrowerOffer.startPrice = price;
        borrowerOffer.expiryPrice = price;
        borrowerOffer.assets = buyerAssets;
        deal(address(loanToken), lender, buyerAssets);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        collateralize(obligation, borrower, expectedUnits);

        take(buyerAssets, 0, 0, 0, lender, borrowerOffer);

        assertEq(morphoV2.sharesOf(lender, id), expectedUnits, "lender obligation shares");
        assertEq(morphoV2.debtOf(borrower, id), expectedUnits, "borrower debt");
        assertEq(morphoV2.totalUnits(id), expectedUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), expectedUnits, "total shares");
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(morphoV2.consumed(borrower, 0), buyerAssets, "borrower consumed");
    }

    function testSellAssetsInput1(uint256 buyerAssets, uint256 price) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        lenderOffer.startPrice = price;
        lenderOffer.expiryPrice = price;
        lenderOffer.assets = buyerAssets;
        deal(address(loanToken), lender, buyerAssets);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        collateralize(obligation, borrower, expectedUnits);

        take(buyerAssets, 0, 0, 0, borrower, lenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), expectedUnits, "lender obligation shares");
        assertEq(morphoV2.debtOf(borrower, id), expectedUnits, "borrower debt");
        assertEq(morphoV2.totalUnits(id), expectedUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), expectedUnits, "total shares");
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(morphoV2.consumed(lender, 0), buyerAssets, "lender consumed");
    }

    function testBuyObligationUnitsInput1(uint256 obligationUnits, uint256 price) public {
        obligationUnits = bound(obligationUnits, 1, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        borrowerOffer.startPrice = price;
        borrowerOffer.expiryPrice = price;
        uint256 expectedAssets = obligationUnits.mulDivDown(price, WAD);
        deal(address(loanToken), lender, expectedAssets);
        collateralize(obligation, borrower, obligationUnits);
        borrowerOffer.assets = expectedAssets;

        take(0, 0, obligationUnits, 0, lender, borrowerOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationUnits, "lender obligation shares");
        assertEq(morphoV2.debtOf(borrower, id), obligationUnits, "borrower debt");
        assertEq(morphoV2.totalUnits(id), obligationUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), obligationUnits, "total shares");
        assertEq(loanToken.balanceOf(borrower), expectedAssets, "borrower balance");
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(morphoV2.consumed(borrower, 0), expectedAssets, "borrower consumed");
    }

    function testSellObligationUnitsInput1(uint256 obligationUnits, uint256 price) public {
        obligationUnits = bound(obligationUnits, 1, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        lenderOffer.startPrice = price;
        lenderOffer.expiryPrice = price;
        uint256 expectedAssets = obligationUnits.mulDivDown(price, WAD);
        deal(address(loanToken), lender, expectedAssets);
        collateralize(obligation, borrower, obligationUnits);
        lenderOffer.assets = expectedAssets;

        take(0, 0, obligationUnits, 0, borrower, lenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationUnits, "lender obligation shares");
        assertEq(morphoV2.debtOf(borrower, id), obligationUnits, "borrower debt");
        assertEq(morphoV2.totalUnits(id), obligationUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), obligationUnits, "total shares");
        assertEq(loanToken.balanceOf(borrower), expectedAssets, "borrower balance");
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(morphoV2.consumed(lender, 0), expectedAssets, "lender consumed");
    }

    function testBuyObligationSharesInput1(uint256 obligationShares, uint256 price) public {
        obligationShares = bound(obligationShares, 1, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        borrowerOffer.startPrice = price;
        borrowerOffer.expiryPrice = price;
        uint256 expectedAssets = obligationShares.mulDivDown(price, WAD); // special case, no prior bad debt
            // realization.
        deal(address(loanToken), lender, expectedAssets);
        collateralize(obligation, borrower, obligationShares);
        borrowerOffer.assets = expectedAssets;

        take(0, 0, 0, obligationShares, lender, borrowerOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationShares, "lender obligation shares");
        assertEq(morphoV2.debtOf(borrower, id), obligationShares, "borrower debt");
        assertEq(morphoV2.totalUnits(id), obligationShares, "total obligations");
        assertEq(morphoV2.totalShares(id), obligationShares, "total shares");
        assertEq(loanToken.balanceOf(borrower), expectedAssets, "borrower balance");
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(morphoV2.consumed(borrower, 0), expectedAssets, "borrower consumed");
    }

    function testSellObligationSharesInput1(uint256 obligationShares, uint256 price) public {
        obligationShares = bound(obligationShares, 1, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        lenderOffer.startPrice = price;
        lenderOffer.expiryPrice = price;
        uint256 expectedAssets = obligationShares.mulDivDown(price, WAD); // special case, no prior bad debt
            // realization.
        deal(address(loanToken), lender, expectedAssets);
        collateralize(obligation, borrower, obligationShares);
        lenderOffer.assets = expectedAssets;

        take(0, 0, 0, obligationShares, borrower, lenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationShares, "lender obligation shares");
        assertEq(morphoV2.debtOf(borrower, id), obligationShares, "borrower debt");
        assertEq(morphoV2.totalUnits(id), obligationShares, "total obligations");
        assertEq(morphoV2.totalShares(id), obligationShares, "total shares");
        assertEq(loanToken.balanceOf(borrower), expectedAssets, "borrower balance");
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(morphoV2.consumed(lender, 0), expectedAssets, "lender consumed");
    }

    // path 2: Lender enters + lender exits.

    function testBuyAssetsInput2(uint256 buyerAssets, uint256 price, uint256 otherLenderUnits) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        vm.assume(expectedUnits <= maxAssets); // TODO improve this.
        otherLenderUnits = bound(otherLenderUnits, expectedUnits, maxAssets);
        setupOtherUsers(obligation, otherLenderUnits);
        deal(address(loanToken), lender, buyerAssets);
        otherLenderOffer.buy = false;
        otherLenderOffer.assets = type(uint256).max; // TODO: fix this.
        otherLenderOffer.startPrice = price;
        otherLenderOffer.expiryPrice = price;

        take(buyerAssets, 0, 0, 0, lender, otherLenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), expectedUnits, "lender obligation shares");
        assertEq(morphoV2.sharesOf(otherLender, id), otherLenderUnits - expectedUnits, "other lender obligation shares");
        assertEq(morphoV2.totalUnits(id), otherLenderUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), otherLenderUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "other lender balance");
        assertEq(morphoV2.consumed(otherLenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellAssetsInput2(uint256 buyerAssets, uint256 price, uint256 otherLenderUnits) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        vm.assume(expectedUnits <= maxAssets); // TODO improve this.
        otherLenderUnits = bound(otherLenderUnits, expectedUnits, maxAssets);
        setupOtherUsers(obligation, otherLenderUnits);
        deal(address(loanToken), lender, buyerAssets);
        lenderOffer.assets = buyerAssets;
        lenderOffer.startPrice = price;
        lenderOffer.expiryPrice = price;

        take(buyerAssets, 0, 0, 0, otherLender, lenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), expectedUnits, "lender obligation shares");
        assertEq(morphoV2.sharesOf(otherLender, id), otherLenderUnits - expectedUnits, "other lender obligation shares");
        assertEq(morphoV2.totalUnits(id), otherLenderUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), otherLenderUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "other lender balance");
        assertEq(morphoV2.consumed(lenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testBuyObligationUnitsInput2(uint256 obligationUnits, uint256 price, uint256 otherLenderUnits) public {
        obligationUnits = bound(obligationUnits, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationUnits.mulDivDown(price, WAD);
        vm.assume(obligationUnits <= maxAssets);
        otherLenderUnits = bound(otherLenderUnits, obligationUnits, maxAssets);
        setupOtherUsers(obligation, otherLenderUnits);
        deal(address(loanToken), lender, buyerAssets);
        otherLenderOffer.buy = false;
        otherLenderOffer.assets = type(uint256).max; // TODO: fix this.
        otherLenderOffer.startPrice = price;
        otherLenderOffer.expiryPrice = price;

        take(0, 0, obligationUnits, 0, lender, otherLenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationUnits, "lender obligation shares");
        assertEq(
            morphoV2.sharesOf(otherLender, id), otherLenderUnits - obligationUnits, "other lender obligation shares"
        );
        assertEq(morphoV2.totalUnits(id), otherLenderUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), otherLenderUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "other lender balance");
        assertEq(morphoV2.consumed(otherLenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellObligationUnitsInput2(uint256 obligationUnits, uint256 price, uint256 otherLenderUnits) public {
        obligationUnits = bound(obligationUnits, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationUnits.mulDivDown(price, WAD);
        vm.assume(obligationUnits <= maxAssets);
        otherLenderUnits = bound(otherLenderUnits, obligationUnits, maxAssets);
        setupOtherUsers(obligation, otherLenderUnits);
        deal(address(loanToken), lender, buyerAssets);
        lenderOffer.assets = buyerAssets;
        lenderOffer.startPrice = price;
        lenderOffer.expiryPrice = price;

        take(0, 0, obligationUnits, 0, otherLender, lenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationUnits, "lender obligation shares");
        assertEq(
            morphoV2.sharesOf(otherLender, id), otherLenderUnits - obligationUnits, "other lender obligation shares"
        );
        assertEq(morphoV2.totalUnits(id), otherLenderUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), otherLenderUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "other lender balance");
        assertEq(morphoV2.consumed(lenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testBuyObligationSharesInput2(uint256 obligationShares, uint256 price, uint256 otherLenderUnits) public {
        obligationShares = bound(obligationShares, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationShares.mulDivDown(price, WAD);
        vm.assume(obligationShares <= maxAssets);
        otherLenderUnits = bound(otherLenderUnits, obligationShares, maxAssets);
        setupOtherUsers(obligation, otherLenderUnits);
        deal(address(loanToken), lender, buyerAssets);
        otherLenderOffer.buy = false;
        otherLenderOffer.assets = type(uint256).max; // TODO: fix this.
        otherLenderOffer.startPrice = price;
        otherLenderOffer.expiryPrice = price;

        take(0, 0, 0, obligationShares, lender, otherLenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationShares, "lender obligation shares");
        assertEq(
            morphoV2.sharesOf(otherLender, id), otherLenderUnits - obligationShares, "other lender obligation shares"
        );
        assertEq(morphoV2.totalUnits(id), otherLenderUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), otherLenderUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "other lender balance");
        assertEq(morphoV2.consumed(otherLenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellObligationSharesInput2(uint256 obligationShares, uint256 price, uint256 otherLenderUnits) public {
        obligationShares = bound(obligationShares, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationShares.mulDivDown(price, WAD);
        vm.assume(obligationShares <= maxAssets);
        otherLenderUnits = bound(otherLenderUnits, obligationShares, maxAssets);
        setupOtherUsers(obligation, otherLenderUnits);
        deal(address(loanToken), lender, buyerAssets);
        lenderOffer.assets = buyerAssets;
        lenderOffer.startPrice = price;
        lenderOffer.expiryPrice = price;

        take(0, 0, 0, obligationShares, otherLender, lenderOffer);

        assertEq(morphoV2.sharesOf(lender, id), obligationShares, "lender obligation shares");
        assertEq(
            morphoV2.sharesOf(otherLender, id), otherLenderUnits - obligationShares, "other lender obligation shares"
        );
        assertEq(morphoV2.totalUnits(id), otherLenderUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), otherLenderUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(lender), 0, "lender balance");
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "other lender balance");
        assertEq(morphoV2.consumed(lenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    // path 3: Borrower exits + borrower enters.

    function testBuyAssetsInput3(uint256 buyerAssets, uint256 price, uint256 otherBorrowerDebt) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        vm.assume(expectedUnits <= maxAssets); // TODO improve this.
        otherBorrowerDebt = bound(otherBorrowerDebt, expectedUnits, maxAssets);
        setupOtherUsers(obligation, otherBorrowerDebt);
        collateralize(obligation, borrower, expectedUnits);
        borrowerOffer.assets = buyerAssets;
        borrowerOffer.startPrice = price;
        borrowerOffer.expiryPrice = price;

        take(buyerAssets, 0, 0, 0, otherBorrower, borrowerOffer);

        assertEq(morphoV2.debtOf(borrower, id), expectedUnits, "borrower obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), otherBorrowerDebt - expectedUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), otherBorrowerDebt, "total obligations");
        assertEq(morphoV2.totalShares(id), otherBorrowerDebt, "total shares"); // special case.
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(otherBorrower), otherBorrowerDebt - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(borrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellAssetsInput3(uint256 buyerAssets, uint256 price, uint256 otherBorrowerDebt) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        vm.assume(expectedUnits <= maxAssets); // TODO improve this.
        otherBorrowerDebt = bound(otherBorrowerDebt, expectedUnits, maxAssets);
        setupOtherUsers(obligation, otherBorrowerDebt);
        collateralize(obligation, borrower, expectedUnits);
        otherBorrowerOffer.assets = buyerAssets;
        otherBorrowerOffer.startPrice = price;
        otherBorrowerOffer.expiryPrice = price;

        take(buyerAssets, 0, 0, 0, borrower, otherBorrowerOffer);

        assertEq(morphoV2.debtOf(borrower, id), expectedUnits, "borrower debt");
        assertEq(morphoV2.debtOf(otherBorrower, id), otherBorrowerDebt - expectedUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), otherBorrowerDebt, "total obligations");
        assertEq(morphoV2.totalShares(id), otherBorrowerDebt, "total shares"); // special case.
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(otherBorrower), otherBorrowerDebt - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherBorrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testBuyObligationUnitsInput3(uint256 obligationUnits, uint256 price, uint256 otherBorrowerDebt) public {
        obligationUnits = bound(obligationUnits, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationUnits.mulDivDown(price, WAD);
        otherBorrowerDebt = bound(otherBorrowerDebt, obligationUnits, maxAssets);
        setupOtherUsers(obligation, otherBorrowerDebt);
        collateralize(obligation, borrower, obligationUnits);
        borrowerOffer.assets = buyerAssets;
        borrowerOffer.startPrice = price;
        borrowerOffer.expiryPrice = price;

        take(0, 0, obligationUnits, 0, otherBorrower, borrowerOffer);

        assertEq(morphoV2.debtOf(borrower, id), obligationUnits, "otherBorrower debt");
        assertEq(morphoV2.debtOf(otherBorrower, id), otherBorrowerDebt - obligationUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), otherBorrowerDebt, "total obligations");
        assertEq(morphoV2.totalShares(id), otherBorrowerDebt, "total shares"); // special case.
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(otherBorrower), otherBorrowerDebt - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(borrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellObligationUnitsInput3(uint256 obligationUnits, uint256 price, uint256 otherBorrowerDebt) public {
        obligationUnits = bound(obligationUnits, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationUnits.mulDivDown(price, WAD);
        otherBorrowerDebt = bound(otherBorrowerDebt, obligationUnits, maxAssets);
        setupOtherUsers(obligation, otherBorrowerDebt);
        collateralize(obligation, borrower, obligationUnits);
        otherBorrowerOffer.assets = buyerAssets;
        otherBorrowerOffer.startPrice = price;
        otherBorrowerOffer.expiryPrice = price;

        take(0, 0, obligationUnits, 0, borrower, otherBorrowerOffer);

        assertEq(morphoV2.debtOf(borrower, id), obligationUnits, "borrower debt");
        assertEq(morphoV2.debtOf(otherBorrower, id), otherBorrowerDebt - obligationUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), otherBorrowerDebt, "total obligations");
        assertEq(morphoV2.totalShares(id), otherBorrowerDebt, "total shares"); // special case.
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(otherBorrower), otherBorrowerDebt - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherBorrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testBuyObligationSharesInput3(uint256 obligationShares, uint256 price, uint256 otherBorrowerDebt) public {
        obligationShares = bound(obligationShares, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationShares.mulDivDown(price, WAD);
        otherBorrowerDebt = bound(otherBorrowerDebt, obligationShares, maxAssets);
        setupOtherUsers(obligation, otherBorrowerDebt);
        collateralize(obligation, borrower, obligationShares);
        borrowerOffer.assets = buyerAssets;
        borrowerOffer.startPrice = price;
        borrowerOffer.expiryPrice = price;

        take(0, 0, obligationShares, 0, otherBorrower, borrowerOffer);

        assertEq(morphoV2.debtOf(borrower, id), obligationShares, "borrower debt");
        assertEq(morphoV2.debtOf(otherBorrower, id), otherBorrowerDebt - obligationShares, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), otherBorrowerDebt, "total obligations");
        assertEq(morphoV2.totalShares(id), otherBorrowerDebt, "total shares"); // special case.
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(otherBorrower), otherBorrowerDebt - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(borrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellObligationSharesInput3(uint256 obligationShares, uint256 price, uint256 otherBorrowerDebt) public {
        obligationShares = bound(obligationShares, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationShares.mulDivDown(price, WAD);
        otherBorrowerDebt = bound(otherBorrowerDebt, obligationShares, maxAssets);
        setupOtherUsers(obligation, otherBorrowerDebt);
        collateralize(obligation, borrower, obligationShares);
        otherBorrowerOffer.assets = buyerAssets;
        otherBorrowerOffer.startPrice = price;
        otherBorrowerOffer.expiryPrice = price;

        take(0, 0, obligationShares, 0, borrower, otherBorrowerOffer);

        assertEq(morphoV2.debtOf(borrower, id), obligationShares, "borrower debt");
        assertEq(morphoV2.debtOf(otherBorrower, id), otherBorrowerDebt - obligationShares, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), otherBorrowerDebt, "total obligations");
        assertEq(morphoV2.totalShares(id), otherBorrowerDebt, "total shares"); // special case.
        assertEq(loanToken.balanceOf(borrower), buyerAssets, "borrower balance");
        assertEq(loanToken.balanceOf(otherBorrower), otherBorrowerDebt - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherBorrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    // path 4: Borrower exits + lender enters.

    function testBuyAssetsInput4(uint256 buyerAssets, uint256 price, uint256 existingUnits) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        vm.assume(expectedUnits <= maxAssets); // TODO improve this.
        existingUnits = bound(existingUnits, expectedUnits, maxAssets);
        setupOtherUsers(obligation, existingUnits);
        otherLenderOffer.assets = buyerAssets;
        otherLenderOffer.startPrice = price;
        otherLenderOffer.expiryPrice = price;

        take(buyerAssets, 0, 0, 0, otherBorrower, otherLenderOffer);

        assertEq(morphoV2.sharesOf(otherLender, id), existingUnits - expectedUnits, "otherLender obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), existingUnits - expectedUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), existingUnits - expectedUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), existingUnits - expectedUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "otherLender balance");
        assertEq(loanToken.balanceOf(otherBorrower), existingUnits - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherLenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellAssetsInput4(uint256 buyerAssets, uint256 price, uint256 existingUnits) public {
        buyerAssets = bound(buyerAssets, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 expectedUnits = buyerAssets.mulDivDown(WAD, price);
        vm.assume(expectedUnits <= maxAssets); // TODO improve this.
        existingUnits = bound(existingUnits, expectedUnits, maxAssets);
        setupOtherUsers(obligation, existingUnits);
        otherBorrowerOffer.assets = buyerAssets;
        otherBorrowerOffer.startPrice = price;
        otherBorrowerOffer.expiryPrice = price;

        take(buyerAssets, 0, 0, 0, otherLender, otherBorrowerOffer);

        assertEq(morphoV2.sharesOf(otherLender, id), existingUnits - expectedUnits, "otherLender obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), existingUnits - expectedUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), existingUnits - expectedUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), existingUnits - expectedUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "otherLender balance");
        assertEq(loanToken.balanceOf(otherBorrower), existingUnits - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherBorrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testBuyObligationUnitsInput4(uint256 obligationUnits, uint256 price, uint256 existingUnits) public {
        obligationUnits = bound(obligationUnits, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationUnits.mulDivDown(price, WAD);
        vm.assume(obligationUnits <= maxAssets); // TODO improve this.
        existingUnits = bound(existingUnits, obligationUnits, maxAssets);
        setupOtherUsers(obligation, existingUnits);
        otherLenderOffer.assets = buyerAssets;
        otherLenderOffer.startPrice = price;
        otherLenderOffer.expiryPrice = price;

        take(0, 0, obligationUnits, 0, otherBorrower, otherLenderOffer);

        assertEq(morphoV2.sharesOf(otherLender, id), existingUnits - obligationUnits, "otherLender obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), existingUnits - obligationUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), existingUnits - obligationUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), existingUnits - obligationUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "otherLender balance");
        assertEq(loanToken.balanceOf(otherBorrower), existingUnits - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherLenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellObligationUnitsInput4(uint256 obligationUnits, uint256 price, uint256 existingUnits) public {
        obligationUnits = bound(obligationUnits, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationUnits.mulDivDown(price, WAD);
        vm.assume(obligationUnits <= maxAssets); // TODO improve this.
        existingUnits = bound(existingUnits, obligationUnits, maxAssets);
        setupOtherUsers(obligation, existingUnits);
        otherBorrowerOffer.assets = buyerAssets;
        otherBorrowerOffer.startPrice = price;
        otherBorrowerOffer.expiryPrice = price;

        take(0, 0, obligationUnits, 0, otherLender, otherBorrowerOffer);

        assertEq(morphoV2.sharesOf(otherLender, id), existingUnits - obligationUnits, "otherLender obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), existingUnits - obligationUnits, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), existingUnits - obligationUnits, "total obligations");
        assertEq(morphoV2.totalShares(id), existingUnits - obligationUnits, "total shares"); // special case.
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "otherLender balance");
        assertEq(loanToken.balanceOf(otherBorrower), existingUnits - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherBorrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testBuyObligationSharesInput4(uint256 obligationShares, uint256 price, uint256 existingUnits) public {
        obligationShares = bound(obligationShares, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationShares.mulDivDown(price, WAD);
        vm.assume(obligationShares <= maxAssets); // TODO improve this.
        existingUnits = bound(existingUnits, obligationShares, maxAssets);
        setupOtherUsers(obligation, existingUnits);

        otherLenderOffer.assets = buyerAssets;
        otherLenderOffer.startPrice = price;
        otherLenderOffer.expiryPrice = price;

        take(0, 0, 0, obligationShares, otherBorrower, otherLenderOffer);

        assertEq(morphoV2.sharesOf(otherLender, id), existingUnits - obligationShares, "otherLender obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), existingUnits - obligationShares, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), existingUnits - obligationShares, "total obligations");
        assertEq(morphoV2.totalShares(id), existingUnits - obligationShares, "total shares"); // special case.
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "otherLender balance");
        assertEq(loanToken.balanceOf(otherBorrower), existingUnits - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherLenderOffer.maker, 0), buyerAssets, "maker consumed");
    }

    function testSellObligationSharesInput4(uint256 obligationShares, uint256 price, uint256 existingUnits) public {
        obligationShares = bound(obligationShares, 0, maxAssets);
        price = bound(price, 0.01 ether, 1 ether);
        uint256 buyerAssets = obligationShares.mulDivDown(price, WAD);
        vm.assume(obligationShares <= maxAssets); // TODO improve this.
        existingUnits = bound(existingUnits, obligationShares, maxAssets);
        setupOtherUsers(obligation, existingUnits);

        otherBorrowerOffer.assets = buyerAssets;
        otherBorrowerOffer.startPrice = price;
        otherBorrowerOffer.expiryPrice = price;

        take(0, 0, 0, obligationShares, otherLender, otherBorrowerOffer);

        assertEq(morphoV2.sharesOf(otherLender, id), existingUnits - obligationShares, "otherLender obligation shares");
        assertEq(morphoV2.debtOf(otherBorrower, id), existingUnits - obligationShares, "otherBorrower debt");
        assertEq(morphoV2.totalUnits(id), existingUnits - obligationShares, "total obligations");
        assertEq(morphoV2.totalShares(id), existingUnits - obligationShares, "total shares"); // special case.
        assertEq(loanToken.balanceOf(otherLender), buyerAssets, "otherLender balance");
        assertEq(loanToken.balanceOf(otherBorrower), existingUnits - buyerAssets, "otherBorrower balance");
        assertEq(morphoV2.consumed(otherBorrowerOffer.maker, 0), buyerAssets, "maker consumed");
    }

    // other tests.

    function testMatch() public {
        take(100, 0, 0, 0, address(this), borrowerOffer);
        take(0, 0, 101, 0, address(this), lenderOffer);

        assertEq(morphoV2.sharesOf(address(this), id), 0, "obligation shares");
        assertEq(morphoV2.debtOf(address(this), id), 0, "debt");
        assertEq(loanToken.balanceOf(address(this)), 99, "balance");
        assertEq(morphoV2.consumed(lender, 0), 99, "lender consumed");
        assertEq(morphoV2.consumed(borrower, 0), 100, "borrower consumed");
    }

    function testConsumed() public {
        take(100, 0, 0, 0, borrower, lenderOffer);

        vm.expectRevert("consumed");
        take(100, 0, 0, 0, borrower, lenderOffer);
    }

    function testTakePartialFill() public {
        take(50, 0, 0, 0, borrower, lenderOffer);

        assertEq(morphoV2.consumed(lender, 0), 50);

        vm.expectRevert("consumed");
        take(51, 0, 0, 0, borrower, lenderOffer);

        take(50, 0, 0, 0, borrower, lenderOffer);

        assertEq(morphoV2.consumed(lender, 0), 100);
    }

    function testTakeOCO() public {
        Offer memory lenderOffer2 = lenderOffer;
        lenderOffer2.obligation.maturity = block.timestamp + 200;
        lenderOffer2.expiry = block.timestamp + 200;
        Obligation memory obligation2 = obligation;
        obligation2.maturity = block.timestamp + 200;

        take(70, 0, 0, 0, borrower, lenderOffer);

        vm.expectRevert("consumed");
        take(31, 0, 0, 0, borrower, lenderOffer2);

        morphoV2.supplyCollateral(obligation2, obligation2.collaterals[0].token, 134, borrower);

        take(30, 0, 0, 0, borrower, lenderOffer2);
        assertEq(morphoV2.consumed(lender, 0), 100);
    }

    // other tests.

    function testTakePastMaturity(uint256 elapsed) public {
        uint256 expiry = obligation.maturity * 3;
        lenderOffer.expiry = expiry;
        borrowerOffer.expiry = expiry;
        vm.warp(bound(elapsed, vm.getBlockTimestamp(), obligation.maturity * 3));

        uint256 snap = vm.snapshotState();

        take(100, 0, 0, 0, borrower, lenderOffer);

        vm.revertToStateAndDelete(snap);
        take(100, 0, 0, 0, lender, borrowerOffer);
    }

    function testTakeSellerMakerNotHealthyMaker() public {
        morphoV2.withdrawCollateral(obligation, obligation.collaterals[0].token, 1, borrower);
        vm.expectRevert("Seller is unhealthy");
        take(100, 0, 0, 0, lender, borrowerOffer);
    }

    function testTakeSellerTakerNotHealthy() public {
        morphoV2.withdrawCollateral(obligation, obligation.collaterals[0].token, 1, borrower);
        vm.expectRevert("Seller is unhealthy");
        take(100, 0, 0, 0, borrower, lenderOffer);
    }

    function testTakeInconsistentPrices() public {
        lenderOffer.start = block.timestamp;
        lenderOffer.expiryPrice = 0.98 ether;
        lenderOffer.expiry = lenderOffer.start;
        vm.expectRevert("inconsistent prices");
        take(100, 0, 0, 0, borrower, lenderOffer);
    }

    function testNonce() public {
        vm.prank(lender);
        morphoV2.shuffleNonce();

        vm.expectRevert("invalid nonce");
        take(100, 0, 0, 0, borrower, lenderOffer);
    }

    // test tree / signatures.

    function testTakeWrongRoot() public {
        vm.expectRevert("invalid signature");
        morphoV2.take(
            100,
            0,
            0,
            0,
            borrower,
            lenderOffer,
            sig([borrowerOffer]),
            root([lenderOffer]),
            proof([lenderOffer]),
            address(0),
            hex""
        );
    }

    function testTakeInvalidSignature() public {
        vm.expectRevert("invalid signature");
        morphoV2.take(
            100,
            0,
            0,
            0,
            borrower,
            lenderOffer,
            Signature({v: 0, r: 0, s: 0}),
            root([lenderOffer]),
            proof([lenderOffer]),
            address(0),
            hex""
        );
    }

    function testTakeInvalidProofOneLeaf(bytes32[] memory proof) public {
        vm.assume(proof.length >= 1);
        vm.expectRevert("invalid proof");
        morphoV2.take(
            100, 0, 0, 0, borrower, lenderOffer, sig([lenderOffer]), root([lenderOffer]), proof, address(0), hex""
        );
    }

    function testTakeInvalidProofTwoLeaves(Offer memory otherOffer, bytes32[] memory proof) public {
        vm.assume(proof.length >= 1);
        vm.assume(proof[0] != keccak256(abi.encode(otherOffer)));
        vm.expectRevert("invalid proof");
        morphoV2.take(
            100,
            0,
            0,
            0,
            borrower,
            lenderOffer,
            sig([lenderOffer, otherOffer]),
            root([lenderOffer, otherOffer]),
            proof,
            address(0),
            hex""
        );
    }

    function testTakeTwoLeaves(Offer memory otherOffer) public {
        morphoV2.take(
            100,
            0,
            0,
            0,
            borrower,
            lenderOffer,
            sig([lenderOffer, otherOffer]),
            root([lenderOffer, otherOffer]),
            proof([lenderOffer, otherOffer]),
            address(0),
            hex""
        );
    }

    // test callbacks.

    function testTakeLendBorrowCallback() public {
        borrowerOffer.callback = address(new BorrowCallback());
        borrowerOffer.callbackData = abi.encode(obligation.collaterals[0].token, 135);
        borrowerOffer.maker = address(otherBorrower);
        deal(obligation.collaterals[0].token, borrowerOffer.callback, 135);
        assertEq(morphoV2.collateralOf(otherBorrower, id, obligation.collaterals[0].token), 0);

        take(100, 0, 0, 0, lender, borrowerOffer);

        assertEq(morphoV2.collateralOf(otherBorrower, id, obligation.collaterals[0].token), 135);
        assertEq(BorrowCallback(borrowerOffer.callback).recordedData(), borrowerOffer.callbackData);
    }

    function testTakeBorrowBorrowCallback() public {
        (address otherBorrower,) = makeAddrAndKey("otherBorrower");
        address callback = address(new BorrowCallback());
        deal(obligation.collaterals[0].token, callback, 135);
        assertEq(morphoV2.collateralOf(otherBorrower, id, obligation.collaterals[0].token), 0);

        morphoV2.take(
            100,
            0,
            0,
            0,
            otherBorrower,
            lenderOffer,
            sig([lenderOffer]),
            root([lenderOffer]),
            proof([lenderOffer]),
            callback,
            abi.encode(obligation.collaterals[0].token, 135)
        );
        assertEq(morphoV2.collateralOf(otherBorrower, id, obligation.collaterals[0].token), 135);
        assertEq(BorrowCallback(callback).recordedData(), abi.encode(obligation.collaterals[0].token, 135));
    }

    function testTakeBorrowLendCallback() public {
        vm.prank(otherLender);
        loanToken.approve(address(morphoV2), 100);
        lenderOffer.callback = address(new LendCallback());
        lenderOffer.callbackData = abi.encode(loanToken, 100);
        lenderOffer.maker = address(otherLender);
        deal(address(loanToken), lenderOffer.callback, 100);

        take(100, 0, 0, 0, borrower, lenderOffer);

        assertEq(LendCallback(lenderOffer.callback).recordedData(), lenderOffer.callbackData);
    }

    function testTakeLendLendCallback() public {
        (address otherLender,) = makeAddrAndKey("otherLender");
        vm.prank(otherLender);
        loanToken.approve(address(morphoV2), 100);
        address callback = address(new LendCallback());
        deal(address(loanToken), callback, 100);

        morphoV2.take(
            100,
            0,
            0,
            0,
            otherLender,
            borrowerOffer,
            sig([borrowerOffer]),
            root([borrowerOffer]),
            proof([borrowerOffer]),
            callback,
            abi.encode(address(loanToken), 100)
        );
        assertEq(LendCallback(callback).recordedData(), abi.encode(address(loanToken), 100));
    }
}

contract BorrowCallback is ICallbacks {
    bytes public recordedData;

    function onSell(
        Obligation memory obligation,
        address seller,
        uint256,
        uint256,
        uint256,
        uint256,
        bytes memory data
    ) external {
        recordedData = data;
        (address collateralToken, uint256 amount) = abi.decode(data, (address, uint256));
        ERC20(collateralToken).approve(msg.sender, amount);
        MorphoV2(msg.sender).supplyCollateral(obligation, collateralToken, amount, seller);
    }

    function onBuy(
        Obligation memory obligation,
        address buyer,
        uint256 buyerAssets,
        uint256 sellerAssets,
        uint256 obligationUnits,
        uint256 obligationShares,
        bytes memory data
    ) external {}

    function onLiquidate(Seizure[] memory seizures, address borrower, address liquidator, bytes memory data) external {}
}

contract LendCallback is ICallbacks {
    bytes public recordedData;

    function onBuy(
        Obligation memory obligation,
        address buyer,
        uint256 buyerAssets,
        uint256,
        uint256,
        uint256,
        bytes memory data
    ) external {
        recordedData = data;
        require(ERC20(obligation.loanToken).transfer(buyer, buyerAssets), "transfer failed");
    }

    function onSell(
        Obligation memory obligation,
        address seller,
        uint256 buyerAssets,
        uint256 sellerAssets,
        uint256 obligationUnits,
        uint256 obligationShares,
        bytes memory data
    ) external {}
    function onLiquidate(Seizure[] memory seizures, address borrower, address liquidator, bytes memory data) external {}
}
