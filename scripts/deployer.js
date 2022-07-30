const hre = require("hardhat");

async function main() {
  // const Monster = await hre.ethers.getContractFactory("Monsters");
  // const monster = await Monster.deploy();

  // const MonsterGame = await hre.ethers.getContractFactory("MonsterGame");
  // const monsterGame = await MonsterGame.deploy();

  // const Smelter = await hre.ethers.getContractFactory("Smelter");
  // const smelter = await Smelter.deploy();

  // const Dungeon = await hre.ethers.getContractFactory("Dungeon");
  // const dungeon = await Dungeon.deploy();

  // const Trader = await hre.ethers.getContractFactory("Trader");
  // const trader = await Trader.deploy();

  const Nursery = await hre.ethers.getContractFactory("Nursery");
  const nursery = await Nursery.deploy();

  // const Items = await hre.ethers.getContractFactory("Items");
  // const items = await Items.deploy(monsterGame.address);

  // await monster.deployed();
  await nursery.deployed();
  // await smelter.deployed();
  // await dungeon.deployed();
  // await items.deployed();
  // await monsterGame.deployed();
  // await trader.deployed();

  // await monsterGame.setInterface(
  //   "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35",
  //   "0x1c83A0119Fc52E6Ff5F9E1d1A6B39e54c422646f"
  // );
  await nursery.setInterface(
    "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35",
    "0x1c83A0119Fc52E6Ff5F9E1d1A6B39e54c422646f"
  );
  // await dungeon.setInterface(
  //   "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35",
  //   "0x1c83A0119Fc52E6Ff5F9E1d1A6B39e54c422646f"
  // );
  // await nursery.setInterface(monster.address, items.address);

  // await trader.setInterface(items.address, monsterGame.address);

  // console.log("Monster NFT deployed to:", monster.address);
  // console.log("Monster Game deployed to:", monsterGame.address);
  console.log("Nursery deployed to:", nursery.address);
  // console.log("Dungeon deployed to:", dungeon.address);
  // console.log("Smelter deployed to:", smelter.address);
  // console.log("Items deployed to:", items.address);

  // console.log("Trader deployed to:", trader.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
