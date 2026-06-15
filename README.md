# uniswap-v4 smart wallet

## Key property of this design

Assets are not held at the user’s EOA. Instead, funds are deposited into a Uniswap v4 liquidity position , where they continuously earn yield as a liquidity provider.

This custody model renders address-level freezes enforced by centralized stablecoin issuers ineffective, because no assets reside on the owner’s address that can be directly blacklisted or seized.

Fund transfers from this “wallet” are executed within a single atomic transaction using account abstraction, based on the Uniswap Calibur solution.

Within this transaction (which can be submitted by any relayer possessing a valid owner signature), the following steps occur atomically:

- A temporary, single-use proxy smart wallet is deployed.
- The required portion of liquidity is withdrawn from the Uniswap v4 position to the proxy wallet.
- The withdrawn assets are swapped on Uniswap into a single target asset.
- The target asset is transferred to the recipient address.

## Usage

### Environment Variables

Create a .env file in the root directory and configure the necessary keys (e.g., ARBISCAN_TOKEN,SNOWTRACE_TOKEN, BLASTSCAN_TOKEN). You can find them in ./contracts/foundry.toml

### Use encrypted keystores

```shell
cast wallet new
```
```shell
cast wallet import deployer2026 --interactive
```
### Deploy Local
#### 1.运行本地测试链 Run test chain server in local
```shell
# default port is 8545
$ anvil
```
#### 2.部署本地测试脚本 Deploy in local
```shell
$ ## 确认<YOUR_WALLET_ACCOUNTS_ADDRESS>  这个是anvil分配的钱包账号，并且里面有余额(默认分配10000ETH)，--unlocked是必须的，否则无法交易
$ forge clean
$ forge script script/DeployFactoryAndWalletLocal.s.sol:DeployFactoryAndWalletLocal --broadcast --rpc-url localhost --sender <YOUR_WALLET_ACCOUNTS_ADDRESS> --unlocked   -vvvv
```

### 3. 显示已部署代币余额
```shell
$ # 显示代币0的总数
$ cast call <CURRENCY0_ADDRESS> "totalSupply()(uint256)" --rpc-url http://127.0.0.1:8545
$ # 显示代理钱包内代币0的数量
$ cast call <CURRENCY0_ADDRESS> "balanceOf(address)" <PROXY_WALLET_ADDERSS>  --rpc-url http://127.0.0.1:8545
$ # 向代理钱包转账代币0
$ cast call <CURRENCY0_ADDRESS> "mint(address,uint256)" <PROXY_WALLET_ADDERSS> <AMOUNT> --rpc-url http://127.0.0.1:8545
```


#### 4.运行前端工程 Run frontend project
```shell
$ cd  frontend
$ npm run dev
```
#### 5.连接钱包后将anvil创建的钱包导入METAMASK

#### 6.打开浏览器http://localhost:3000,连接小狐狸钱包，输入currency0、currency1、代理钱包(ProxyWallet.sol)地址、最终出币的货币地址、要交易的账户、交易数量，模拟swapAndTransfer方法

### Deploy in main Chain
```shell
$ ## 确认<YOUR_WALLET_ACCOUNTS_ADDRESS>  这个是自己的钱包账号，并且里面有余额(部署上链需要真ETH)
$ # 部署币安链 Deploy in BSC
$ forge script script/DeployFactoryAndWallet.s.sol:DeployFactoryAndWallet --rpc-url bnb_smart_chain --account deployer2026 --sender <YOUR_WALLET_ACCOUNTS_ADDRESS> --broadcast --verify --etherscan-api-key $ETHERSCAN_TOKEN

$ # 部署uni链 Deploy in Unichain
$ forge script script/DeployFactoryAndWallet.s.sol:DeployFactoryAndWallet --rpc-url unichain  --account deployer2026 --sender <YOUR_WALLET_ACCOUNTS_ADDRESS> --broadcast --verify --etherscan-api-key $ETHERSCAN_TOKEN 
```
### Test
```shell
forge test -vvvv
```