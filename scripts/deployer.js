const hre = require("hardhat");

async function main() {
  const Monster = await hre.ethers.getContractFactory("Monsters");
  const monster = await Monster.deploy();

  const MonsterGame = await hre.ethers.getContractFactory("MonsterGame");
  const monsterGame = await MonsterGame.deploy();

  const Smelter = await hre.ethers.getContractFactory("Smelter");
  const smelter = await Smelter.deploy();

  const Dungeon = await hre.ethers.getContractFactory("Dungeon");
  const dungeon = await Dungeon.deploy();

  const Trader = await hre.ethers.getContractFactory("Trader");
  const trader = await Trader.deploy();

  const Nursery = await hre.ethers.getContractFactory("Nursery");
  const nursery = await Nursery.deploy();

  const Items = await hre.ethers.getContractFactory("Items");
  const items = await Items.deploy();

  const UsersData = await hre.ethers.getContractFactory("UsersData");
  const usersData = await UsersData.deploy();

  const MonsterToken = await hre.ethers.getContractFactory("MonsterToken");
  const monsterToken = await MonsterToken.deploy();

  await monster.deployed();
  await nursery.deployed();
  await smelter.deployed();
  await dungeon.deployed();
  await monsterGame.deployed();
  await trader.deployed();
  await items.deployed();
  await usersData.deployed();
  await monsterToken.deployed();

  await monsterGame.setInterface(
    monster.address,
    items.address,
    usersData.address
  );
  await dungeon.setInterface(monster.address, items.address, usersData.address);
  await nursery.setInterface(monster.address, usersData.address);
  await trader.setInterface(items.address);
  await smelter.setInterface(
    items.address,
    monsterToken.address,
    usersData.address
  );

  const itemsToAdd = [0, 1, 2];
  await items.setApprovedAddress(monsterGame.address);
  await items.setApprovedAddress(dungeon.address);
  await items.setApprovedAddress(trader.address);
  await items.addNewItems(itemsToAdd);
  await items.addDrops(0, [0, 1], [3, 5]);
  await items.addDrops(1, [0, 1], [6, 8]);
  await items.addDrops(2, [0, 1], [10, 10]);
  await items.addDrops(3, [0, 1, 2], [12, 14, 1]);
  await items.addDrops(4, [0, 1, 3], [12, 14, 1]);
  await items.addDrops(5, [2, 3], [1, 1]);
  await items.addDrops(6, [0, 2, 3, 4], [50, 2, 1, 10]);
  await items.addDrops(7, [0, 2, 4], [10, 1, 3]);
  await items.addDrops(8, [0, 2, 3, 4], [20, 1, 1, 3]);

  await monster.setInterface(usersData.address);
  await monster.setApprovedAddress(nursery.address);
  await monster.setApprovedAddress(monsterGame.address);
  await monster.setApprovedAddress(dungeon.address);

  const shopItems = [0, 1];
  const limits = [3, 3];
  const prices = [
    hre.ethers.utils.parseEther("0.001"),
    hre.ethers.utils.parseEther("0.002"),
  ];

  await trader.addItemsToShop(shopItems, limits, prices);
  await trader.addNewTrade(0, 2, 1, 2, 3);

  console.log("Monster NFT deployed to:", monster.address);
  console.log("Monster Game deployed to:", monsterGame.address);
  console.log("Nursery deployed to:", nursery.address);
  console.log("Dungeon deployed to:", dungeon.address);
  console.log("Smelter deployed to:", smelter.address);
  console.log("Items deployed to:", items.address);
  console.log("Users Data deployed to: ", usersData.address);
  console.log("Trader deployed to:", trader.address);
  console.log("Monster Token deployed to: ", monsterToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
