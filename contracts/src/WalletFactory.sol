// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "@openzeppelin/contracts/proxy/Clones.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/*
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * 部署最小代理合约，也称为“克隆”
 */
contract WalletFactory {
    //钱包合约创建事件
    event WalletDeployment(address indexed proxy, address indexed implementation);

    /**
     * 
     * @param _implementation 
     * @param _initCallData 
     */
    function createWallet(address _implementation, bytes memory _initCallData) public payable returns (address wallet) {
        wallet = _clone(_implementation, _initCallData);

        emit WalletDeployment(wallet, _implementation);
    }
    /**
     * 
     * @param _implementation 
     * @param _initCallData 
     * @param _salt 
     */
    function createWallet(address _implementation, bytes memory _initCallData, bytes32 _salt)
        public
        payable
        returns (address wallet)
    {
        wallet = _cloneDeterministic(_implementation, _initCallData, _salt);

        emit WalletDeployment(wallet, _implementation);
    }
    /**
     * 预测 确定性地址
     * @param implementation 
     * @param salt 
     * @return address 合约的地址
     */
    function predictDeterministicAddress(address implementation, bytes32 salt) public view returns (address) {
        return Clones.predictDeterministicAddress(implementation, salt);
    }

    /**
     * 
     * @param _implementation 
     * @param _initCallData 
     * @return _contract  
     */
    function _clone(address _implementation, bytes memory _initCallData) internal returns (address _contract) {
        _contract = Clones.clone(_implementation);

        // Initialize Wallet
        if (_initCallData.length > 0) {
            Address.functionCallWithValue(_contract, _initCallData, msg.value);
        }
    }
    //克隆确定性地址
    function _cloneDeterministic(address _implementation, bytes memory _initCallData, bytes32 _salt)
        internal
        returns (address _contract)
    {
        _contract = Clones.cloneDeterministic(_implementation, _salt);

        // Initialize Wallet
        if (_initCallData.length > 0) {
            Address.functionCallWithValue(_contract, _initCallData, msg.value);
        }
    }

    function _cloneDeterministic(
        address _implementation,
        bytes memory _initCallData,
        bytes32 _salt,
        uint256 _valueDenominator
    ) internal returns (address _contract) {
        _contract = Clones.cloneDeterministic(_implementation, _salt);

        // Initialize wallet
        if (_initCallData.length > 0) {
            Address.functionCallWithValue(_contract, _initCallData, msg.value / _valueDenominator);
        }
    }
}