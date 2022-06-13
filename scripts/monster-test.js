const hre = require("hardhat");

async function main() {

  const [owner, user1] = await hre.ethers.getSigners();
  const Monster = await hre.ethers.getContractFactory("Monsters");
  const monster = await Monster.deploy();

  const MonsterGame = await hre.ethers.getContractFactory("MonsterGame");
  const monsterGame=  await MonsterGame.deploy();

  const Items = await hre.ethers.getContractFactory("Items");
  const items = await Items.deploy(monsterGame.address);

  await monster.deployed();
  await monsterGame.deployed();
  await items.deployed();

  await monsterGame.setInterface(monster.address, items.address)

  // console.log("Monster NFT deployed to:", monster.address);
  // console.log("Monster Game deployed to:", monsterGame.address);
  // console.log("Items deployed to:", items.address);

  console.log("===Mint Monster NFT======");

  const price = (3 * 0.002).toString();
  await monster.connect(user1).summon(3, {value: hre.ethers.utils.parseEther(price)});

  console.log("")
  console.log("Minting Succeeded !");
  console.log("")

  const balance = await monster.balanceOf(user1.address);
  const monsters = await monster.getMyMonster(user1.address);

  console.log("Monsters owned by user 1: " + monsters + " (" + balance + " monsters)");
  console.log("")

  console.log("=== Send monster to missions=======");
  console.log("");

  const monster0 = await monster.monsterStats(0);

  console.log("Monster 0 stats before mission : " + monster0);

  await monsterGame.connect(user1).beginnerMission(0, user1.address);

  console.log("");
  console.log("Sending Monster 0 to mission...")
  console.log("");

  await monsterGame.claimBeginnerMission(0, user1.address);
  const monster0After = await monster.monsterStats(0);

  console.log("Monster 0 stats after mission : " + monster0After);
  console.log("");

  const inventory0 = await monsterGame.playerInventory(user1.address, 0);
  const inventory1 = await monsterGame.playerInventory(user1.address, 1);
  
  console.log("User 1 inventory after mission: " + "( "+ inventory0 +" "+ inventory1+" )");






}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
