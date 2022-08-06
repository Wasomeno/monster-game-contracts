import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import MonsterGameABI from "../src/api/MonsterGame.json";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";

const MonsterGameContract = "0x697049b6FcFDa75dE7bA4FBd9C364382c745BF8C";
const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";
const MissionsModal = ({
  showBeginner,
  showInter,
  setShowBeginner,
  setShowInter,
}) => {
  const [onMission, setOnMission] = useState([]);
  const [monsters, setMonsters] = useState([]);
  const [loadingMonster, setLoadingMonster] = useState(false);
  const [loadingOnMission, setLoadingOnMission] = useState(false);

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterGameContract = new ethers.Contract(
    MonsterGameContract,
    MonsterGameABI.abi,
    signer
  );
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );

  async function getMonstersOnMissions() {
    setLoadingOnMission(true);
    if (!showInter) {
      await monsterGameContract
        .getMonstersOnBeginner(signer.getAddress())
        .then((response) => {
          setOnMission(response);
        });
      setLoadingOnMission(false);
    } else {
      await monsterGameContract
        .getMonstersOnIntermediate(signer.getAddress())
        .then((response) => {
          setOnMission(response);
        });
      setLoadingOnMission(false);
    }
  }

  async function getMonsters() {
    let monstersTemp = [];
    setLoadingMonster(true);
    const myMonsters = await monsterContract.getMyMonster(signer.getAddress());
    for (let i = 0; i < myMonsters.length; i++) {
      const status = await monsterContract.getMonsterStatus(myMonsters[i]);
      if (status.toString() === "0") {
        monstersTemp.push(myMonsters[i]);
      }
    }
    setMonsters(monstersTemp);
    setLoadingMonster(false);
  }

  async function sendToBeginner(monster) {
    await monsterGameContract
      .beginnerMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
          getMonsters();
        });
      });
  }

  async function claimBeginner(monster) {
    await monsterGameContract
      .claimBeginnerMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
          getMonsters();
        });
      });
  }

  async function sendToIntermediate(monster) {
    await monsterGameContract
      .intermediateMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
          getMonsters();
        });
      });
  }

  async function claimIntermediate(monster) {
    await monsterGameContract
      .claimIntermediateMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
          getMonsters();
        });
      });
  }

  useEffect(() => {
    getMonstersOnMissions();
    getMonsters();
  }, []);
  if (!showBeginner && !showInter) return;
  return (
    <>
      {showBeginner ? (
        <>
          <img
            src="/back_icon.png"
            onClick={() => setShowBeginner(false)}
            width={"45px"}
            alt="back-img"
          />
          <motion.div
            className="container"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 id="modal-title" className="text-center">
                Beginner Mission
              </h2>
            </div>
            <div className="row justify-content-center h-100">
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Your Monsters
                </h4>
                <div
                  id="monsters-container"
                  className="d-flex justify-content-center align-items-center flex-wrap mb-5"
                >
                  {loadingMonster ? (
                    <MoonLoader
                      loading={loadingMonster}
                      size={50}
                      color={"#8E3200"}
                    />
                  ) : monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No Monsters in Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div
                        className="card col-4 m-1 d-flex justify-content-center align-items-center shadow-sm"
                        key={index}
                        style={{ backgroundColor: "#D8CCA3" }}
                      >
                        <img src="/monster.png" alt="..." width={"50%"} />
                        <div className="card-body text-center py-1">
                          <h5 className="card-title" id="modal-title">
                            Monster #{monster.toString()}
                          </h5>
                          <button
                            id="modal-title"
                            className="btn btn-success"
                            onClick={() => sendToBeginner(monster)}
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
                <h4 id="modal-title" className="text-center">
                  Monster on Mission
                </h4>
                <div
                  id="monsters-container"
                  className="d-flex justify-content-center align-items-center flex-wrap"
                >
                  {loadingOnMission ? (
                    <MoonLoader
                      loading={loadingOnMission}
                      size={50}
                      color={"#8E3200"}
                    />
                  ) : onMission.length < 1 ? (
                    <h5 id="modal-title" className="text-center">
                      No Monsters on Mission
                    </h5>
                  ) : (
                    onMission.map((monster, index) => (
                      <div
                        className="card col-4 m-1 d-flex justify-content-center align-items-center"
                        key={index}
                        style={{ backgroundColor: "#D8CCA3" }}
                      >
                        <img
                          src="/monster.png"
                          width={"50%"}
                          alt="monster-img"
                        />
                        <div className="card-body text-center py-1">
                          <h5 className="card-title" id="modal-title">
                            Monster #{monster.tokenId.toString()}
                          </h5>
                          <button
                            id="modal-title"
                            className="btn btn-danger"
                            onClick={() => claimBeginner(monster.tokenId)}
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
          <img
            src="/back_icon.png"
            onClick={() => setShowInter(false)}
            width={"45px"}
            alt="back-img"
          />
          <motion.div
            className="container"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 id="modal-title" className="text-center">
                Intermediate Mission
              </h2>
            </div>
            <div className="row justify-content-center">
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Your Monster
                </h4>
                <div
                  id="monsters-container"
                  className="d-flex justify-content-center align-items-center flex-wrap"
                >
                  {loadingMonster ? (
                    <MoonLoader
                      size={50}
                      loading={loadingMonster}
                      color={"#8E3200"}
                    />
                  ) : monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No Monsters in Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div
                        className="card col-4 m-1 d-flex justify-content-center align-items-center"
                        style={{ backgroundColor: "#D8CCA3" }}
                        key={index}
                      >
                        <img src="/monster.png" width={"50%"} alt="..." />
                        <div className="card-body text-center py-1">
                          <h5 className="card-title" id="modal-title">
                            Monster #{monster.toString()}
                          </h5>
                          <button
                            id="modal-title"
                            className="btn btn-success"
                            onClick={() => sendToIntermediate(monster)}
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
                <h4 id="modal-title" className="text-center">
                  Monster on Mission
                </h4>
                <div className="d-flex justify-content-center align-items-center flex-wrap">
                  {loadingOnMission ? (
                    <MoonLoader
                      size={50}
                      loading={loadingOnMission}
                      color={"#8E3200"}
                    />
                  ) : onMission.length < 1 ? (
                    <h5 id="modal-title" className="text-center">
                      No Monsters on Mission
                    </h5>
                  ) : (
                    onMission.map((monster, index) => (
                      <div
                        className="card col-4 m-1 d-flex justify-content-center align-items-center"
                        key={index}
                        style={{ backgroundColor: "#D8CCA3" }}
                      >
                        <img
                          src="/monster.png"
                          alt="monster-img"
                          width={"50%"}
                        />
                        <div className="card-body py-1">
                          <h5 className="card-title">
                            {monster.tokenId.toString()}
                          </h5>
                          <button
                            className="btn btn-danger"
                            onClick={() => claimIntermediate(monster.tokenId)}
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
      )}
    </>
  );
};

export default MissionsModal;
