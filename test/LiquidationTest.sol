// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import "./BaseTest.sol";

contract LiquidationTest is BaseTest {
    Term internal term;
    bytes32 internal id;
    Collateral[] internal collaterals;

    function setUp() public override {
        super.setUp();

        collaterals = new Collateral[](2);
        collaterals[0] = Collateral({token: address(collateralToken1), lltv: 0.75e18, oracle: address(oracle)});
        collaterals[1] = Collateral({token: address(collateralToken2), lltv: 0.75e18, oracle: address(oracle)});
        collaterals = sortCollaterals(collaterals);

        term = Term(address(loanToken), collaterals, block.timestamp + 100);
        id = keccak256(abi.encode(term));
    }

    function testLiquidateWrongSeizuresLength() public {
        vm.expectRevert("should have all collats");
        terms.liquidate(term, new Seizure[](0), borrower, "");
    }

    function testLiquidateHealthy() public {
        setupBond(term, 100);

        vm.expectRevert("position is healthy");
        terms.liquidate(term, new Seizure[](2), borrower, "");
    }

    function testLiquidateNoOp() public {
        setupBond(term, 100);
        oracle.setPrice(0);

        terms.liquidate(term, new Seizure[](2), borrower, "");
    }

    function testLiquidateInconsistentInput() public {
        setupBond(term, 100);
        oracle.setPrice(0);

        Seizure[] memory seizures = new Seizure[](2);
        seizures[0] = Seizure({repaidBonds: 1, seizedAssets: 1});
        seizures[1] = Seizure({repaidBonds: 0, seizedAssets: 100});

        vm.expectRevert("INCONSISTENT_INPUT");
        terms.liquidate(term, seizures, borrower, "");
    }

    function testLiquidateBondsInput() public {
        // Setup
        setupBond(term, 100);
        oracle.setPrice(1e36 - 1);
        deal(address(loanToken), address(this), 1);

        // Test
        Seizure[] memory seizures = new Seizure[](2);
        seizures[0] = Seizure({repaidBonds: 1, seizedAssets: 0});
        seizures[1] = Seizure({repaidBonds: 0, seizedAssets: 0});
        terms.liquidate(term, seizures, borrower, "");
        assertEq(terms.debtOf(borrower, id), 99);
        assertEq(terms.collateralOf(borrower, id, collaterals[0].token), 133);
        assertEq(loanToken.balanceOf(address(this)), 0);
    }

    function testLiquidateCollateralInput() public {
        // Setup
        setupBond(term, 100);
        oracle.setPrice(1e36 - 1);
        deal(address(loanToken), address(this), 1);

        // Test
        Seizure[] memory seizures = new Seizure[](2);
        seizures[0] = Seizure({repaidBonds: 0, seizedAssets: 1});
        seizures[1] = Seizure({repaidBonds: 0, seizedAssets: 0});
        terms.liquidate(term, seizures, borrower, "");
        assertEq(loanToken.balanceOf(address(this)), 0);
        assertEq(terms.debtOf(borrower, id), 99);
        assertEq(terms.collateralOf(borrower, id, collaterals[0].token), 133);
    }

    function testLiquidateBadDebt() public {
        // Setup
        setupBond(term, 100);
        oracle.setPrice(0.5e36);
        deal(address(loanToken), address(this), 1);

        // Test
        Seizure[] memory seizures = new Seizure[](2);
        seizures[0] = Seizure({repaidBonds: 1, seizedAssets: 0});
        seizures[1] = Seizure({repaidBonds: 0, seizedAssets: 0});
        terms.liquidate(term, seizures, borrower, "");
        assertEq(terms.collateralOf(borrower, id, collaterals[0].token), 132);
        // TODO assert bad debt
    }
}
