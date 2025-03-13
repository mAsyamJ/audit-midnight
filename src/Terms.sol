// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "./libraries/Math.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/ITerms.sol";

contract Terms is ITerms {
    /// CONSTANTS ///

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
    bytes32 public constant OFFER_TYPEHASH = keccak256(
        "Offer(bool lend,address offering,uint256 assets,address loanToken,Collateral[] collaterals,uint256 maturity,uint256 price)"
    );
    uint256 public constant WAD = 1 ether;

    /// STORAGE ///

    // Terms.
    mapping(address => mapping(bytes32 => uint256)) public bondOf;
    mapping(address => mapping(bytes32 => uint256)) public debtOf;
    mapping(bytes32 => uint256) public withdrawable;
    mapping(address => mapping(bytes32 => mapping(address => uint256))) public collateralOf;
    // Offers.
    mapping(bytes => uint256) public consumed;

    /// ENTRY-POINTS ///

    /// @dev This function is used for both primary and secondary markets.
    function MATCH(Offer memory buyOffer, Signature memory buySig, Offer memory sellOffer, Signature memory sellSig)
        public
    {
        _checkOffers(buyOffer, buySig, sellOffer, sellSig);

        uint256 amount = Math.min(
            buyOffer.assets - consumed[abi.encode(buyOffer)], sellOffer.assets - consumed[abi.encode(sellOffer)]
        );
        require(amount > 0, "No assets to match");
        address buyer = buyOffer.offering;
        address seller = sellOffer.offering;

        consumed[abi.encode(buyOffer)] += amount;
        consumed[abi.encode(sellOffer)] += amount;

        Term memory term = Term(sellOffer.loanToken, sellOffer.collaterals, sellOffer.maturity);
        bytes32 id = _id(term);

        uint256 repaid = Math.min(debtOf[buyer][id], amount);
        debtOf[buyer][id] -= repaid;
        bondOf[buyer][id] += amount - repaid;

        uint256 withdrawn = Math.min(bondOf[seller][id], amount);
        bondOf[seller][id] -= withdrawn;
        debtOf[seller][id] += amount - withdrawn;

        require(debtOf[buyer][id] == 0 || _isHealthy(term, buyer), "Buyer is unhealthy");
        require(debtOf[seller][id] == 0 || _isHealthy(term, seller), "Seller is unhealthy");

        uint256 sellerScaledPrice = sellOffer.price * amount / sellOffer.assets;
        uint256 buyerScaledPrice = buyOffer.price * amount / buyOffer.assets;

        uint256 rest;
        if (sellerScaledPrice < buyerScaledPrice) {
            rest = buyerScaledPrice - sellerScaledPrice;
        } else {
            rest = 0;
        }

        IERC20(buyOffer.loanToken).transferFrom(buyer, seller, sellerScaledPrice);
        if (rest > 0) {
            IERC20(buyOffer.loanToken).transferFrom(buyer, msg.sender, rest);
        }
    }

    /// @dev Will revert if there is no withdrawable funds.
    function withdrawBond(Term memory term, uint256 amount, address onBehalf) external {
        bytes32 id = _id(term);

        bondOf[onBehalf][id] -= amount;
        withdrawable[id] -= amount;

        IERC20(term.loanToken).transfer(msg.sender, amount);
    }

    function repayDebt(Term memory term, uint256 amount, address onBehalf) external {
        bytes32 id = _id(term);

        debtOf[onBehalf][id] -= amount;
        withdrawable[id] += amount;

        IERC20(term.loanToken).transferFrom(msg.sender, address(this), amount);
    }

    function supplyCollateral(Term memory term, address collateral, uint256 amount, address onBehalf) external {
        collateralOf[onBehalf][_id(term)][collateral] += amount;
        IERC20(collateral).transferFrom(msg.sender, address(this), amount);
    }

    function withdrawCollateral(Term memory term, address collateral, uint256 amount, address onBehalf) external {
        collateralOf[onBehalf][_id(term)][collateral] -= amount;

        require(_isHealthy(term, onBehalf), "Unhealthy borrower");

        IERC20(collateral).transfer(msg.sender, amount);
    }

    /// @notice Liquidates the given collections `repaidAmounts` of debt asset
    /// by colleral or seize the given `seizedAssets` of collateral on the given
    /// `term` of the given `borrower`,
    /// @dev Either `seizedAssets` or `repaidAmounts` should be empty.
    /// @param term The term of the bond.
    /// @param borrower The debtor of the loan.
    /// @param seizedAssets A collection of amounts of collateral to seize and the collateral index to seize..
    /// @param repaidShares A collection of amounts of loan asset to repay and the collateral index to seize.
    /// @param data Arbitrary data to pass to the `onMorphoLiquidate` callback. Pass empty data if not needed.
    /// @return The list of amounts of assets seized by collateral index.
    /// @return The list of amounts of assets repaid by collateral index.
    function liquidate(Term memory term, Limit[] memory seizedAssets, Limit[] memory repaidAmounts, address borrower)
        external
        returns (Limit[] memory, Limit[] memory)
    {
        require(
            seizedAssets.length <= term.collaterals.length, "Cannot seize more assets than the the supplied collaterals"
        );
        // TODO check that either the user is either seized or repaying amounts.
        require(seizedAssets.length == repaidAmounts.length, "Incoherent limit arrays");
        require(!_isHealthy(term, borrower), "Healthy borrower");

        bytes32 id = _id(term);

        // Over approximation
        uint256 liquidationIncentiveFactor = 1.15e18;

        uint256 totalRepaid;
        for (uint256 i = 0; i < repaidAmounts.length; i++) {
            totalRepaid += repaidAmounts[i].amount;
        }

        // Compute the repaid and seized amounts by collateral index.
        if (totalRepaid > 0) {
            for (uint256 i = 0; i < repaidAmounts.length; i++) {
                Limit memory l;
                uint256 collateralPrice = IOracle(term.collaterals[repaidAmounts[i].collateralIndex].oracle).price();
                l.collateralIndex = repaidAmounts[i].collateralIndex;
                l.amount = (repaidAmounts[i].amount * liquidationIncentiveFactor / WAD) / collateralPrice;
                seizedAssets[i] = l;
            }
        } else {
            for (uint256 i = 0; i < seizedAssets.length; i++) {
                Limit memory l;
                uint256 collateralPrice = IOracle(term.collaterals[seizedAssets[i].collateralIndex].oracle).price();
                uint256 seizedAssetsQuoted = seizedAssets[i].amount * collateralPrice;
                l.collateralIndex = repaidAmounts[i].collateralIndex;
                l.amount = seizedAssetsQuoted * WAD / liquidationIncentiveFactor;
                totalRepaid += l.amount;
                repaidAmounts[i] = l;
            }
        }

        debtOf[borrower][id] -= totalRepaid;
        withdrawable[id] += totalRepaid;

        // Transfer the repaid amount.
        IERC20(term.loanToken).transferFrom(msg.sender, address(this), totalRepaid);

        // Transfer the seized collaterals.
        for (uint256 i = 0; i < seizedAssets.length; i++) {
            Limit memory l = seizedAssets[i];
            address collateral = term.collaterals[l.collateralIndex].token;
            collateralOf[borrower][_id(term)][collateral] -= l.amount;
            IERC20(collateral).transfer(msg.sender, l.amount);
        }

        // Realize bad debt.
        uint256 totalCollateralQuoted;
        for (uint256 i = 0; i < term.collaterals.length; i++) {
            uint256 price = IOracle(term.collaterals[i].oracle).price();
            uint256 collateralQuoted = collateralOf[borrower][id][term.collaterals[i].token] * price / WAD;
            totalCollateralQuoted += collateralQuoted;
        }
        if (totalCollateralQuoted == 0) {
            uint256 badDebt = debtOf[borrower][id];
            withdrawable[id] -= badDebt;
            debtOf[borrower][id] = 0;
        }
        return (seizedAssets, repaidAmounts);
    }

    /// INTERNAL ///

    function _id(Term memory term) public pure returns (bytes32) {
        return keccak256(abi.encode(term));
    }

    function _checkOffers(
        Offer memory buyOffer,
        Signature memory buySig,
        Offer memory sellOffer,
        Signature memory sellSig
    ) internal view {
        // Check consistency.

        require(buyOffer.buy && !sellOffer.buy, "Inconsistent lend flags");
        require(buyOffer.maturity > block.timestamp, "Buy offer has expired");
        _checkSignature(buyOffer, buySig);
        _checkSignature(sellOffer, sellSig);

        // Check compatibility.

        require(buyOffer.offering != sellOffer.offering, "Same offering");
        require(buyOffer.loanToken == sellOffer.loanToken, "Loan tokens do not match");
        for (uint256 i = 0; i < sellOffer.collaterals.length; i++) {
            uint256 j;
            // Relies on the fact that the collaterals are sorted.
            // Note that we actually never check that.
            // If they are not, the match could fail.
            while (
                bytes20(sellOffer.collaterals[i].token) < bytes20(buyOffer.collaterals[j].token)
                    && j++ < buyOffer.collaterals.length
            ) {}
            require(sellOffer.collaterals[i].token == buyOffer.collaterals[j].token, "Collaterals tokens do not match");
            require(sellOffer.collaterals[i].lltv <= buyOffer.collaterals[j].lltv, "LLTVs do not match");
            require(sellOffer.collaterals[i].oracle == buyOffer.collaterals[j].oracle, "Oracles do not match");
        }
        require(buyOffer.maturity == sellOffer.maturity, "Maturities do not match");
        require(buyOffer.price >= sellOffer.price, "Buy offer price is less than sell offer price");
    }

    function _checkSignature(Offer memory offer, Signature memory signature) internal view {
        bytes32 hashStruct = keccak256(abi.encode(OFFER_TYPEHASH, offer));
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, block.chainid, address(this)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, hashStruct));
        address signatory = ecrecover(digest, signature.v, signature.r, signature.s);

        require(signatory != address(0) && offer.offering == signatory, "Invalid signature");
    }

    function _isHealthy(Term memory term, address borrower) internal view returns (bool) {
        if (term.maturity < block.timestamp) {
            return false;
        } else {
            bytes32 id = _id(Term(term.loanToken, term.collaterals, term.maturity));

            uint256 maxDebt;
            for (uint256 i = 0; i < term.collaterals.length; i++) {
                uint256 price = IOracle(term.collaterals[i].oracle).price();
                uint256 collateralQuoted = collateralOf[borrower][id][term.collaterals[i].token] * price / WAD;
                maxDebt += collateralQuoted * term.collaterals[i].lltv / WAD;
            }

            return debtOf[borrower][id] <= maxDebt;
        }
    }
}
