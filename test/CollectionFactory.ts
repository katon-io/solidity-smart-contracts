import { singletons } from "@openzeppelin/test-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("CollectionFactory", function () {
  it("Should create a collection with 0 value", async function () {
    const katonAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    const projectAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

    const CoinFactory = await hre.ethers.getContractFactory(
      "CollectionFactory"
    );
    const Relayer = await hre.ethers.getContractFactory("Relayer");
    const coinFactory = await CoinFactory.deploy(katonAddress);
    const relayer = await Relayer.deploy();
    const erc1820 = await singletons.ERC1820Registry(katonAddress);

    // assert that the value is correct
    const truc = await coinFactory.issueCollection(
      katonAddress,
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
        katonAddress_: katonAddress,
        katonFeesPercentage_: 100,
        projectAddress_: projectAddress,
        projectFeesPercentage_: 9900,
      },
      relayer.address,
      {
        value: 0,
        from: katonAddress,
      }
    );
    const waited = await truc.wait();
    const events = waited.events;
    const collectionIssuedEvent = events?.find(
      (event) => event.event === "CollectionIssued"
    );
    if (collectionIssuedEvent && collectionIssuedEvent.decode)
      expect(
        collectionIssuedEvent.decode(
          collectionIssuedEvent.data,
          collectionIssuedEvent.topics
        )
      ).to.not.be.null;
  });
  it("Should create a collection with a value", async function () {
    const katonAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    const projectAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

    const CoinFactory = await hre.ethers.getContractFactory(
      "CollectionFactory"
    );
    const Relayer = await hre.ethers.getContractFactory("Relayer");
    const coinFactory = await CoinFactory.deploy(katonAddress);
    const relayer = await Relayer.deploy();
    const erc1820 = await singletons.ERC1820Registry(katonAddress);

    // assert that the value is correct
    const truc = await coinFactory.issueCollection(
      katonAddress,
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
        katonAddress_: katonAddress,
        katonFeesPercentage_: 100,
        projectAddress_: projectAddress,
        projectFeesPercentage_: 9900,
      },
      relayer.address,
      {
        value: ethers.BigNumber.from(1000000000),
        from: katonAddress,
      }
    );
    const waited = await truc.wait();
    const events = waited.events;
    const collectionIssuedEvent = events?.find(
      (event) => event.event === "CollectionIssued"
    );
    if (collectionIssuedEvent && collectionIssuedEvent.decode)
      expect(
        collectionIssuedEvent.decode(
          collectionIssuedEvent.data,
          collectionIssuedEvent.topics
        )
      ).to.not.be.null;
  });
});
