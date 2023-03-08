import { bscscanApiKey } from "./secrets.json";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "@solidstate/hardhat-bytecode-exporter";
import "@nomiclabs/hardhat-etherscan";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: { optimizer: { enabled: true, runs: 25 } },
  },
  paths: {
    sources: "./contracts",
  },
  abiExporter: {
    path: "./data",
    runOnCompile: true,
    clear: true,
    only: ["Coin", "Collection", "FeeHandler", "Relayer", "CoinFactory", "CollectionFactory"],
  },
  bytecodeExporter: {
    path: "./data",
    runOnCompile: true,
    clear: true,
    only: ["Coin", "Collection", "FeeHandler", "Relayer", "CoinFactory", "CollectionFactory"],
  },
  networks: {
    testnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
    },
    mainnet: {
      url: `https://bsc-dataseed.binance.org/`,
    },
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: bscscanApiKey,
  },
};

export default config;
