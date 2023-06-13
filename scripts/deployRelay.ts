import { ethers } from "hardhat";

async function main() {
  const Relay = await ethers.getContractFactory("Relayer");
  const relay = await Relay.deploy();

  await relay.deployed();

  console.log(
    `Relayer deployed to ${relay.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});