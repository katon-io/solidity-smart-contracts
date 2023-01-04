# Solidity Hardhat project for Katon.io smart contracts

This project contains all contracts used in Katon.io ecosystem for EVM blockchains

To compile

```shell
npx hardhat compile
```

To verify a contract
Copy the `secrets.template.json` file and name it `secrets.json`. Ask for the `bscscanApiKey` and update the field. 

```shell
npx hardhat verify --network MAINNET/TESTNET --constructor-args ./arguments.js ADDRESS_OF_CONTRACT
```

Example:
```shell
npx hardhat verify --network testnet --constructor-args ./coin_args.js 0xE1866D37d8e070f94ff97B0c3465713a01ADB25C
```
