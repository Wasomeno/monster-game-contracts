const { expect } = require("chai");
const { ethers } = require("hardhat");

let user;
let usersDataContract;
let monstersContract;
let gameContract;
let dungeonContract;
let nurseryContract;
let traderContract;
let itemsContract;

const userSetup = async () => {
  const [user1] = await ethers.getSigners();
  user = user1;
};

const usersDataSetup = async () => {
  let UsersData = await ethers.getContractFactory("UsersData");
  usersDataContract = await UsersData.deploy();
};

const monstersSetup = async () => {
  const Monsters = await ethers.getContractFactory("Monsters");
  monstersContract = await Monsters.deploy();
};

const dungeonSetup = async () => {
  const Dungeon = await ethers.getContractFactory("Dungeon");
  dungeonContract = await Dungeon.deploy();
};

const traderSetup = async () => {
  const Trader = await ethers.getContractFactory("Trader");
  traderContract = await Trader.deploy();
  const items = [0, 1];
  const limits = [3, 3];
  const prices = [
    ethers.utils.parseEther("0.001"),
    ethers.utils.parseEther("0.002"),
  ];
  await traderContract.addItemsToShop(items, limits, prices);
  await traderContract.addNewTrade(0, 2, 1, 2, 3);
};

const missionsSetup = async () => {
  const Missions = await ethers.getContractFactory("MonsterGame");
  const Items = await ethers.getContractFactory("Items");
  const itemsToAdd = [0, 1, 2, 3, 4];
  gameContract = await Missions.deploy();
  itemsContract = await Items.deploy();
  await itemsContract.addNewItems(itemsToAdd);
  await itemsContract.addDrops(0, [0, 1], [3, 5]);
  await itemsContract.addDrops(1, [0, 1], [6, 8]);
  await itemsContract.addDrops(2, [0, 1], [10, 10]);
  await itemsContract.addDrops(3, [0, 1, 2], [12, 14, 1]);
  await itemsContract.addDrops(4, [0, 1, 3], [12, 14, 1]);
  await itemsContract.addDrops(5, [2, 3], [1, 1]);
  await itemsContract.addDrops(6, [0, 2, 3, 4], [50, 2, 1, 10]);
  await itemsContract.addDrops(7, [0, 2, 4], [10, 1, 3]);
  await itemsContract.addDrops(8, [0, 2, 3, 4], [20, 1, 1, 3]);
};

const nurserySetup = async () => {
  const Nursery = await ethers.getContractFactory("Nursery");
  nurseryContract = await Nursery.deploy();
};

const interfaceSetup = async () => {
  await itemsContract.setApprovedAddress(gameContract.address);
  await itemsContract.setApprovedAddress(dungeonContract.address);
  await itemsContract.setApprovedAddress(traderContract.address);
  await gameContract.setInterface(
    monstersContract.address,
    itemsContract.address,
    usersDataContract.address
  );
  await dungeonContract.setInterface(
    monstersContract.address,
    itemsContract.address,
    usersDataContract.address
  );

  await monstersContract.setInterface(usersDataContract.address);
  await monstersContract.setApprovedAddress(nurseryContract.address);
  await monstersContract.setApprovedAddress(gameContract.address);
  await monstersContract.setApprovedAddress(dungeonContract.address);

  await traderContract.setInterface(itemsContract.address);
  await nurseryContract.setInterface(
    monstersContract.address,
    usersDataContract.address
  );
};

describe("User Registration", function () {
  it("Succesfully registered", async () => {
    await usersDataSetup();
    await userSetup();
    await dungeonSetup();
    await nurserySetup();
    await traderSetup();
    await missionsSetup();
    await monstersSetup();
    await interfaceSetup();
    const name = ethers.utils.formatBytes32String("Sir Fargow");
    const image = ethers.utils.formatBytes32String("1");
    await usersDataContract.connect(user).register(name, image);
    const result = await usersDataContract.registrationStatus(user.address);
    expect(result).to.equal(true);
  });
});

describe("Monster Summon", function () {
  it("Returns the same amount of monsters that the use minted", async function () {
    const summonCost = ethers.utils.formatEther(
      await monstersContract.SUMMON_PRICE()
    );
    const total = 5 * summonCost.toString();
    await monstersContract
      .connect(user)
      .summon(5, { value: ethers.utils.parseEther(total.toString()) });

    const summoned = await monstersContract.getMonsters(user.address);
    expect(summoned.length).to.equal(5);
  });

  it("Returns the  monsters details", async function () {
    const monsters = await monstersContract.getMonstersDetails(user.address);
    expect(monsters.length).to.equal(5);
  });
});

