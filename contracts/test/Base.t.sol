// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Currency} from "v4-core/src/types/Currency.sol";

import {Deployers} from "../script/Deployers.s.sol";

contract BaseTest is Test, Deployers {
    function deployArtifactsAndLabel() internal {
        /////////////////////////////// 
        /// 部署Permit2      //////////
        /// 部署PoolManager ////////// 
        /// 部署PositionManager //////
        /// 部署UniSwapV4 Router ///// 
        ///////////////////////////// 
        deployArtifacts();

        vm.label(address(permit2), "Permit2");
        vm.label(address(poolManager), "V4PoolManager");
        vm.label(address(positionManager), "V4PositionManager");
        vm.label(address(swapRouter), "V4SwapRouter");
    }
    /**
     * 部署货币对
     * @return currency0 token0
     * @return currency1 token1
     */
    function deployCurrencyPair() internal virtual override returns (Currency currency0, Currency currency1) {
        (currency0, currency1) = super.deployCurrencyPair();

        vm.label(Currency.unwrap(currency0), "Currency0");
        vm.label(Currency.unwrap(currency1), "Currency1");
    }

    function _etch(address target, bytes memory bytecode) internal override {
        vm.etch(target, bytecode);
    }
}