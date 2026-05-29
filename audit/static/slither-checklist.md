**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [arbitrary-send-erc20](#arbitrary-send-erc20) (1 results) (High)
 - [divide-before-multiply](#divide-before-multiply) (3 results) (Medium)
 - [incorrect-equality](#incorrect-equality) (4 results) (Medium)
 - [uninitialized-local](#uninitialized-local) (13 results) (Medium)
 - [unused-return](#unused-return) (6 results) (Medium)
 - [shadowing-local](#shadowing-local) (10 results) (Low)
 - [missing-zero-check](#missing-zero-check) (8 results) (Low)
 - [calls-loop](#calls-loop) (26 results) (Low)
 - [timestamp](#timestamp) (13 results) (Low)
 - [assembly](#assembly) (13 results) (Informational)
 - [pragma](#pragma) (1 results) (Informational)
 - [cyclomatic-complexity](#cyclomatic-complexity) (2 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (4 results) (Informational)
 - [naming-convention](#naming-convention) (11 results) (Informational)
## arbitrary-send-erc20
Impact: High
Confidence: High
 - [ ] ID-0
[Midnight.flashLoan(address[],uint256[],address,bytes)](src/Midnight.sol#L737-L752) uses arbitrary from in transferFrom: [SafeTransferLib.safeTransferFrom(tokens[i_scope_0],callback,address(this),assets[i_scope_0])](src/Midnight.sol#L750)

src/Midnight.sol#L737-L752


## divide-before-multiply
Impact: Medium
Confidence: Medium
 - [ ] ID-1
[TickLib.wExp(int256)](src/libraries/TickLib.sol#L23-L42) performs a multiplication on the result of a division:
	- [secondTerm = r * r / (2 * 1e18)](src/libraries/TickLib.sol#L33)
	- [thirdTerm = secondTerm * r / (3 * 1e18)](src/libraries/TickLib.sol#L34)

src/libraries/TickLib.sol#L23-L42


 - [ ] ID-2
[TickLib.wExp(int256)](src/libraries/TickLib.sol#L23-L42) performs a multiplication on the result of a division:
	- [q = (x + offset) / ln2](src/libraries/TickLib.sol#L31)
	- [r = x - q * ln2](src/libraries/TickLib.sol#L32)

src/libraries/TickLib.sol#L23-L42


 - [ ] ID-3
[TickLib.priceToTick(uint256,uint256)](src/libraries/TickLib.sol#L56-L68) performs a multiplication on the result of a division:
	- [(low + spacing - 1) / spacing * spacing](src/libraries/TickLib.sol#L67)

src/libraries/TickLib.sol#L56-L68


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-4
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes)](src/Midnight.sol#L581-L720) uses a dangerous strict equality:
	- [newCollateral == 0 && seizedAssets > 0](src/Midnight.sol#L672)

src/Midnight.sol#L581-L720


 - [ ] ID-5
[Midnight.take(Offer,bytes,uint256,address,address,address,bytes)](src/Midnight.sol#L337-L479) uses a dangerous strict equality:
	- [require(bool,error)(IBuyCallback(buyerCallback).onBuy(id,offer.market,buyerAssets,units,buyerPendingFeeIncrease,buyer,buyerCallbackData) == CALLBACK_SUCCESS,revert WrongBuyCallbackReturnValue()())](src/Midnight.sol#L447-L452)

src/Midnight.sol#L337-L479


 - [ ] ID-6
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes)](src/Midnight.sol#L581-L720) uses a dangerous strict equality:
	- [require(bool,error)(ILiquidateCallback(callback).onLiquidate(msg.sender,id,market,collateralIndex,seizedAssets,repaidUnits,borrower,receiver,data,badDebt) == CALLBACK_SUCCESS,revert WrongLiquidateCallbackReturnValue()())](src/Midnight.sol#L699-L714)

src/Midnight.sol#L581-L720


 - [ ] ID-7
[Midnight.take(Offer,bytes,uint256,address,address,address,bytes)](src/Midnight.sol#L337-L479) uses a dangerous strict equality:
	- [require(bool,error)(ISellCallback(sellerCallback).onSell(id,offer.market,sellerAssets,units,sellerPendingFeeDecrease,seller,receiver,sellerCallbackData) == CALLBACK_SUCCESS,revert WrongSellCallbackReturnValue()())](src/Midnight.sol#L460-L473)

src/Midnight.sol#L337-L479


## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-8
[MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address).filledSellerAssets](src/periphery/MidnightBundles.sol#L143) is a local variable never initialized

src/periphery/MidnightBundles.sol#L143


 - [ ] ID-9
[Midnight.touchMarket(Market).previousCollateralToken](src/Midnight.sol#L761) is a local variable never initialized

src/Midnight.sol#L761


 - [ ] ID-10
[MidnightBundles.buyWithUnitsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address).filledUnits](src/periphery/MidnightBundles.sol#L69) is a local variable never initialized

src/periphery/MidnightBundles.sol#L69


 - [ ] ID-11
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes).liquidatedCollatPrice](src/Midnight.sol#L603) is a local variable never initialized

src/Midnight.sol#L603


 - [ ] ID-12
[Midnight.isHealthy(Market,bytes32,address).maxDebt](src/Midnight.sol#L947) is a local variable never initialized

src/Midnight.sol#L947


 - [ ] ID-13
[Midnight.withdraw(Market,uint256,address,address).pendingFeeDecrease](src/Midnight.sol#L488) is a local variable never initialized

src/Midnight.sol#L488


 - [ ] ID-14
[MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address).filledUnits](src/periphery/MidnightBundles.sol#L142) is a local variable never initialized

src/periphery/MidnightBundles.sol#L142


 - [ ] ID-15
[MidnightBundles.buyWithUnitsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address).filledBuyerAssets](src/periphery/MidnightBundles.sol#L70) is a local variable never initialized

src/periphery/MidnightBundles.sol#L70


 - [ ] ID-16
[MidnightBundles.buyWithAssetsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address).filledUnits](src/periphery/MidnightBundles.sol#L203) is a local variable never initialized

src/periphery/MidnightBundles.sol#L203


 - [ ] ID-17
[MidnightBundles.buyWithAssetsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address).filledBuyerAssets](src/periphery/MidnightBundles.sol#L204) is a local variable never initialized

src/periphery/MidnightBundles.sol#L204


 - [ ] ID-18
[MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address).filledUnits](src/periphery/MidnightBundles.sol#L280) is a local variable never initialized

src/periphery/MidnightBundles.sol#L280


 - [ ] ID-19
[MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address).filledSellerAssets](src/periphery/MidnightBundles.sol#L281) is a local variable never initialized

src/periphery/MidnightBundles.sol#L281


 - [ ] ID-20
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes).maxDebt](src/Midnight.sol#L602) is a local variable never initialized

src/Midnight.sol#L602


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-21
[MidnightBundles.buyWithAssetsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L180-L240) ignores return value by [(resBuyerAssets) = IMidnight(MIDNIGHT).take(takes[i].offer,takes[i].ratifierData,unitsToTake,taker,address(0),address(0),)](src/periphery/MidnightBundles.sol#L215-L221)

src/periphery/MidnightBundles.sol#L180-L240


 - [ ] ID-22
[Midnight.touchMarket(Market)](src/Midnight.sol#L755-L791) ignores return value by [IdLib.storeInCode(market,INITIAL_CHAIN_ID)](src/Midnight.sol#L786)

src/Midnight.sol#L755-L791


 - [ ] ID-23
[MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L117-L169) ignores return value by [(resSellerAssets) = IMidnight(MIDNIGHT).take(takes[i_scope_0].offer,takes[i_scope_0].ratifierData,unitsToTake,taker,address(this),address(0),)](src/periphery/MidnightBundles.sol#L152-L160)

src/periphery/MidnightBundles.sol#L117-L169


 - [ ] ID-24
[MidnightBundles.buyWithUnitsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L49-L105) ignores return value by [(resBuyerAssets) = IMidnight(MIDNIGHT).take(takes[i].offer,takes[i].ratifierData,unitsToTake,taker,address(0),address(0),)](src/periphery/MidnightBundles.sol#L79-L85)

src/periphery/MidnightBundles.sol#L49-L105


 - [ ] ID-25
[MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L252-L308) ignores return value by [(resSellerAssets) = IMidnight(MIDNIGHT).take(takes[i_scope_0].offer,takes[i_scope_0].ratifierData,unitsToTake,taker,address(this),address(0),)](src/periphery/MidnightBundles.sol#L292-L300)

src/periphery/MidnightBundles.sol#L252-L308


 - [ ] ID-26
[Midnight.take(Offer,bytes,uint256,address,address,address,bytes)](src/Midnight.sol#L337-L479) ignores return value by [UtilsLib.tExchange(LIQUIDATION_LOCK_SLOT,id,seller,false)](src/Midnight.sol#L475)

src/Midnight.sol#L337-L479


## shadowing-local
Impact: Low
Confidence: High
 - [ ] ID-27
[IMidnight.marketState(bytes32).continuousFee](src/interfaces/IMidnight.sol#L121) shadows:
	- [IMidnight.continuousFee(bytes32)](src/interfaces/IMidnight.sol#L177) (function)

src/interfaces/IMidnight.sol#L121


 - [ ] ID-28
[IMidnight.marketState(bytes32).tickSpacing](src/interfaces/IMidnight.sol#L121) shadows:
	- [IMidnight.tickSpacing(bytes32)](src/interfaces/IMidnight.sol#L174) (function)

src/interfaces/IMidnight.sol#L121


 - [ ] ID-29
[IMidnight.position(bytes32,address).pendingFee](src/interfaces/IMidnight.sol#L120) shadows:
	- [IMidnight.pendingFee(bytes32,address)](src/interfaces/IMidnight.sol#L179) (function)

src/interfaces/IMidnight.sol#L120


 - [ ] ID-30
[IMidnight.marketState(bytes32).lossFactor](src/interfaces/IMidnight.sol#L121) shadows:
	- [IMidnight.lossFactor(bytes32)](src/interfaces/IMidnight.sol#L173) (function)

src/interfaces/IMidnight.sol#L121


 - [ ] ID-31
[IMidnight.marketState(bytes32).totalUnits](src/interfaces/IMidnight.sol#L121) shadows:
	- [IMidnight.totalUnits(bytes32)](src/interfaces/IMidnight.sol#L172) (function)

src/interfaces/IMidnight.sol#L121


 - [ ] ID-32
[IMidnight.position(bytes32,address).collateralBitmap](src/interfaces/IMidnight.sol#L120) shadows:
	- [IMidnight.collateralBitmap(bytes32,address)](src/interfaces/IMidnight.sol#L166) (function)

src/interfaces/IMidnight.sol#L120


 - [ ] ID-33
[IMidnight.marketState(bytes32).withdrawable](src/interfaces/IMidnight.sol#L121) shadows:
	- [IMidnight.withdrawable(bytes32)](src/interfaces/IMidnight.sol#L175) (function)

src/interfaces/IMidnight.sol#L121


 - [ ] ID-34
[IMidnight.position(bytes32,address).lastLossFactor](src/interfaces/IMidnight.sol#L120) shadows:
	- [IMidnight.lastLossFactor(bytes32,address)](src/interfaces/IMidnight.sol#L165) (function)

src/interfaces/IMidnight.sol#L120


 - [ ] ID-35
[IMidnight.position(bytes32,address).lastAccrual](src/interfaces/IMidnight.sol#L120) shadows:
	- [IMidnight.lastAccrual(bytes32,address)](src/interfaces/IMidnight.sol#L180) (function)

src/interfaces/IMidnight.sol#L120


 - [ ] ID-36
[IMidnight.marketState(bytes32).continuousFeeCredit](src/interfaces/IMidnight.sol#L121) shadows:
	- [IMidnight.continuousFeeCredit(bytes32)](src/interfaces/IMidnight.sol#L178) (function)

src/interfaces/IMidnight.sol#L121


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-37
[MidnightBundles.constructor(address)._midnight](src/periphery/MidnightBundles.sol#L33) lacks a zero-check on :
		- [MIDNIGHT = _midnight](src/periphery/MidnightBundles.sol#L34)

src/periphery/MidnightBundles.sol#L33


 - [ ] ID-38
[EcrecoverAuthorizer.constructor(address)._midnight](src/periphery/EcrecoverAuthorizer.sol#L20) lacks a zero-check on :
		- [MIDNIGHT = _midnight](src/periphery/EcrecoverAuthorizer.sol#L21)

src/periphery/EcrecoverAuthorizer.sol#L20


 - [ ] ID-39
[SetterRatifier.constructor(address)._midnight](src/ratifiers/SetterRatifier.sol#L20) lacks a zero-check on :
		- [MIDNIGHT = _midnight](src/ratifiers/SetterRatifier.sol#L21)

src/ratifiers/SetterRatifier.sol#L20


 - [ ] ID-40
[Midnight.setTickSpacingSetter(address).newTickSpacingSetter](src/Midnight.sol#L242) lacks a zero-check on :
		- [tickSpacingSetter = newTickSpacingSetter](src/Midnight.sol#L244)

src/Midnight.sol#L242


 - [ ] ID-41
[Midnight.setRoleSetter(address).newRoleSetter](src/Midnight.sol#L224) lacks a zero-check on :
		- [roleSetter = newRoleSetter](src/Midnight.sol#L226)

src/Midnight.sol#L224


 - [ ] ID-42
[Midnight.setFeeSetter(address).newFeeSetter](src/Midnight.sol#L230) lacks a zero-check on :
		- [feeSetter = newFeeSetter](src/Midnight.sol#L232)

src/Midnight.sol#L230


 - [ ] ID-43
[EcrecoverRatifier.constructor(address)._midnight](src/ratifiers/EcrecoverRatifier.sol#L23) lacks a zero-check on :
		- [MIDNIGHT = _midnight](src/ratifiers/EcrecoverRatifier.sol#L24)

src/ratifiers/EcrecoverRatifier.sol#L23


 - [ ] ID-44
[Midnight.setFeeClaimer(address).newFeeClaimer](src/Midnight.sol#L236) lacks a zero-check on :
		- [feeClaimer = newFeeClaimer](src/Midnight.sol#L238)

src/Midnight.sol#L236


## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-45
[MidnightBundles.pullToken(address,address,uint256,TokenPermit)](src/periphery/MidnightBundles.sol#L378-L398) has external calls inside a loop: [IPermit2(PERMIT2).permitTransferFrom(IPermit2.PermitTransferFrom(IPermit2.TokenPermissions(token,amount),nonce,deadline_scope_0),IPermit2.SignatureTransferDetails(address(this),amount),from,signature)](src/periphery/MidnightBundles.sol#L388-L394)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)

src/periphery/MidnightBundles.sol#L378-L398


 - [ ] ID-46
[MidnightBundles.pullToken(address,address,uint256,TokenPermit)](src/periphery/MidnightBundles.sol#L378-L398) has external calls inside a loop: [IERC20Permit(token).permit(from,address(this),amount,deadline,v,r,s)](src/periphery/MidnightBundles.sol#L383)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)

src/periphery/MidnightBundles.sol#L378-L398


 - [ ] ID-47
[MidnightBundles.buyWithAssetsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L180-L240) has external calls inside a loop: [IMidnight(MIDNIGHT).withdrawCollateral(market,collateralWithdrawals[i_scope_0].collateralIndex,collateralWithdrawals[i_scope_0].assets,taker,collateralReceiver)](src/periphery/MidnightBundles.sol#L229-L236)

src/periphery/MidnightBundles.sol#L180-L240


 - [ ] ID-48
[MidnightBundles.safeApprove(address,address,uint256)](src/periphery/MidnightBundles.sol#L358-L366) has external calls inside a loop: [(success,returndata) = token.call(abi.encodeCall(IERC20.approve,(spender,value)))](src/periphery/MidnightBundles.sol#L359)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)
		MidnightBundles.forceApproveMax(address,address)

src/periphery/MidnightBundles.sol#L358-L366


 - [ ] ID-49
[MidnightBundles.forceApproveMax(address,address)](src/periphery/MidnightBundles.sol#L371-L375) has external calls inside a loop: [IERC20(token).allowance(address(this),spender) >= type()(uint96).max / 2](src/periphery/MidnightBundles.sol#L372)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)

src/periphery/MidnightBundles.sol#L371-L375


 - [ ] ID-50
[MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L252-L308) has external calls inside a loop: [(resSellerAssets) = IMidnight(MIDNIGHT).take(takes[i_scope_0].offer,takes[i_scope_0].ratifierData,unitsToTake,taker,address(this),address(0),)](src/periphery/MidnightBundles.sol#L292-L300)

src/periphery/MidnightBundles.sol#L252-L308


 - [ ] ID-51
[MidnightBundles.pullToken(address,address,uint256,TokenPermit)](src/periphery/MidnightBundles.sol#L378-L398) has external calls inside a loop: [IPermit2(PERMIT2).permitTransferFrom(IPermit2.PermitTransferFrom(IPermit2.TokenPermissions(token,amount),nonce,deadline_scope_0),IPermit2.SignatureTransferDetails(address(this),amount),from,signature)](src/periphery/MidnightBundles.sol#L388-L394)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)

src/periphery/MidnightBundles.sol#L378-L398


 - [ ] ID-52
[MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L117-L169) has external calls inside a loop: [require(bool,error)(IMidnight(MIDNIGHT).toId(takes[i_scope_0].offer.market) == id,revert InconsistentMarket()())](src/periphery/MidnightBundles.sol#L146)

src/periphery/MidnightBundles.sol#L117-L169


 - [ ] ID-53
[MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L252-L308) has external calls inside a loop: [require(bool,error)(IMidnight(MIDNIGHT).toId(takes[i_scope_0].offer.market) == id,revert InconsistentMarket()())](src/periphery/MidnightBundles.sol#L284)

src/periphery/MidnightBundles.sol#L252-L308


 - [ ] ID-54
[MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L252-L308) has external calls inside a loop: [IMidnight(MIDNIGHT).supplyCollateral(market,collateralSupplies[i].collateralIndex,collateralSupplies[i].assets,taker)](src/periphery/MidnightBundles.sol#L273-L274)

src/periphery/MidnightBundles.sol#L252-L308


 - [ ] ID-55
[MidnightBundles.forceApproveMax(address,address)](src/periphery/MidnightBundles.sol#L371-L375) has external calls inside a loop: [IERC20(token).allowance(address(this),spender) >= type()(uint96).max / 2](src/periphery/MidnightBundles.sol#L372)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)

src/periphery/MidnightBundles.sol#L371-L375


 - [ ] ID-56
[Midnight.isHealthy(Market,bytes32,address)](src/Midnight.sol#L944-L960) has external calls inside a loop: [price = IOracle(collateralParam.oracle).price()](src/Midnight.sol#L953)
	Calls stack containing the loop:
		Midnight.withdrawCollateral(Market,uint256,uint256,address,address)

src/Midnight.sol#L944-L960


 - [ ] ID-57
[MidnightBundles.pullToken(address,address,uint256,TokenPermit)](src/periphery/MidnightBundles.sol#L378-L398) has external calls inside a loop: [IERC20Permit(token).permit(from,address(this),amount,deadline,v,r,s)](src/periphery/MidnightBundles.sol#L383)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithAssetsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)

src/periphery/MidnightBundles.sol#L378-L398


 - [ ] ID-58
[MidnightBundles.buyWithUnitsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L49-L105) has external calls inside a loop: [(resBuyerAssets) = IMidnight(MIDNIGHT).take(takes[i].offer,takes[i].ratifierData,unitsToTake,taker,address(0),address(0),)](src/periphery/MidnightBundles.sol#L79-L85)

src/periphery/MidnightBundles.sol#L49-L105


 - [ ] ID-59
[MidnightBundles.repayAndWithdrawCollateral(Market,uint256,address,TokenPermit,CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L315-L348) has external calls inside a loop: [IMidnight(MIDNIGHT).withdrawCollateral(market,collateralWithdrawals[i].collateralIndex,collateralWithdrawals[i].assets,onBehalf,collateralReceiver)](src/periphery/MidnightBundles.sol#L337-L344)

src/periphery/MidnightBundles.sol#L315-L348


 - [ ] ID-60
[MidnightBundles.buyWithAssetsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L180-L240) has external calls inside a loop: [require(bool,error)(IMidnight(MIDNIGHT).toId(takes[i].offer.market) == id,revert InconsistentMarket()())](src/periphery/MidnightBundles.sol#L207)

src/periphery/MidnightBundles.sol#L180-L240


 - [ ] ID-61
[MidnightBundles.buyWithUnitsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L49-L105) has external calls inside a loop: [IMidnight(MIDNIGHT).withdrawCollateral(market,collateralWithdrawals[i_scope_0].collateralIndex,collateralWithdrawals[i_scope_0].assets,taker,collateralReceiver)](src/periphery/MidnightBundles.sol#L92-L99)

src/periphery/MidnightBundles.sol#L49-L105


 - [ ] ID-62
[MidnightBundles.buyWithAssetsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L180-L240) has external calls inside a loop: [(resBuyerAssets) = IMidnight(MIDNIGHT).take(takes[i].offer,takes[i].ratifierData,unitsToTake,taker,address(0),address(0),)](src/periphery/MidnightBundles.sol#L215-L221)

src/periphery/MidnightBundles.sol#L180-L240


 - [ ] ID-63
[Midnight.isHealthy(Market,bytes32,address)](src/Midnight.sol#L944-L960) has external calls inside a loop: [price = IOracle(collateralParam.oracle).price()](src/Midnight.sol#L953)

src/Midnight.sol#L944-L960


 - [ ] ID-64
[Midnight.multicall(bytes[])](src/Midnight.sol#L211-L220) has external calls inside a loop: [(success,returnData) = address(this).delegatecall(calls[i])](src/Midnight.sol#L213)

src/Midnight.sol#L211-L220


 - [ ] ID-65
[MidnightBundles.safeApprove(address,address,uint256)](src/periphery/MidnightBundles.sol#L358-L366) has external calls inside a loop: [(success,returndata) = token.call(abi.encodeCall(IERC20.approve,(spender,value)))](src/periphery/MidnightBundles.sol#L359)
	Calls stack containing the loop:
		MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)
		MidnightBundles.forceApproveMax(address,address)

src/periphery/MidnightBundles.sol#L358-L366


 - [ ] ID-66
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes)](src/Midnight.sol#L581-L720) has external calls inside a loop: [price = IOracle(_collateralParam.oracle).price()](src/Midnight.sol#L610)

src/Midnight.sol#L581-L720


 - [ ] ID-67
[MidnightBundles.buyWithUnitsTargetAndWithdrawCollateral(uint256,uint256,address,TokenPermit,Take[],CollateralWithdrawal[],address,uint256,address)](src/periphery/MidnightBundles.sol#L49-L105) has external calls inside a loop: [require(bool,error)(IMidnight(MIDNIGHT).toId(takes[i].offer.market) == id,revert InconsistentMarket()())](src/periphery/MidnightBundles.sol#L73)

src/periphery/MidnightBundles.sol#L49-L105


 - [ ] ID-68
[Midnight.isHealthy(Market,bytes32,address)](src/Midnight.sol#L944-L960) has external calls inside a loop: [price = IOracle(collateralParam.oracle).price()](src/Midnight.sol#L953)
	Calls stack containing the loop:
		Midnight.take(Offer,bytes,uint256,address,address,address,bytes)

src/Midnight.sol#L944-L960


 - [ ] ID-69
[MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L117-L169) has external calls inside a loop: [IMidnight(MIDNIGHT).supplyCollateral(market,collateralSupplies[i].collateralIndex,collateralSupplies[i].assets,taker)](src/periphery/MidnightBundles.sol#L138-L139)

src/periphery/MidnightBundles.sol#L117-L169


 - [ ] ID-70
[MidnightBundles.supplyCollateralAndSellWithUnitsTarget(uint256,uint256,address,address,CollateralSupply[],Take[],uint256,address)](src/periphery/MidnightBundles.sol#L117-L169) has external calls inside a loop: [(resSellerAssets) = IMidnight(MIDNIGHT).take(takes[i_scope_0].offer,takes[i_scope_0].ratifierData,unitsToTake,taker,address(this),address(0),)](src/periphery/MidnightBundles.sol#L152-L160)

src/periphery/MidnightBundles.sol#L117-L169


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-71
[Midnight.take(Offer,bytes,uint256,address,address,address,bytes)](src/Midnight.sol#L337-L479) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(_marketState.lossFactor < type()(uint128).max,revert MarketLossFactorMaxedOut()())](src/Midnight.sol#L349)
	- [require(bool,error)(offer.tick % _marketState.tickSpacing == 0,revert TickNotAccessible()())](src/Midnight.sol#L351)
	- [require(bool,error)(block.timestamp >= offer.start,revert OfferNotStarted()())](src/Midnight.sol#L352)
	- [require(bool,error)(block.timestamp <= offer.expiry,revert OfferExpired()())](src/Midnight.sol#L353)
	- [require(bool,error)(newConsumed <= offer.maxAssets,revert ConsumedAssets()())](src/Midnight.sol#L369)
	- [require(bool,error)(newConsumed <= offer.maxUnits,revert ConsumedUnits()())](src/Midnight.sol#L372)
	- [hasCredit(id,buyer) || units > buyerPos.debt](src/Midnight.sol#L379)
	- [require(bool,error)(block.timestamp <= offer.market.maturity || sellerDebtIncrease == 0,revert CannotIncreaseDebtPostMaturity()())](src/Midnight.sol#L391)
	- [require(bool,error)(IBuyCallback(buyerCallback).onBuy(id,offer.market,buyerAssets,units,buyerPendingFeeIncrease,buyer,buyerCallbackData) == CALLBACK_SUCCESS,revert WrongBuyCallbackReturnValue()())](src/Midnight.sol#L447-L452)
	- [require(bool,error)(ISellCallback(sellerCallback).onSell(id,offer.market,sellerAssets,units,sellerPendingFeeDecrease,seller,receiver,sellerCallbackData) == CALLBACK_SUCCESS,revert WrongSellCallbackReturnValue()())](src/Midnight.sol#L460-L473)

src/Midnight.sol#L337-L479


 - [ ] ID-72
[Midnight.settlementFee(bytes32,uint256)](src/Midnight.sol#L963-L980) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(_marketState.tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L965)
	- [timeToMaturity >= 31104000](src/Midnight.sol#L967)
	- [timeToMaturity < 86400](src/Midnight.sol#L970-L976)
	- [timeToMaturity < 604800](src/Midnight.sol#L970-L976)
	- [timeToMaturity < 2592000](src/Midnight.sol#L970-L976)
	- [timeToMaturity < 7776000](src/Midnight.sol#L970-L976)
	- [timeToMaturity < 15552000](src/Midnight.sol#L970-L976)

src/Midnight.sol#L963-L980


 - [ ] ID-73
[Midnight.claimContinuousFee(Market,uint256,address)](src/Midnight.sol#L312-L325) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(_marketState.tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L316)

src/Midnight.sol#L312-L325


 - [ ] ID-74
[Midnight.updatePosition(Market,address)](src/Midnight.sol#L823-L827) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(marketState[id].tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L825)

src/Midnight.sol#L823-L827


 - [ ] ID-75
[TakeAmountsLib.buyerAssetsToUnits(address,bytes32,Offer,uint256)](src/periphery/TakeAmountsLib.sol#L17-L30) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(buyerPrice <= WAD,TickLib.PriceGreaterThanOne())](src/periphery/TakeAmountsLib.sol#L28)

src/periphery/TakeAmountsLib.sol#L17-L30


 - [ ] ID-76
[Midnight.toMarket(bytes32)](src/Midnight.sol#L877-L881) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(marketState[id].tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L878)

src/Midnight.sol#L877-L881


 - [ ] ID-77
[Midnight.hasCredit(bytes32,address)](src/Midnight.sol#L853-L855) uses timestamp for comparisons
	Dangerous comparisons:
	- [position[id][user].credit > 0](src/Midnight.sol#L854)

src/Midnight.sol#L853-L855


 - [ ] ID-78
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes)](src/Midnight.sol#L581-L720) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(UtilsLib.atMostOneNonZero(repaidUnits,seizedAssets),revert InconsistentInput()())](src/Midnight.sol#L595)
	- [require(bool,error)(_position.debt > 0,revert NotBorrower()())](src/Midnight.sol#L596)
	- [repaidUnits > 0 || seizedAssets > 0](src/Midnight.sol#L643)
	- [seizedAssets > 0](src/Midnight.sol#L649)
	- [require(bool,error)(repaidUnits <= maxRepaid || _position.collateral[collateralIndex].mulDivDown(liquidatedCollatPrice,ORACLE_PRICE_SCALE).mulDivDown(WAD,lif).zeroFloorSub(maxRepaid) < market.rcfThreshold,revert RecoveryCloseFactorConditionsViolated()())](src/Midnight.sol#L662-L667)
	- [newCollateral == 0 && seizedAssets > 0](src/Midnight.sol#L672)
	- [require(bool,error)(ILiquidateCallback(callback).onLiquidate(msg.sender,id,market,collateralIndex,seizedAssets,repaidUnits,borrower,receiver,data,badDebt) == CALLBACK_SUCCESS,revert WrongLiquidateCallbackReturnValue()())](src/Midnight.sol#L699-L714)
	- [require(bool,error)(! liquidationLocked(id,borrower) && block.timestamp > market.maturity,revert NotLiquidatable()())](src/Midnight.sol#L620-L624)

src/Midnight.sol#L581-L720


 - [ ] ID-79
[Midnight.setMarketTickSpacing(bytes32,uint256)](src/Midnight.sol#L249-L256) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(marketState[id].tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L251)
	- [require(bool,error)(newTickSpacing > 0 && marketState[id].tickSpacing % newTickSpacing == 0,revert InvalidTickSpacing()())](src/Midnight.sol#L252)

src/Midnight.sol#L249-L256


 - [ ] ID-80
[EcrecoverAuthorizer.setIsAuthorized(Authorization,Signature)](src/periphery/EcrecoverAuthorizer.sol#L24-L48) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(block.timestamp <= authorization.deadline,revert Expired()())](src/periphery/EcrecoverAuthorizer.sol#L25)

src/periphery/EcrecoverAuthorizer.sol#L24-L48


 - [ ] ID-81
[Midnight.touchMarket(Market)](src/Midnight.sol#L755-L791) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(market.maturity <= block.timestamp + 100 * 31536000,revert MaturityTooFar()())](src/Midnight.sol#L758)

src/Midnight.sol#L755-L791


 - [ ] ID-82
[Midnight.setMarketSettlementFee(bytes32,uint256,uint256)](src/Midnight.sol#L258-L275) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(_marketState.tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L264)

src/Midnight.sol#L258-L275


 - [ ] ID-83
[Midnight.setMarketContinuousFee(bytes32,uint256)](src/Midnight.sol#L287-L295) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,error)(_marketState.tickSpacing > 0,revert MarketNotCreated()())](src/Midnight.sol#L291)

src/Midnight.sol#L287-L295


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-84
[MidnightBundles.safeApprove(address,address,uint256)](src/periphery/MidnightBundles.sol#L358-L366) uses assembly
	- [INLINE ASM](src/periphery/MidnightBundles.sol#L361-L363)

src/periphery/MidnightBundles.sol#L358-L366


 - [ ] ID-85
[UtilsLib.atMostOneNonZero(uint256,uint256)](src/libraries/UtilsLib.sol#L9-L13) uses assembly
	- [INLINE ASM](src/libraries/UtilsLib.sol#L10-L12)

src/libraries/UtilsLib.sol#L9-L13


 - [ ] ID-86
[HashLib.hashNode(bytes32,bytes32)](src/ratifiers/libraries/HashLib.sol#L67-L73) uses assembly
	- [INLINE ASM](src/ratifiers/libraries/HashLib.sol#L68-L72)

src/ratifiers/libraries/HashLib.sol#L67-L73


 - [ ] ID-87
[UtilsLib.min(uint256,uint256)](src/libraries/UtilsLib.sol#L16-L20) uses assembly
	- [INLINE ASM](src/libraries/UtilsLib.sol#L17-L19)

src/libraries/UtilsLib.sol#L16-L20


 - [ ] ID-88
[UtilsLib.msb(uint128)](src/libraries/UtilsLib.sol#L54-L58) uses assembly
	- [INLINE ASM](src/libraries/UtilsLib.sol#L55-L57)

src/libraries/UtilsLib.sol#L54-L58


 - [ ] ID-89
[HashLib.hashMarket(Market)](src/ratifiers/libraries/HashLib.sol#L89-L115) uses assembly
	- [INLINE ASM](src/ratifiers/libraries/HashLib.sol#L97-L102)

src/ratifiers/libraries/HashLib.sol#L89-L115


 - [ ] ID-90
[SafeTransferLib.safeTransfer(address,address,uint256)](src/libraries/SafeTransferLib.sol#L12-L22) uses assembly
	- [INLINE ASM](src/libraries/SafeTransferLib.sol#L17-L19)

src/libraries/SafeTransferLib.sol#L12-L22


 - [ ] ID-91
[SafeTransferLib.safeTransferFrom(address,address,address,uint256)](src/libraries/SafeTransferLib.sol#L24-L34) uses assembly
	- [INLINE ASM](src/libraries/SafeTransferLib.sol#L29-L31)

src/libraries/SafeTransferLib.sol#L24-L34


 - [ ] ID-92
[Midnight.multicall(bytes[])](src/Midnight.sol#L211-L220) uses assembly
	- [INLINE ASM](src/Midnight.sol#L215-L217)

src/Midnight.sol#L211-L220


 - [ ] ID-93
[IdLib.storeInCode(Market,uint256)](src/libraries/IdLib.sol#L35-L41) uses assembly
	- [INLINE ASM](src/libraries/IdLib.sol#L37-L39)

src/libraries/IdLib.sol#L35-L41


 - [ ] ID-94
[UtilsLib.tGet(uint256,bytes32,address)](src/libraries/UtilsLib.sol#L83-L88) uses assembly
	- [INLINE ASM](src/libraries/UtilsLib.sol#L85-L87)

src/libraries/UtilsLib.sol#L83-L88


 - [ ] ID-95
[UtilsLib.tExchange(uint256,bytes32,address,bool)](src/libraries/UtilsLib.sol#L74-L80) uses assembly
	- [INLINE ASM](src/libraries/UtilsLib.sol#L76-L79)

src/libraries/UtilsLib.sol#L74-L80


 - [ ] ID-96
[UtilsLib.zeroFloorSub(uint256,uint256)](src/libraries/UtilsLib.sol#L22-L26) uses assembly
	- [INLINE ASM](src/libraries/UtilsLib.sol#L23-L25)

src/libraries/UtilsLib.sol#L22-L26


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-97
3 different versions of Solidity are used:
	- Version constraint 0.8.34 is used by:
		-[0.8.34](src/Midnight.sol#L3)
		-[0.8.34](src/periphery/EcrecoverAuthorizer.sol#L3)
		-[0.8.34](src/periphery/MidnightBundles.sol#L3)
		-[0.8.34](src/ratifiers/EcrecoverRatifier.sol#L3)
		-[0.8.34](src/ratifiers/SetterRatifier.sol#L3)
	- Version constraint >=0.5.0 is used by:
		-[>=0.5.0](src/interfaces/ICallbacks.sol#L3)
		-[>=0.5.0](src/interfaces/IERC20.sol#L3)
		-[>=0.5.0](src/interfaces/IGate.sol#L3)
		-[>=0.5.0](src/interfaces/IMidnight.sol#L3)
		-[>=0.5.0](src/interfaces/IOracle.sol#L3)
		-[>=0.5.0](src/interfaces/IRatifier.sol#L3)
		-[>=0.5.0](src/periphery/interfaces/IERC20Permit.sol#L3)
		-[>=0.5.0](src/periphery/interfaces/IEcrecoverAuthorizer.sol#L3)
		-[>=0.5.0](src/periphery/interfaces/IMidnightBundles.sol#L3)
		-[>=0.5.0](src/periphery/interfaces/IPermit2.sol#L3)
	- Version constraint ^0.8.0 is used by:
		-[^0.8.0](src/libraries/ConstantsLib.sol#L3)
		-[^0.8.0](src/libraries/EventsLib.sol#L3)
		-[^0.8.0](src/libraries/IdLib.sol#L3)
		-[^0.8.0](src/libraries/SafeTransferLib.sol#L3)
		-[^0.8.0](src/libraries/TickLib.sol#L3)
		-[^0.8.0](src/libraries/UtilsLib.sol#L3)
		-[^0.8.0](src/periphery/ConsumableUnitsLib.sol#L3)
		-[^0.8.0](src/periphery/TakeAmountsLib.sol#L2)
		-[^0.8.0](src/ratifiers/interfaces/IEcrecoverRatifier.sol#L3)
		-[^0.8.0](src/ratifiers/interfaces/ISetterRatifier.sol#L3)
		-[^0.8.0](src/ratifiers/libraries/HashLib.sol#L3)

src/Midnight.sol#L3


## cyclomatic-complexity
Impact: Informational
Confidence: High
 - [ ] ID-98
[Midnight.take(Offer,bytes,uint256,address,address,address,bytes)](src/Midnight.sol#L337-L479) has a high cyclomatic complexity (21).

src/Midnight.sol#L337-L479


 - [ ] ID-99
[Midnight.liquidate(Market,uint256,uint256,uint256,address,bool,address,address,bytes)](src/Midnight.sol#L581-L720) has a high cyclomatic complexity (14).

src/Midnight.sol#L581-L720


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-100
Version constraint >=0.5.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- DirtyBytesArrayToStorage
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow
	- privateCanBeOverridden
	- SignedArrayStorageCopy
	- ABIEncoderV2StorageArrayWithMultiSlotElement
	- DynamicConstructorArgumentsClippedABIV2
	- UninitializedFunctionPointerInConstructor
	- IncorrectEventSignatureInLibraries
	- ABIEncoderV2PackedStorage.
It is used by:
	- [>=0.5.0](src/interfaces/ICallbacks.sol#L3)
	- [>=0.5.0](src/interfaces/IERC20.sol#L3)
	- [>=0.5.0](src/interfaces/IGate.sol#L3)
	- [>=0.5.0](src/interfaces/IMidnight.sol#L3)
	- [>=0.5.0](src/interfaces/IOracle.sol#L3)
	- [>=0.5.0](src/interfaces/IRatifier.sol#L3)
	- [>=0.5.0](src/periphery/interfaces/IERC20Permit.sol#L3)
	- [>=0.5.0](src/periphery/interfaces/IEcrecoverAuthorizer.sol#L3)
	- [>=0.5.0](src/periphery/interfaces/IMidnightBundles.sol#L3)
	- [>=0.5.0](src/periphery/interfaces/IPermit2.sol#L3)

src/interfaces/ICallbacks.sol#L3


 - [ ] ID-101
Version constraint ^0.8.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
It is used by:
	- [^0.8.0](src/libraries/ConstantsLib.sol#L3)
	- [^0.8.0](src/libraries/EventsLib.sol#L3)
	- [^0.8.0](src/libraries/IdLib.sol#L3)
	- [^0.8.0](src/libraries/SafeTransferLib.sol#L3)
	- [^0.8.0](src/libraries/TickLib.sol#L3)
	- [^0.8.0](src/libraries/UtilsLib.sol#L3)
	- [^0.8.0](src/periphery/ConsumableUnitsLib.sol#L3)
	- [^0.8.0](src/periphery/TakeAmountsLib.sol#L2)
	- [^0.8.0](src/ratifiers/interfaces/IEcrecoverRatifier.sol#L3)
	- [^0.8.0](src/ratifiers/interfaces/ISetterRatifier.sol#L3)
	- [^0.8.0](src/ratifiers/libraries/HashLib.sol#L3)

src/libraries/ConstantsLib.sol#L3


## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-102
Low level call in [MidnightBundles.safeApprove(address,address,uint256)](src/periphery/MidnightBundles.sol#L358-L366):
	- [(success,returndata) = token.call(abi.encodeCall(IERC20.approve,(spender,value)))](src/periphery/MidnightBundles.sol#L359)

src/periphery/MidnightBundles.sol#L358-L366


 - [ ] ID-103
Low level call in [SafeTransferLib.safeTransfer(address,address,uint256)](src/libraries/SafeTransferLib.sol#L12-L22):
	- [(success,returndata) = token.call(abi.encodeCall(IERC20.transfer,(to,value)))](src/libraries/SafeTransferLib.sol#L15)

src/libraries/SafeTransferLib.sol#L12-L22


 - [ ] ID-104
Low level call in [Midnight.multicall(bytes[])](src/Midnight.sol#L211-L220):
	- [(success,returnData) = address(this).delegatecall(calls[i])](src/Midnight.sol#L213)

src/Midnight.sol#L211-L220


 - [ ] ID-105
Low level call in [SafeTransferLib.safeTransferFrom(address,address,address,uint256)](src/libraries/SafeTransferLib.sol#L24-L34):
	- [(success,returndata) = token.call(abi.encodeCall(IERC20.transferFrom,(from,to,value)))](src/libraries/SafeTransferLib.sol#L27)

src/libraries/SafeTransferLib.sol#L24-L34


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-106
Function [ISetterRatifier.MIDNIGHT()](src/ratifiers/interfaces/ISetterRatifier.sol#L23) is not in mixedCase

src/ratifiers/interfaces/ISetterRatifier.sol#L23


 - [ ] ID-107
Function [IMidnightBundles.MIDNIGHT()](src/periphery/interfaces/IMidnightBundles.sol#L49) is not in mixedCase

src/periphery/interfaces/IMidnightBundles.sol#L49


 - [ ] ID-108
Function [IEcrecoverRatifier.MIDNIGHT()](src/ratifiers/interfaces/IEcrecoverRatifier.sol#L31) is not in mixedCase

src/ratifiers/interfaces/IEcrecoverRatifier.sol#L31


 - [ ] ID-109
Variable [MidnightBundles.MIDNIGHT](src/periphery/MidnightBundles.sol#L31) is not in mixedCase

src/periphery/MidnightBundles.sol#L31


 - [ ] ID-110
Variable [SetterRatifier.MIDNIGHT](src/ratifiers/SetterRatifier.sol#L16) is not in mixedCase

src/ratifiers/SetterRatifier.sol#L16


 - [ ] ID-111
Function [IMidnightBundles.PERMIT2()](src/periphery/interfaces/IMidnightBundles.sol#L48) is not in mixedCase

src/periphery/interfaces/IMidnightBundles.sol#L48


 - [ ] ID-112
Function [IMidnight.INITIAL_CHAIN_ID()](src/interfaces/IMidnight.sol#L117) is not in mixedCase

src/interfaces/IMidnight.sol#L117


 - [ ] ID-113
Variable [EcrecoverAuthorizer.MIDNIGHT](src/periphery/EcrecoverAuthorizer.sol#L17) is not in mixedCase

src/periphery/EcrecoverAuthorizer.sol#L17


 - [ ] ID-114
Variable [EcrecoverRatifier.MIDNIGHT](src/ratifiers/EcrecoverRatifier.sol#L19) is not in mixedCase

src/ratifiers/EcrecoverRatifier.sol#L19


 - [ ] ID-115
Function [IEcrecoverAuthorizer.MIDNIGHT()](src/periphery/interfaces/IEcrecoverAuthorizer.sol#L39) is not in mixedCase

src/periphery/interfaces/IEcrecoverAuthorizer.sol#L39


 - [ ] ID-116
Variable [Midnight.INITIAL_CHAIN_ID](src/Midnight.sol#L185) is not in mixedCase

src/Midnight.sol#L185


