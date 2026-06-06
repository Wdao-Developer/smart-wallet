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
cast wallet import deployer2026 --interactive
```

### Deploy

```shell
$ # 部署币安链 Deploy in BSC
$ forge script script/DeployFactoryAndWallet.s.sol:DeployFactoryAndWallet --rpc-url bnb_smart_chain --account deployer2026 --sender <YOUR_ADDRESS> --broadcast --verify --etherscan-api-key $ETHERSCAN_TOKEN

$ # 部署uni链 Deploy in Unichain
$ forge script script/DeployFactoryAndWallet.s.sol:DeployFactoryAndWallet --rpc-url unichain  --account deployer2026 --sender <YOUR_ADDRESS> --broadcast --verify --etherscan-api-key $ETHERSCAN_TOKEN 

$ # 使用Uniswap V4头寸运行演示不停转账的脚本 Run Script for Demo Unstopable transfers from Uniswap V4 position
$ #  forge script script/InteracteScript_m.s.sol:InteracteScript --rpc-url bnb_smart_chain  --broadcast --via-ir --account deployer2026
$ # forge script script/InteracteScript_m.s.sol:InteracteScript --rpc-url unichain  --broadcast --via-ir --account deployer2026
```
### Test
```shell
forge test -vvvv
```
