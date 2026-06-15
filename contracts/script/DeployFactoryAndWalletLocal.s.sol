// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {console} from "forge-std/console.sol";

import {Script} from "forge-std/Script.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {IUniswapV4Router04} from "hookmate/interfaces/router/IUniswapV4Router04.sol";
import {AddressConstants} from "hookmate/constants/AddressConstants.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";

import {Permit2Deployer} from "hookmate/artifacts/Permit2.sol";
import {V4PoolManagerDeployer} from "hookmate/artifacts/V4PoolManager.sol";
import {V4PositionManagerDeployer} from "hookmate/artifacts/V4PositionManager.sol";
import {V4RouterDeployer} from "hookmate/artifacts/V4Router.sol";

//import {EasyPositionManager} from "./libraries/EasyPositionManager.sol";

import {WalletFactory} from "../src/WalletFactory.sol";
import {ProxyWallet} from "../src/ProxyWallet.sol";

//import {Deployers} from "../script/Deployers.s.sol";


contract DeployFactoryAndWalletLocal is Script{
    //using EasyPositionManager for IPositionManager;
    IPermit2 permit2;
    IPoolManager poolManager;
    IPositionManager positionManager;
    IUniswapV4Router04 swapRouter;
    Currency  currencyToken0;
    Currency  currencyToken1;
    PoolKey poolKey;
    int24 tickLower;
    int24 tickUpper;
    uint256 tokenId;
     function run() public{
       
        vm.startBroadcast();
        //1.先部署peimit2,PoolManager,PositionManage和UniSwapV4 Router
        deployArtifacts(block.coinbase);
        
       //3.先部署factory,ProxyWallet,合约
        WalletFactory factory = new WalletFactory();
        ProxyWallet walletImpl = new ProxyWallet(
            address(swapRouter),
            address(poolManager),
            address(permit2),
            address(positionManager),
            address(factory)
        );
        //2.部署2代币
        (currencyToken0, currencyToken1) = deployCurrencyPair(address(walletImpl));
        // MockERC20(Currency.unwrap(currencyToken0)).mint(address(walletImpl),1200);
        // MockERC20(Currency.unwrap(currencyToken1)).mint(address(walletImpl),1500);

        //4.初始化 poolkey
        poolKey = PoolKey(currencyToken0, currencyToken1, 3000, 60, IHooks(address(0)));
        //5.初始化 poolmanager
        poolManager.initialize(poolKey, Constants.SQRT_PRICE_1_1);



        // tickLower = TickMath.minUsableTick(poolKey.tickSpacing);//头寸的下界
        // tickUpper = TickMath.maxUsableTick(poolKey.tickSpacing);//头寸的上界

        // uint128 liquidityAmount = 10000e6;

        // (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
        //     Constants.SQRT_PRICE_1_1,
        //     TickMath.getSqrtPriceAtTick(tickLower),
        //     TickMath.getSqrtPriceAtTick(tickUpper),
        //     liquidityAmount
        // );
        
        // bytes memory actions = abi.encodePacked(uint8(Actions.MINT_POSITION), uint8(Actions.SETTLE_PAIR), uint8(Actions.SWEEP), uint8(Actions.SWEEP));

        // bytes[] memory mintParams = new bytes[](4);
        // mintParams[0] = abi.encode(poolKey, tickLower, tickUpper, liquidityAmount, amount0Expected, amount1Expected, address(walletImpl),  Constants.ZERO_BYTES);
        // mintParams[1] = abi.encode(currencyToken0, currencyToken1);
        // mintParams[2] = abi.encode(currencyToken0, address(walletImpl));
        // mintParams[3] = abi.encode(currencyToken1, address(walletImpl));

        // tokenId = positionManager.nextTokenId();
        // uint256 valueToPass = currencyToken0.isAddressZero() ? amount0Expected : 0;

        // positionManager.modifyLiquidities{value: valueToPass}(abi.encode(actions, mintParams), block.timestamp);


        console.log("WalletFactory deployed at:",address(factory));
        console.log("permit2 deployed at:", address(permit2));
        console.log("poolManager deployed at:", address(poolManager));
        console.log("positionManager deployed at:", address(positionManager));
        console.log("swapRouter deployed at:", address(swapRouter));
        console.log("ProxyWallet deployed at:",address(walletImpl));
        console.log("currencyToken0 deployed at:", address(Currency.unwrap(currencyToken0)));
        console.log("currencyToken1 deployed at:", address(Currency.unwrap(currencyToken1)));

        console.log("wallet Token0 blanceof:", MockERC20(Currency.unwrap(currencyToken0)).balanceOf(address(walletImpl)));
        console.log("wallet Token1 blanceof:", MockERC20(Currency.unwrap(currencyToken1)).balanceOf(address(walletImpl)));

        saveContracts('permit2',address(permit2),block.chainid);
        saveContracts('poolManager',address(poolManager),block.chainid);
        saveContracts('positionManager',address(positionManager),block.chainid);
        saveContracts('swapRouter',address(swapRouter),block.chainid);
        saveContracts('WalletFactory',address(factory),block.chainid);
        saveContracts('ProxyWallet',address(walletImpl),block.chainid);

        saveContracts('currencyToken0', address(Currency.unwrap(currencyToken0)),block.chainid);
        saveContracts('currencyToken1',address(Currency.unwrap(currencyToken1)),block.chainid);

        vm.stopBroadcast();
        
       
        
        
     }
     //部署Permit2
    function deployPermit2() internal {
        //address permit2Address = AddressConstants.getPermit2Address();

        // if (permit2Address.code.length > 0) {
        //     // Permit2 is already deployed, no need to etch it.
        // } else {
        //     _etch(permit2Address, Permit2Deployer.deploy().code);
        // }

        permit2 = IPermit2(Permit2Deployer.deploy());
        //saveContracts("permit2",address(permit2));
    }

    //部署PoolManager
     function deployPoolManager() internal virtual {
         //local network
        poolManager = IPoolManager(V4PoolManagerDeployer.deploy(address(0x4444)));
        //saveContracts("poolManager",address(poolManager));
    }
    //部署PositionManager
    function deployPositionManager() internal virtual {
         //local network
        positionManager = IPositionManager(
                V4PositionManagerDeployer.deploy(
                    address(poolManager), address(permit2), 300_000, address(0), address(0)
                )
            );
        
        //saveContracts("positionManager",address(positionManager));
    }
    //部署UniSwapV4 Router
    function deployRouter() internal virtual {
        //local network
         swapRouter = IUniswapV4Router04(payable(V4RouterDeployer.deploy(address(poolManager), address(permit2))));
        //saveContracts("swapV4Router",address(swapRouter));
    }
    function deployToken(address coinbase,string memory symb, uint256 supply, uint8 dec) internal returns (MockERC20 token) {
        token = new MockERC20("Test Token", symb, dec);
        token.mint(coinbase, supply);

        token.approve(address(permit2), type(uint256).max);
        token.approve(address(swapRouter), type(uint256).max);

        permit2.approve(address(token), address(positionManager), type(uint160).max, type(uint48).max);
        permit2.approve(address(token), address(poolManager), type(uint160).max, type(uint48).max);
    }

    function deployCurrencyPair(address coinbase) internal virtual returns (Currency currency0, Currency currency1) {
        MockERC20 token0 = deployToken(coinbase,"LRT", 10_000_000e18, 6);
        MockERC20 token1 = deployToken(coinbase,"REV", 20_000_000e18, 6);
        //确保token0地址小于token1
        if (address(token0)  > address(token1) ){
            (token0, token1) = (token1, token0);
        }

        currency0 = Currency.wrap(address(token0));
        currency1 = Currency.wrap(address(token1));
    }

    function _etch(address, bytes memory) internal virtual {
        revert("Not implemented");
    }
    function deployArtifacts(address coinbase) internal {
        
        deployPermit2(coinbase);
        deployPoolManager();
        deployPositionManager();
        deployRouter();
    }

    function saveContracts(string memory name,address addr,uint256 chainid) internal {
        //string memory timestamp = string.concat("-",vm.toString(time));
        string memory chainId = vm.toString(chainid);
        string memory json1="key";
        string memory finalJson = vm.serializeAddress(json1, "address", addr);
        string memory dirPath = string.concat(string.concat("deploy_ContractsAddr/", name), "_");
        vm.writeJson(finalJson, string.concat(dirPath, string.concat(chainId, ".json"))); 

    }
}