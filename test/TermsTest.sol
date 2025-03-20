// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import "../src/Terms.sol";
import {ERC20} from "./helpers/ERC20.sol";
import {Oracle} from "./helpers/Oracle.sol";

contract TermsTest is Test {
    Terms private terms;
    ERC20 private loanToken;
    ERC20 private collateralToken;
    Oracle private oracle;
    uint256 private borrowerSK;
    address private borrower;
    uint256 private lenderSK;
    address private lender;
    Term private term;
    bytes32 private id;
    Collateral[] private collaterals;

    function setUp() external {
        (borrower, borrowerSK) = makeAddrAndKey("borrower");
        (lender, lenderSK) = makeAddrAndKey("lender");

        terms = new Terms();
        loanToken = new ERC20("loan", "loan", 1 ether);
        loanToken.transfer(lender, 99);
        loanToken.transfer(borrower, 1);
        collateralToken = new ERC20("collat", "collat", 1 ether);
        oracle = new Oracle();

        collaterals = new Collateral[](1);
        collaterals[0] = Collateral({token: address(collateralToken), lltv: 1e18, oracle: address(oracle)});

        term = Term(address(loanToken), collaterals, block.timestamp + 100);
        id = keccak256(abi.encode(term));

        vm.prank(lender);
        loanToken.approve(address(terms), type(uint256).max);
        vm.prank(borrower);
        loanToken.approve(address(terms), type(uint256).max);
        collateralToken.approve(address(terms), type(uint256).max);
        terms.supplyCollateral(term, address(collateralToken), 1 ether, borrower);
    }

    function testMint() public {
        Offer memory lendOffer = Offer({
            buy: true,
            offering: lender,
            assets: 100,
            loanToken: address(loanToken),
            collaterals: collaterals,
            maturity: block.timestamp + 100,
            price: 99
        });
        Offer memory borrowOffer = Offer({
            buy: false,
            offering: borrower,
            assets: 100,
            loanToken: address(loanToken),
            collaterals: collaterals,
            maturity: block.timestamp + 100,
            price: 99
        });

        Signature memory lendSig = _signOffer(lendOffer, lenderSK);
        Signature memory borrowSig = _signOffer(borrowOffer, borrowerSK);

        terms.MATCH(lendOffer, lendSig, borrowOffer, borrowSig);

        assertEq(terms.bondOf(lender, id), 100);
        assertEq(terms.debtOf(borrower, id), 100);

        assertEq(loanToken.balanceOf(borrower), 100);
        assertEq(loanToken.balanceOf(lender), 0);
    }

    function testRepay() public {
        testMint();

        vm.warp(block.timestamp + 99);

        vm.prank(borrower);
        terms.repayDebt(term, 100, borrower);

        assertEq(terms.debtOf(borrower, id), 0);
        assertEq(terms.withdrawable(id), 100);

        assertEq(loanToken.balanceOf(address(terms)), 100);
        assertEq(loanToken.balanceOf(borrower), 0);
    }

    function testWithdraw() public {
        testRepay();

        vm.prank(lender);
        terms.withdrawBond(term, 100, lender);

        assertEq(terms.bondOf(lender, id), 0);
        assertEq(terms.withdrawable(id), 0);

        assertEq(loanToken.balanceOf(address(terms)), 0);
        assertEq(loanToken.balanceOf(lender), 100);
    }

    function testWithdrawCollateral() public {
        testRepay();

        vm.prank(borrower);
        terms.withdrawCollateral(term, address(collateralToken), 1 ether, borrower);

        assertEq(terms.collateralOf(borrower, id, address(collateralToken)), 0);

        assertEq(collateralToken.balanceOf(address(terms)), 0);
        assertEq(collateralToken.balanceOf(borrower), 1 ether);
    }

    function genTerm() internal returns (Term memory) {
        // instantiate tokens and oracle
        ERC20 c1 = new ERC20("collat1", "c1", 1 ether);
        ERC20 c2 = new ERC20("collat1", "c2", 1 ether);
        Oracle o1 = new Oracle();
        Oracle o2 = new Oracle();
        Collateral[] memory cs = new Collateral[](1);
        cs[0] = Collateral({token: address(c1), lltv: 0.75e18, oracle: address(o1)});
        cs[1] = Collateral({token: address(c2), lltv: 1e18, oracle: address(o2)});
        Term memory t = Term(address(loanToken), cs, block.timestamp + 100);
        return t;
    }

    function genSeizures() internal pure returns (Seizure[] memory) {
        Seizure[] memory s = new Seizure[](1);
        s[0] = Seizure({collateralIndex: 0, repaidAmount: 43, seizedAssets: 0});

        return s;
    }

    function mintBond(Collateral[] memory cs) internal {
        Offer memory lendOffer = Offer({
            buy: true,
            offering: lender,
            assets: 100,
            loanToken: address(loanToken),
            collaterals: cs,
            maturity: block.timestamp + 100,
            price: 99
        });
        Offer memory borrowOffer = Offer({
            buy: false,
            offering: borrower,
            assets: 100,
            loanToken: address(loanToken),
            collaterals: cs,
            maturity: block.timestamp + 100,
            price: 99
        });

        Signature memory lendSig = _signOffer(lendOffer, lenderSK);
        Signature memory borrowSig = _signOffer(borrowOffer, borrowerSK);

        terms.MATCH(lendOffer, lendSig, borrowOffer, borrowSig);
    }

    function testLiquidation() public {
        address liquidator;
        uint256 liquidatorSK;
        (liquidator, liquidatorSK) = makeAddrAndKey("liquidator");

        Term memory t = genTerm();

        deal(t.collaterals[0].token, borrower, 1 ether);
        deal(t.collaterals[1].token, borrower, 1 ether);

        vm.startPrank(borrower);
        ERC20(t.collaterals[0].token).approve(address(terms), type(uint256).max);
        ERC20(t.collaterals[1].token).approve(address(terms), type(uint256).max);
        terms.supplyCollateral(t, t.collaterals[0].token, 134, borrower);
        terms.supplyCollateral(t, t.collaterals[1].token, 34, borrower);
        vm.stopPrank();

        mintBond(t.collaterals);

        Seizure[] memory s = genSeizures();
        loanToken.transfer(liquidator, 50);

        vm.prank(liquidator);
        loanToken.approve(address(terms), type(uint256).max);

        vm.warp(block.timestamp + 50);
        Oracle(t.collaterals[0].oracle).setPrice(0.5e18);

        vm.prank(liquidator);
        uint256 gasBefore = gasleft();
        terms.liquidate(t, s, borrower, "0x0");
        uint256 gasUsed = gasBefore - gasleft();

        oracle.setPrice(1e18);
        emit log_named_uint("Gas used", gasUsed);

        bytes32 idT = keccak256(abi.encode(t));
        assertEq(terms.debtOf(borrower, idT), 57);
        assertEq(terms.withdrawable(idT), 43);

        assertEq(loanToken.balanceOf(address(terms)), 43);
        assertEq(loanToken.balanceOf(liquidator), 7);
        assertEq(ERC20(t.collaterals[0].token).balanceOf(liquidator), 98);
    }

    function _signOffer(Offer memory offer, uint256 sk) internal view returns (Signature memory) {
        bytes32 hashStruct = keccak256(abi.encode(terms.OFFER_TYPEHASH(), offer));
        bytes32 domainSeparator = keccak256(abi.encode(terms.DOMAIN_TYPEHASH(), block.chainid, address(terms)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, hashStruct));

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(sk, digest);
        return sig;
    }
}
