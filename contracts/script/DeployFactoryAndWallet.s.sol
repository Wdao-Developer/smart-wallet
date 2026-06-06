// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {Test, console2} from "forge-std/Test.sol";
//import {BaseScript} from "./BaseScript.sol";
import {AddressConstants} from "hookmate/constants/AddressConstants.sol";

import {WalletFactory} from "../src/WalletFactory.sol";
import {ProxyWallet} from "../src/ProxyWallet.sol";

contract DeployFactoryAndWallet is Script {
    function run() public {
        vm.startBroadcast();
        WalletFactory factory = new WalletFactory();
        ProxyWallet walletImpl = new ProxyWallet(
            AddressConstants.getV4SwapRouterAddress(block.chainid),
            AddressConstants.getPoolManagerAddress(block.chainid),
            AddressConstants.getPermit2Address(),
            AddressConstants.getPositionManagerAddress(block.chainid),
            address(factory)
        );
        //saveContracts("WalletFactory",address(factory));
        //saveContracts("ProxyWallet",address(walletImpl));
        vm.stopBroadcast();

        console2.log("WalletFactory deployed at:", address(factory));
        console2.log("ProxyWallet deployed at:", address(walletImpl));
    }

    // function saveContracts(string memory name,address addr) internal {
    //     string memory chainId = vm.toString(block.chainId);
    //     string memory json1="key";
    //     string memory finalJson = vm.serializeAddress(json1, "address", addr);
    //     string memory dirPath = string.concat(string.concat("deploy_ContractsABIs/", name), "_");
    //     vm.writeJson(finalJson, string.concat(dirPath, string.concat(chainId, ".json"))); 

    // }
}