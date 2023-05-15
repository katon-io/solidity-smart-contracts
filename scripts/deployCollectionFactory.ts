import { ethers } from "hardhat";

async function main() {
  const katonAddress = "0x16cB8A621F3022A602aD41586b108a649DF1c9Bb";

  const CollectionFactory = await ethers.getContractFactory("CollectionFactory");
  const collectionFactory = await CollectionFactory.deploy(katonAddress);

  await collectionFactory.deployed();

  console.log(
    `Collection factory deployed to ${collectionFactory.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});