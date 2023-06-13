import { singletons } from "@openzeppelin/test-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("Collection", function () {
  it("Claim should be working as expected and emit the correct event when there is no account share holder", async function () {
    const [katonAddress, projectAddress] = await ethers.getSigners();

    const Collection = await hre.ethers.getContractFactory("Collection");
    const Relayer = await hre.ethers.getContractFactory("Relayer");
    const relayer = await Relayer.deploy();
    const erc1820 = await singletons.ERC1820Registry(katonAddress.address);
    const collection = await Collection.deploy(
      projectAddress.address,
      "TestCoin",
      "https://test.com",
      false,
      {
        isBurnable_: true,
        isFreezable_: true,
        isMintable_: true,
        isPausable_: true,
        isUpgradeable_: true,
        isWipeable_: true,
      },
      {
        accountAddress_: ethers.constants.AddressZero,
        accountFeesPercentage_: 0,
        katonAddress_: katonAddress.address,
        katonFeesPercentage_: 100,
        projectAddress_: projectAddress.address,
        projectFeesPercentage_: 9900,
      },
      relayer.address
    );
    await katonAddress.sendTransaction({
      to: collection.address,
      value: ethers.utils.parseEther("10"),
    });

    await expect(collection.claim(true, ethers.constants.AddressZero))
      .to.emit(collection, "Claimed")
      .withArgs(
        true,
        ethers.constants.AddressZero,
        "10000000000000000000",
        "100000000000000000",
        projectAddress.address,
        "9900000000000000000",
        ethers.constants.AddressZero,
        "0"
      );
  });
  it("Claim should be working as expected and emit the correct event when there is a share holder account", async function () {
    const [katonAddress, projectAddress, shareHolderAccount] = await ethers.getSigners();

    const Collection = await hre.ethers.getContractFactory("Collection");
    const Relayer = await hre.ethers.getContractFactory("Relayer");
    const relayer = await Relayer.deploy();
    const erc1820 = await singletons.ERC1820Registry(katonAddress.address);
    const collection = await Collection.deploy(
      projectAddress.address,
      "TestCoin",
      "https://test.com",
      false,
      {
        isBurnable_: true,
        isFreezable_: true,
        isMintable_: true,
        isPausable_: true,
        isUpgradeable_: true,
        isWipeable_: true,
      },
      {
        accountAddress_: shareHolderAccount.address,
        accountFeesPercentage_: 8000,
        katonAddress_: katonAddress.address,
        katonFeesPercentage_: 100,
        projectAddress_: projectAddress.address,
        projectFeesPercentage_: 1900,
      },
      relayer.address
    );
    await katonAddress.sendTransaction({
      to: collection.address,
      value: ethers.utils.parseEther("10"),
    });

    await expect(collection.claim(true, ethers.constants.AddressZero))
      .to.emit(collection, "Claimed")
      .withArgs(
        true,
        ethers.constants.AddressZero,
        "10000000000000000000",
        "100000000000000000",
        projectAddress.address,
        "1900000000000000000",
        shareHolderAccount.address,
        "8000000000000000000"
      );
  });
});
