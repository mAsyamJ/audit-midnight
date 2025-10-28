// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {LIQUIDATION_INCENTIVE_FACTOR, WAD, ORACLE_PRICE_SCALE} from "../src/libraries/ConstantsLib.sol";
import {Obligation, Collateral, Seizure} from "../src/interfaces/IMorphoV2.sol";
import {MathLib} from "../src/libraries/MathLib.sol";
import {Oracle} from "./helpers/Oracle.sol";
import {BaseTest, MAX_TEST_AMOUNT} from "./BaseTest.sol";

contract LiquidationTest is BaseTest {
    using MathLib for uint256;

    Obligation internal obligation;
    bytes32 internal id;

    Seizure[] internal recordedSeizures;
    address internal recordedBorrower;
    address internal recordedLiquidator;
    bytes internal recordedData;

    Seizure[] internal seizures;

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

        id = toId(obligation);
    }

    function testLiquidateHealthy(uint256 obligations) public {
        obligations = bound(obligations, 1, MAX_TEST_AMOUNT);
        collateralize(obligation, borrower, obligations);
        setupObligation(obligation, obligations);

        vm.expectRevert("position is healthy");
        morphoV2.liquidate(obligation, seizures, borrower, "");
    }

    function testLiquidateNoOp(uint256 obligations) public {
        obligations = bound(obligations, 1, MAX_TEST_AMOUNT);
        collateralize(obligation, borrower, obligations);
        setupObligation(obligation, obligations);
        oracle.setPrice(0);

        morphoV2.liquidate(obligation, seizures, borrower, "");
    }

    function testLiquidateInconsistentInput(uint256 obligations) public {
        obligations = bound(obligations, 1, MAX_TEST_AMOUNT);
        collateralize(obligation, borrower, obligations);
        setupObligation(obligation, obligations);
        oracle.setPrice(0);
        seizures.push(Seizure({collateralIndex: 0, repaid: 1, seized: 1}));

        vm.expectRevert("INCONSISTENT_INPUT");
        morphoV2.liquidate(obligation, seizures, borrower, "");
    }

    function testLiquidateObligationUnitsInput(uint256 obligations, uint256 repaid) public {
        obligations = bound(obligations, 1, MAX_TEST_AMOUNT);
        repaid = bound(repaid, 0, obligations);
        collateralize(obligation, borrower, obligations);
        setupObligation(obligation, obligations);
        uint256 initialCollateral = morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token);
        oracle.setPrice(1e36 - 1);
        deal(address(loanToken), address(this), repaid);
        seizures.push(Seizure({collateralIndex: 0, repaid: repaid, seized: 0}));

        morphoV2.liquidate(obligation, seizures, borrower, "");

        assertEq(morphoV2.debtOf(borrower, id), obligations - repaid);
        assertEq(
            morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token),
            initialCollateral
                - repaid.mulDivDown(ORACLE_PRICE_SCALE, 1e36 - 1).mulDivDown(LIQUIDATION_INCENTIVE_FACTOR, WAD)
        );
        assertEq(loanToken.balanceOf(address(this)), 0);
    }

    function testLiquidateCollateralInput(uint256 obligations, uint256 seized) public {
        obligations = bound(obligations, 1, MAX_TEST_AMOUNT);
        collateralize(obligation, borrower, obligations);
        setupObligation(obligation, obligations);
        uint256 initialCollateral = morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token);
        seized = bound(seized, 0, obligations.mulDivDown(LIQUIDATION_INCENTIVE_FACTOR, WAD));
        oracle.setPrice(1e36 - 1);
        uint256 repaid = seized.mulDivUp(WAD, LIQUIDATION_INCENTIVE_FACTOR).mulDivUp(1e36 - 1, ORACLE_PRICE_SCALE);
        deal(address(loanToken), address(this), repaid);
        seizures.push(Seizure({collateralIndex: 0, repaid: 0, seized: seized}));

        morphoV2.liquidate(obligation, seizures, borrower, "");

        assertEq(loanToken.balanceOf(address(this)), 0, "loan token balance");
        assertApproxEqAbs(morphoV2.debtOf(borrower, id), obligations - repaid, 1, "debt"); // TODO fix approx
        assertEq(
            morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token),
            initialCollateral - seized,
            "collateral"
        );
    }

    function testLiquidateBadDebt() public {
        collateralize(obligation, borrower, 100);
        setupObligation(obligation, 100);
        oracle.setPrice(0.5e36);
        deal(address(loanToken), address(this), 1);
        seizures.push(Seizure({collateralIndex: 0, repaid: 1, seized: 0}));

        morphoV2.liquidate(obligation, seizures, borrower, "");

        assertEq(morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token), 132);
        // TODO assert bad debt
    }

    function testLiquidateCallback(bytes memory data) public {
        vm.assume(data.length > 0);
        collateralize(obligation, borrower, 100);
        setupObligation(obligation, 100);
        oracle.setPrice(1e36 - 1);
        deal(address(loanToken), address(this), 1);
        seizures.push(Seizure({collateralIndex: 0, repaid: 1, seized: 0}));

        morphoV2.liquidate(obligation, seizures, borrower, data);

        assertEq(recordedSeizures.length, 1, "seizures length");
        assertEq(recordedSeizures[0].repaid, 1, "repaid obligations");
        assertEq(recordedSeizures[0].seized, 1, "seized assets");
        assertEq(recordedBorrower, borrower, "borrower");
        assertEq(recordedLiquidator, address(this), "liquidator");
        assertEq(recordedData, data, "data");
    }

    // Check that if there is bad debt it is possible to seize all assets.
    function testLiquidateAllWhenBadDebt(uint256 obligations) public {
        obligations = bound(obligations, 1, MAX_TEST_AMOUNT);
        Oracle oracle2 = new Oracle();
        obligation.collaterals[1].oracle = address(oracle2);
        id = toId(obligation);
        collateralize(obligation, borrower, obligations);
        setupObligation(obligation, obligations);
        uint256 initialCollateral = morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token);
        oracle.setPrice(1e36 / 2); // TODO fuzz
        deal(address(loanToken), address(this), obligations); // not needed.
        seizures.push(Seizure({collateralIndex: 0, repaid: 0, seized: initialCollateral}));

        morphoV2.liquidate(obligation, seizures, borrower, "");

        assertEq(morphoV2.collateralOf(borrower, id, obligation.collaterals[0].token), 0);
    }

    function onLiquidate(Seizure[] memory _seizures, address borrower, address liquidator, bytes memory data) public {
        for (uint256 i = 0; i < _seizures.length; i++) {
            recordedSeizures.push(_seizures[i]);
        }
        recordedBorrower = borrower;
        recordedLiquidator = liquidator;
        recordedData = data;
    }
}
