import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import ReactDom from "react-dom";
import MissionsModal from "./MissionsModal";
import DungeonABI from "../src/api/Dungeon.json";
import MonsterABI from "../src/api/Monsters.json";

const DungeonContract = "0x4f46037fEffa0433E013b77d131019b02042197A";
const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const DungeonModal = ({
  showDungeon,
  showMission,
  setShowDungeon,
  setShowMission,
}) => {
  const [showBeginner, setShowBeginner] = useState(false);
  const [showInter, setShowInter] = useState(false);
  const [monsters, setMonsters] = useState([]);
  const [onDungeon, setOnDungeon] = useState([]);

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const dungeonContract = new ethers.Contract(
    DungeonContract,
    DungeonABI.abi,
    signer
  );
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );

  async function getMonsters() {
    let monstersTemp = [];
    const myMonsters = await monsterContract.getMyMonster(signer.getAddress());
    for (let i = 0; i < myMonsters.length; i++) {
      const status = await monsterContract.getMonsterStatus(myMonsters[i]);
      if (status.toString() === "0") {
        monstersTemp.push(myMonsters[i]);
      }
    }
    setMonsters(monstersTemp);
  }

  async function getMonstersOnDungeon() {
    await dungeonContract
      .getMyMonsters(signer.getAddress())
      .then((response) => {
        setOnDungeon(response);
      });
    console.log(onDungeon);
  }

  async function sendToBossFight(monster) {
    await dungeonContract
      .bossFight(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonsters();
          getMonstersOnDungeon();
        });
      });
  }

  async function claimBossFight(monster) {
    await dungeonContract
      .claimBossFight(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonsters();
          getMonstersOnDungeon();
        });
      });
  }

  useEffect(() => {
    getMonsters();
    getMonstersOnDungeon();
  }, []);

  if (!showDungeon && !showMission) return;
  return ReactDom.createPortal(
    <>
      {showDungeon ? (
        <>
          <motion.div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowDungeon(false)}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          />
          <motion.div
            id="shop-modal"
            className="container w-75 h-75"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 className="text-center" id="modal-title">
                Dungeon
              </h2>
              <div className="col">
                <h3 id="modal-title" className="text-center">
                  Your Monster
                </h3>
                <div className="row justify-content-center">
                  {monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No Monsters in Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div className="card col-3 mx-1" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="d-flex flex-column justify-content-center">
                          <h5 className="card-title text-center col">
                            {monster.toString()}
                          </h5>
                          <button
                            className="btn btn-success text-center col m-3"
                            onClick={() => sendToBossFight(monster)}
                          >
                            Send
                          </button>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </div>
              <div className="col">
                <h3 id="modal-title" className="text-center">
                  Monster on Dungeon
                </h3>
                <div className="row justify-content-center">
                  {onDungeon.length < 1 ? (
                    <h5 id="modal-title" className="text-center">
                      No Monster on Dungeon
                    </h5>
                  ) : (
                    onDungeon.map((monster, index) => (
                      <div className="card col-3 mx-1" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
                          <h5 className="card-title text-center">
                            {monster.tokenId.toString()}
                          </h5>
                          <button
                            className="btn btn-danger"
                            onClick={() => claimBossFight(monster.tokenId)}
                          >
                            Home
                          </button>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </div>
            </div>
          </motion.div>
        </>
      ) : (
        <>
          <motion.div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowMission(false)}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          />
          <motion.div
            id="shop-modal"
            className="container w-75 h-75"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            {!showBeginner && !showInter ? (
              <motion.div
                className="container h-100 w-100"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ type: "tween", duration: 0.25 }}
              >
                <div className="row justify-center align-items-center h-25">
                  <h2 id="modal-title" className="text-center">
                    Missions
                  </h2>
                </div>
                <div className="row justify-content-center">
                  <div className="col-3 d-flex justify-content-center">
                    <button
                      id="missions-button"
                      className="btn btn-primary"
                      onClick={() => setShowBeginner(true)}
                    >
                      Beginner Mission
                    </button>
                  </div>
                  <div className="col-3 d-flex justify-content-center">
                    <button
                      id="missions-button"
                      className="btn btn-primary"
                      onClick={() => setShowInter(true)}
                    >
                      Intermediate Mission
                    </button>
                  </div>
                </div>
              </motion.div>
            ) : (
              <MissionsModal
                showBeginner={showBeginner}
                showInter={showInter}
                setShowBeginner={setShowBeginner}
                setShowInter={setShowInter}
              />
            )}
          </motion.div>
        </>
      )}
    </>,
    document.getElementById("modal")
  );
};

export default DungeonModal;
