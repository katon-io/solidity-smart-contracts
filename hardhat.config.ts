import { bscscanApiKey, deployerPrivateKey } from "./secrets.json";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "@solidstate/hardhat-bytecode-exporter";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-deploy";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: { optimizer: { enabled: true, runs: 200 } },
  },
  paths: {
    sources: "./contracts",
  },
  abiExporter: {
    path: "./data",
    runOnCompile: true,
    clear: true,
    only: [
      "Coin",
      "Collection",
      "FeeHandler",
      "Relayer",
      "CoinFactory",
      "CollectionFactory",
    ],
  },
  bytecodeExporter: {
    path: "./data",
    runOnCompile: true,
    clear: true,
    only: [
      "Coin",
      "Collection",
      "FeeHandler",
      "Relayer",
      "CoinFactory",
      "CollectionFactory",
    ],
  },
  networks: {
    bnbChainTestnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      accounts: [deployerPrivateKey],
    },
    bnbChainMainnet: {
      url: `https://bsc-dataseed.binance.org/`,
      accounts: [deployerPrivateKey],
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      gas: 10000000,
      gasPrice: 8000000000
    },
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: bscscanApiKey,
  },
};

export default config;
