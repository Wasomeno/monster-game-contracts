const { BigNumber } = require("ethers");
const hre = require("hardhat");

async function main() {
  const [owner, user1] = await hre.ethers.getSigners();
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
  const items = await Items.deploy(monsterGame.address);

  await monster.deployed();
  await nursery.deployed();
  await trader.deployed();
  await smelter.deployed();
  await dungeon.deployed();
  await items.deployed();
  await monsterGame.deployed();

  await nursery.setInterface(monster.address, items.address);
  await trader.setInterface(items.address, monsterGame.address);
  await dungeon.setInterface(monster.address, items.address);
  await nursery.setInterface(monster.address, items.address);

  let shopItems = [];
  shopItems.push(BigNumber.from(0));
  shopItems.push(BigNumber.from(1));
  shopItems.push(BigNumber.from(2));
  let limits = [];
  limits.push(BigNumber.from(3));
  limits.push(BigNumber.from(4));
  limits.push(BigNumber.from(5));

  let prices = [];
  prices.push(hre.ethers.utils.parseEther("0.00004"));
  prices.push(hre.ethers.utils.parseEther("0.0002"));
  prices.push(hre.ethers.utils.parseEther("0.00001"));

  await trader.connect(owner).addItemsToShop(shopItems, limits, prices);
  await trader.connect(owner).addTradeToTrader(0, 1, 3, 2, 5);
  console.log("===Mint Monster NFT======");

  const price = (3 * 0.002).toString();
  await monster
    .connect(user1)
    .summon(3, { value: hre.ethers.utils.parseEther(price) });

  console.log("");
  console.log("Minting Succeeded !");
  console.log("");

  const balance = await monster.balanceOf(user1.address);
  const monsters = await monster.getMyMonster(user1.address);

  console.log(
    "Monsters owned by user 1: " + monsters + " (" + balance + " monsters)"
  );
  console.log("");

  console.log("=== Send monster dungeon ====");

  const monster0 = await monster.monsterStats(0);

  console.log("Monster 0 stats before mission : " + monster0);

  await dungeon.connect(user1).bossFight(0, user1.address);

  console.log("");
  console.log("Sending Monster 0 to dungeon...");
  console.log("");

  await dungeon.claimBossFight(0, user1.address);
  const monster0After = await monster.monsterStats(0);

  console.log("Monster 0 stats after mission : " + monster0After);
  console.log("");

  const inventory0 = await items.getInventory(user1.getAddress());

  console.log("User 1 inventory after dungeon: ( " + inventory0 + " )");

  console.log("");
  console.log("=== Send Monster To Nursery ========");

  console.log("Sending monster to nursery.....");
  console.log("");

  await nursery.putOnNursery(0, user1.address, 3);
  await nursery.goBackHome(0, user1.address);

  const monsterAfterNursery = await monster.monsterStats(0);

  console.log("Monster 0 stats after nursery : " + monsterAfterNursery);
  console.log("");

  console.log("=== Buy and Trade items on Trader ===========");

  const item0 = await trader.shopItems(0);
  const item1 = await trader.shopItems(1);
  const item2 = await trader.shopItems(2);
  const total = item0.price * 3 + item1.price * 4 + item2.price * 5;
  await trader.buyItems([0, 1, 2], [3, 4, 5], user1.address, {
    value: total,
  });

  await trader.connect(user1).tradeItem(0, 5, user1.address);
  const inventory = await items.getInventory(user1.getAddress());

  const dailyLimit = await trader.getTradeDailyLimit(user1.getAddress());
  const dailyTimeLimit = await trader.dailyTradeTimeLimit(user1.getAddress());
  console.log(dailyLimit.toString());
  console.log(dailyTimeLimit.toString());

  console.log("");

  console.log("User 1 inventory after buy: ( " + inventory + " )");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
