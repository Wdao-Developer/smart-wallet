// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test,console2} from "forge-std/Test.sol";
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
         console2.log("chainId is: %s", block.chainid);

        console2.log("Permit2 is: %s", address(permit2));
        console2.log("poolManager is: %s", address(poolManager));
        console2.log("positionManager is: %s", address(positionManager));
        console2.log("swapRouter is: %s", address(swapRouter));

        saveContracts("permit2",address(permit2),block.chainid);
        saveContracts("poolManager",address(poolManager),block.chainid);
        saveContracts("positionManager",address(positionManager),block.chainid);
        saveContracts("swapRouter",address(swapRouter),block.chainid);

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

    function saveContracts(string memory name,address addr,uint256 chainid) internal {
        string memory chainId = vm.toString(chainid);
        string memory json1="key";
        string memory finalJson = vm.serializeAddress(json1, "address", addr);
        string memory dirPath = string.concat(string.concat("deploy_ContractsABIs/", name), "_");
        vm.writeJson(finalJson, string.concat(dirPath, string.concat(chainId, ".json"))); 

    }
    function _etch(address target, bytes memory bytecode) internal override {
        vm.etch(target, bytecode);
    }
}