import { bscscanApiKey } from "./secrets.json";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "@solidstate/hardhat-bytecode-exporter";
import "@nomiclabs/hardhat-etherscan";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  paths: {
    sources: "./contracts",
  },
  abiExporter: {
    path: "./data/abi",
    runOnCompile: true,
    clear: true,
    only: ["Coin", "Collection", "FeeHandler", "Relayer"],
  },
  bytecodeExporter: {
    path: "./data/bin",
    runOnCompile: true,
    clear: true,
    only: ["Coin", "Collection", "FeeHandler", "Relayer"],
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