describe("Monster Missions and Dungeon", function () {
  // it("Succesfully send monsters to missions", async function () {
  //   const monstersToMission = [0, 1];
  //   await gameContract.connect(user).startMission(1, monstersToMission);
  //   const monstersOnMission = await gameContract.getMonstersOnMission(
  //     user.address
  //   );
  //   const details = await gameContract.monstersOnMissions(user.address);
  //   expect(monstersOnMission.length).to.equal(2);
  // });
  it("Successfully send monsters to dungeon", async function () {
    const monstersToDungeon = [2, 3];
    await dungeonContract.connect(user).startDungeon(monstersToDungeon);
    const monstersOnDungeon = await dungeonContract.getMonstersOnDungeon(
      user.address
    );

    expect(monstersOnDungeon.length).to.equal(2);
  });
  // it("Successfully received rewards from missions", async function () {
  //   await gameContract.connect(user).finishMission();
  //   const monstersOnMission = await gameContract.getMonstersOnMission(
  //     user.address
  //   );
  //   expect(monstersOnMission.length).to.equal(0);
  // });
  it("Succesfully received rewards from dungeon", async function () {
    await dungeonContract.connect(user).finishDungeon();
    const monstersOnDungeon = await dungeonContract.getMonstersOnDungeon(
      user.address
    );
    const inventoryBefore = await itemsContract.getInventory(user.address);
    console.log(inventoryBefore.toString());

    expect(monstersOnDungeon.length).to.equal(0);
  });
});

// describe("Taking care of monsters", function () {
//   it("Successfully send monsters to nursery", async function () {
//     const monstersToNursery = [0, 1, 2, 3, 4];
//     const restingCost = await nurseryContract.RESTING_FEE();
//     const totalCost =
//       2 * ethers.utils.formatEther(restingCost) * monstersToNursery.length;
//     await nurseryContract.connect(user).restMonsters(monstersToNursery, 2, {
//       value: ethers.utils.parseEther(totalCost.toString()),
//     });
//     const monstersOnNursery = await nurseryContract.getRestingMonsters(
//       user.address
//     );
//     const details = await nurseryContract.monstersOnNursery(user.address);
//     console.log(details.toString());
//     expect(monstersOnNursery.length).to.equal(5);
//   });
//   it("Successfully bring back monsters from nursery", async function () {
//     await nurseryContract.connect(user).finishResting();
//     const monstersOnNursery = await nurseryContract.getRestingMonsters(
//       user.address
//     );
//     expect(monstersOnNursery.length).to.equal(0);
//   });
//   it("Successfully feed monsters (payed)", async function () {
//     const fee = await gameContract.FEEDING_FEE();
//     const level = await monstersContract.getMonsterLevel(0);
//     const total = 20 * ethers.utils.formatEther(fee) * level.toString();
//     const energyBefore = await monstersContract.getMonsterEnergy(0);
//     await gameContract.connect(user).feedMonster(0, 20, {
//       value: ethers.utils.parseEther(total.toString()),
//     });

//     const energyAfter = await monstersContract.getMonsterEnergy(0);

//     expect(parseInt(energyAfter)).to.equal(parseInt(energyBefore) + 20);
//   });
//   it("Successfully feed monsters (potion)", async function () {
//     await itemsContract.setApprovalAll(gameContract.address, true);
//     const energyBefore = await monstersContract.getMonsterEnergy(0);
//     await gameContract.connect(user).useEnergyPotion(0, 1);
//     const energyAfter = await monstersContract.getMonsterEnergy(0);
//     expect(parseInt(energyAfter)).to.equal(parseInt(energyBefore) + 10);
//   });
// });

// describe("Buy and trade items", function () {
//   it("Succesfully bought items", async function () {
//     const itemsToBuy = [0, 1];
//     const itemsQuantity = [3, 3];
//     const itemOne = await traderContract.shopItems(0);
//     const itemTwo = await traderContract.shopItems(1);
//     const totalPrice =
//       parseInt(itemOne.price) * itemsQuantity[0] +
//       parseInt(itemTwo.price) * itemsQuantity[1];

//     const inventoryBefore = await itemsContract.getInventory(user.address);

//     await traderContract.buyItems(itemsToBuy, itemsQuantity, user.address, {
//       value: totalPrice,
//     });
//     const inventoryAfter = await itemsContract.getInventory(user.address);
//     const details = await traderContract.shopItems(0);
//     console.log(details.toString());

//     expect(parseInt(inventoryAfter[0])).to.equal(
//       parseInt(inventoryBefore[0]) + 3
//     );
//   });
//   it("Successfully trade items", async function () {
//     const inventoryBefore = await itemsContract.getInventory(user.address);
//     await itemsContract.setApprovalAll(traderContract.address, true);
//     await traderContract.tradeItem(0, 1, user.address);

//     const inventoryAfter = await itemsContract.getInventory(user.address);
//     expect(parseInt(inventoryAfter[0])).to.equal(
//       parseInt(inventoryBefore[0]) - 2
//     );
//   });
// });

// describe("Smelting", () => {
//   it("Succesfully send gem to smelter", async function () {});
// });
