// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IBuyCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market} from "../../../src/interfaces/IMidnight.sol";
import {MidnightBundles} from "../../../src/periphery/MidnightBundles.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";
import {IdLib} from "../../../src/libraries/IdLib.sol";

/// @notice Funded buy-callback that pulls from the maker before paying Midnight.
contract BundleReentrantAttacker is IBuyCallback {
    MidnightBundles public targetBundler;
    address public beneficiary;
    bool public attemptedReentry;
    uint256 public observedBundlerBalance;
    uint256 public extracted;

    function configure(MidnightBundles _bundler, address _beneficiary) external {
        targetBundler = _bundler;
        beneficiary = _beneficiary;
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
        attemptedReentry = true;
        observedBundlerBalance = ERC20(market.loanToken).balanceOf(address(targetBundler));

        uint256 bal = observedBundlerBalance;
        if (bal > 0) {
            try ERC20(market.loanToken).transferFrom(address(targetBundler), beneficiary, bal) {
                extracted = bal;
            } catch {}
        }

        ERC20(market.loanToken).transferFrom(buyer, address(this), buyerAssets);
        ERC20(market.loanToken).approve(msg.sender, buyerAssets);
        return CALLBACK_SUCCESS;
    }
}
