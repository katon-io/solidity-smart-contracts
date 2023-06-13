import { ethers } from "hardhat";

async function main() {
  const katonAddress = "0x3Eff76eFD2432B1EFbe1a783B5defF889De3CD86";

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