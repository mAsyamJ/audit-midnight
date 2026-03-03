// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {Obligation, Offer, Signature, Collateral} from "../src/interfaces/IMidnight.sol";
import {UtilsLib} from "../src/libraries/UtilsLib.sol";
import {TickLib, TICK_RANGE} from "../src/libraries/TickLib.sol";
import {WAD} from "../src/libraries/ConstantsLib.sol";
import {TakeBundler} from "../src/periphery/TakeBundler.sol";
import {BaseTest} from "./BaseTest.sol";

contract BundlerTest is BaseTest {
    using UtilsLib for uint256;

    TakeBundler internal takeBundler;

    Obligation internal obligation;
    bytes20 internal id;
    Offer internal borrowerOffer;

    function setUp() public override {
        super.setUp();

        takeBundler = new TakeBundler();

        obligation.loanToken = address(loanToken);
        obligation.maturity = block.timestamp + 100;
        obligation.collaterals
            .push(Collateral({token: address(collateralToken1), lltv: 0.75e18, oracle: address(oracle1)}));
        obligation.collaterals
            .push(Collateral({token: address(collateralToken2), lltv: 0.75e18, oracle: address(oracle2)}));
        obligation.collaterals = sortCollaterals(obligation.collaterals);
        obligation.rcfThreshold = 0;

        id = toId(obligation);

        borrowerOffer.buy = false;
        borrowerOffer.maker = borrower;
        borrowerOffer.receiverIfMakerIsSeller = borrower;
        borrowerOffer.obligationShares = type(uint256).max;
        borrowerOffer.obligation = obligation;
        borrowerOffer.expiry = block.timestamp + 200;
        borrowerOffer.tick = TICK_RANGE;
    }

    function testLengthMismatchSigs() public {
        Offer[] memory offers = new Offer[](2);
        offers[0] = borrowerOffer;
        offers[1] = borrowerOffer;

        Signature[] memory sigs = new Signature[](1);
        bytes32[] memory roots = new bytes32[](2);
        bytes32[][] memory proofs = new bytes32[][](2);

        vm.prank(lender);
        vm.expectRevert("length mismatch");
        takeBundler.bundleTake(midnight, 100, lender, address(0), hex"", address(0), offers, sigs, roots, proofs);
    }

    function testLengthMismatchRoots() public {
        Offer[] memory offers = new Offer[](2);
        offers[0] = borrowerOffer;
        offers[1] = borrowerOffer;

        Signature[] memory sigs = new Signature[](2);
        bytes32[] memory roots = new bytes32[](1);
        bytes32[][] memory proofs = new bytes32[][](2);

        vm.prank(lender);
        vm.expectRevert("length mismatch");
        takeBundler.bundleTake(midnight, 100, lender, address(0), hex"", address(0), offers, sigs, roots, proofs);
    }

    function testLengthMismatchProofs() public {
        Offer[] memory offers = new Offer[](2);
        offers[0] = borrowerOffer;
        offers[1] = borrowerOffer;

        Signature[] memory sigs = new Signature[](2);
        bytes32[] memory roots = new bytes32[](2);
        bytes32[][] memory proofs = new bytes32[][](1);

        vm.prank(lender);
        vm.expectRevert("length mismatch");
        takeBundler.bundleTake(midnight, 100, lender, address(0), hex"", address(0), offers, sigs, roots, proofs);
    }
}
