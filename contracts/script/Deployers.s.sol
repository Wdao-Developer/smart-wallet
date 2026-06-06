// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";

import {Currency} from "v4-core/src/types/Currency.sol";

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";

import {IUniswapV4Router04} from "hookmate/interfaces/router/IUniswapV4Router04.sol";
import {AddressConstants} from "hookmate/constants/AddressConstants.sol";

import {Permit2Deployer} from "hookmate/artifacts/Permit2.sol";
import {V4PoolManagerDeployer} from "hookmate/artifacts/V4PoolManager.sol";
import {V4PositionManagerDeployer} from "hookmate/artifacts/V4PositionManager.sol";
import {V4RouterDeployer} from "hookmate/artifacts/V4Router.sol";

/**
 *  Deployer 合约用于钩子测试
 *
 * 自动执行:
 * 1. 安装部署Permit2， PoolManager， PositionManager和V4SwapRouter.
 * 2. 检查chainId是否为31337，如果是，则部署本地实例.
 * 3. 如果没有，则使用所选网络上的现有规范部署.
 * 4. 提供实用函数来部署token和货币对.
 *
 * 这个合约既可以用于本地测试，也可以用于分叉测试.
 */

abstract contract Deployers {
    IPermit2 permit2;
    IPoolManager poolManager;
    IPositionManager positionManager;
    IUniswapV4Router04 swapRouter;
    
    function deployToken() internal returns (MockERC20 token) {
        token = new MockERC20("Test Token", "TEST", 18);
        token.mint(address(this), 10_000_000 ether);

        token.approve(address(permit2), type(uint256).max);
        token.approve(address(swapRouter), type(uint256).max);

        permit2.approve(address(token), address(positionManager), type(uint160).max, type(uint48).max);
        permit2.approve(address(token), address(poolManager), type(uint160).max, type(uint48).max);
    }
    
    function deployToken(string memory symb, uint256 supply, uint8 dec) internal returns (MockERC20 token) {
        token = new MockERC20("Test Token", symb, dec);
        token.mint(address(this), supply);

        token.approve(address(permit2), type(uint256).max);
        token.approve(address(swapRouter), type(uint256).max);

        permit2.approve(address(token), address(positionManager), type(uint160).max, type(uint48).max);
        permit2.approve(address(token), address(poolManager), type(uint160).max, type(uint48).max);
    }

    function deployCurrencyPair() internal virtual returns (Currency currency0, Currency currency1) {
        MockERC20 token0 = deployToken("fUSDT", 10_000_000e18, 6);
        MockERC20 token1 = deployToken("fUSDC", 20_000_000e18, 6);

        if (token0  >token1) {
            (token0, token1) = (token1, token0);
        }

        currency0 = Currency.wrap(address(token0));
        currency1 = Currency.wrap(address(token1));
    }

    //部署Permit2
    function deployPermit2() internal {
        address permit2Address = AddressConstants.getPermit2Address();

        if (permit2Address.code.length > 0) {
            // Permit2 is already deployed, no need to etch it.
        } else {
            _etch(permit2Address, Permit2Deployer.deploy().code);
        }

        permit2 = IPermit2(permit2Address);
        //saveContracts("permit2",address(permit2));
    }

    //部署PoolManager
     function deployPoolManager() internal virtual {
         //local network
        if (block.chainid == 31337) {
            poolManager = IPoolManager(V4PoolManagerDeployer.deploy(address(0x4444)));
        } else {
            poolManager = IPoolManager(AddressConstants.getPoolManagerAddress(block.chainid));
        }
        //saveContracts("poolManager",address(poolManager));
    }
    //部署PositionManager
    function deployPositionManager() internal virtual {
         //local network
        if (block.chainid == 31337) {
            positionManager = IPositionManager(
                V4PositionManagerDeployer.deploy(
                    address(poolManager), address(permit2), 300_000, address(0), address(0)
                )
            );
        } else {
            positionManager = IPositionManager(AddressConstants.getPositionManagerAddress(block.chainid));
        }
        
        //saveContracts("positionManager",address(positionManager));
    }
    //部署UniSwapV4 Router
    function deployRouter() internal virtual {
        //local network
        if (block.chainid == 31337) {
            swapRouter = IUniswapV4Router04(payable(V4RouterDeployer.deploy(address(poolManager), address(permit2))));
        } else {
            swapRouter = IUniswapV4Router04(payable(AddressConstants.getV4SwapRouterAddress(block.chainid)));
        }
        //saveContracts("swapV4Router",address(swapRouter));
    }

    function _etch(address, bytes memory) internal virtual {
        revert("Not implemented");
    }
    
    function deployArtifacts() internal {
        
        deployPermit2();
        deployPoolManager();
        deployPositionManager();
        deployRouter();
    }

}
