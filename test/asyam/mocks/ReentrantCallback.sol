// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IBuyCallback, ISellCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market, Offer} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {MidnightBundles} from "../../../src/periphery/MidnightBundles.sol";
import {IMidnightBundles, Take, CollateralSupply, TokenPermit} from "../../../src/periphery/interfaces/IMidnightBundles.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";
import {IdLib} from "../../../src/libraries/IdLib.sol";

/// @notice Buy callback that attempts nested Midnight / bundle calls during onBuy.
contract ReentrantBuyCallback is IBuyCallback {
    Midnight public midnight;
    MidnightBundles public bundles;
    address public attacker;
    bool public reentered;
    uint256 public stolen;

    Offer internal nestedOffer;
    bytes internal nestedRatifierData;
    uint256 internal nestedUnits;
    address internal nestedTaker;

    Take[] internal bundleTakes;
    uint256 internal bundleTargetUnits;
    address internal bundleTaker;
    address internal bundleReceiver;
    bool internal useBundleReentry;

    function configure(Midnight _midnight, MidnightBundles _bundles, address _attacker) external {
        midnight = _midnight;
        bundles = _bundles;
        attacker = _attacker;
    }

    function setNestedTake(Offer memory offer, bytes memory ratifierData, uint256 units, address taker) external {
        nestedOffer = offer;
        nestedRatifierData = ratifierData;
        nestedUnits = units;
        nestedTaker = taker;
        useBundleReentry = false;
    }

    function setBundleReentry(
        Take[] memory takes,
        uint256 targetUnits,
        address taker,
        address receiver
    ) external {
        bundleTakes = takes;
        bundleTargetUnits = targetUnits;
        bundleTaker = taker;
        bundleReceiver = receiver;
        useBundleReentry = true;
    }

    function onBuy(
        bytes32 id,
        Market memory market,
        uint256 buyerAssets,
        uint256,
        uint256,
        address buyer,
        bytes memory
    ) external returns (bytes32) {
        require(id == IdLib.toId(market, block.chainid, msg.sender), "wrong id");
        if (!reentered) {
            reentered = true;
            uint256 beforeAttacker = ERC20(market.loanToken).balanceOf(attacker);
            uint256 bundlerBefore = ERC20(market.loanToken).balanceOf(address(bundles));

            if (useBundleReentry) {
                TokenPermit memory noPermit;
                CollateralSupply[] memory supplies = new CollateralSupply[](0);
                try bundles.supplyCollateralAndSellWithUnitsTarget(
                    bundleTargetUnits,
                    0,
                    bundleTaker,
                    bundleReceiver,
                    supplies,
                    bundleTakes,
                    0,
                    address(0)
                ) {} catch {}
            } else if (nestedUnits > 0) {
                ERC20(market.loanToken).transferFrom(buyer, address(this), buyerAssets);
                ERC20(market.loanToken).approve(msg.sender, buyerAssets);
                try midnight.take(nestedOffer, nestedRatifierData, nestedUnits, nestedTaker, nestedTaker, address(0), "")
                {} catch {}
            }

            uint256 afterAttacker = ERC20(market.loanToken).balanceOf(attacker);
            if (afterAttacker > beforeAttacker) {
                stolen = afterAttacker - beforeAttacker;
            }
            assert(bundlerBefore == ERC20(market.loanToken).balanceOf(address(bundles)) || stolen == 0);
        }
        ERC20(market.loanToken).transferFrom(buyer, address(this), buyerAssets);
        ERC20(market.loanToken).approve(msg.sender, buyerAssets);
        return CALLBACK_SUCCESS;
    }
}

/// @notice Sell callback that probes liquidation / flash reentrancy while seller lock is held.
contract ReentrantSellCallback is ISellCallback {
    Midnight public midnight;
    address public seller;
    bool public reentered;
    bool public attemptedLiquidate;
    bool public attemptedFlash;

    function configure(Midnight _midnight, address _seller) external {
        midnight = _midnight;
        seller = _seller;
    }

    function onSell(bytes32 id, Market memory market, uint256, uint256 repaidUnits, uint256, address, address, bytes memory)
        external
        returns (bytes32)
    {
        require(id == IdLib.toId(market, block.chainid, msg.sender), "wrong id");
        if (!reentered) {
            reentered = true;
            attemptedLiquidate = true;
            try midnight.liquidate(market, 0, 0, repaidUnits, seller, false, address(this), address(0), hex"") {} catch {}
            attemptedFlash = true;
            address[] memory tokens = new address[](1);
            tokens[0] = market.loanToken;
            uint256[] memory amounts = new uint256[](1);
            amounts[0] = 1;
            try midnight.flashLoan(tokens, amounts, address(this), hex"") {} catch {}
        }
        return CALLBACK_SUCCESS;
    }
}
