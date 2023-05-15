import { singletons } from "@openzeppelin/test-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("CoinFactory", function () {
  it("Should create a coin with 0 value", async function () {
    const katonAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

    const CoinFactory = await hre.ethers.getContractFactory("CoinFactory");
    const Relayer = await hre.ethers.getContractFactory("Relayer");
    const coinFactory = await CoinFactory.deploy(katonAddress);
    const relayer = await Relayer.deploy();
    const erc1820 = await singletons.ERC1820Registry(katonAddress);

    // assert that the value is correct
    const truc = await coinFactory.issueCoin(
      katonAddress,
      "TestCoin",
      "TCOIN",
      100000000,
      [],
      {
        isBurnable_: true,
        isFreezable_: true,
        isMintable_: true,
        isPausable_: true,
        isUpgradeable_: true,
        isWipeable_: true,
      },
      relayer.address,
      {
        value: 0,
        from: katonAddress,
      }
    );
    const waited = await truc.wait();
    const events = waited.events;
    const coinIssuedEvent = events?.find(
      (event) => event.event === "CoinIssued"
    );
    if (coinIssuedEvent && coinIssuedEvent.decode)
      expect(
        coinIssuedEvent.decode(coinIssuedEvent.data, coinIssuedEvent.topics)
      ).to.not.be.null;
  });
  it("Should create a coin with a value", async function () {
    const katonAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

    const CoinFactory = await hre.ethers.getContractFactory("CoinFactory");
    const Relayer = await hre.ethers.getContractFactory("Relayer");
    const coinFactory = await CoinFactory.deploy(katonAddress);
    const relayer = await Relayer.deploy();
    const erc1820 = await singletons.ERC1820Registry(katonAddress);

    // assert that the value is correct
    const truc = await coinFactory.issueCoin(
      katonAddress,
      "TestCoin",
      "TCOIN",
      100000000,
      [],
      {
        isBurnable_: true,
        isFreezable_: true,
        isMintable_: true,
        isPausable_: true,
        isUpgradeable_: true,
        isWipeable_: true,
      },
      relayer.address,
      {
        value: ethers.BigNumber.from(1000000000),
        from: katonAddress,
      }
    );
    const waited = await truc.wait();
    const events = waited.events;
    const coinIssuedEvent = events?.find(
      (event) => event.event === "CoinIssued"
    );
    if (coinIssuedEvent && coinIssuedEvent.decode) {
      expect(
        coinIssuedEvent.decode(coinIssuedEvent.data, coinIssuedEvent.topics)
      ).to.not.be.null;
    }
  });
});
