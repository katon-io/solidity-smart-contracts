import { ethers } from "hardhat";

async function main() {
  const katonAddress = "0x16cB8A621F3022A602aD41586b108a649DF1c9Bb";

  const CoinFactory = await ethers.getContractFactory("CoinFactory");
  const coinFactory = await CoinFactory.deploy(katonAddress);

  await coinFactory.deployed();

  console.log(
    `Coin factory deployed to ${coinFactory.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});