import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import MonsterGameABI from "../src/api/MonsterGame.json";
import MonsterABI from "../src/api/Monsters.json";

const MonsterGameContract = "0x6F02cf9223849358d81ff344DAb465a66Cd067d9";
const MonsterContract = "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35";
const MissionsModal = ({
  showBeginner,
  showInter,
  setShowBeginner,
  setShowInter,
}) => {
  const [onMission, setOnMission] = useState([]);
  const [monsters, setMonsters] = useState([]);

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
    if (!showInter) {
      await monsterGameContract
        .getMonstersOnBeg(signer.getAddress())
        .then((response) => {
          setOnMission(response);
        });
    } else {
      await monsterGameContract
        .getMonstersOnInt(signer.getAddress())
        .then((response) => {
          setOnMission(response);
        });
    }
  }

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
    console.log(monsters);
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
          <button
            className="btn btn-danger"
            onClick={() => setShowBeginner(false)}
          >
            Back
          </button>
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
            <div className="row justify-content-center">
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Your Monsters
                </h4>
                <div className="row justify-content-center">
                  {monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-text">
                      No Monsters in Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div className="card col-3 mx-1" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
                          <h5 className="card-title">{monster.toString()}</h5>
                          <button
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
                <div className="row justify-content-center">
                  {onMission.length < 1 ? (
                    <h5 id="modal-title" className="text-center">
                      No Monsters on Mission
                    </h5>
                  ) : (
                    onMission.map((monster, index) => (
                      <div className="card col-3 mx-1" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
                          <h5 className="card-title">
                            {monster.tokenId.toString()}
                          </h5>
                          <button
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
          <button
            className="btn btn-danger"
            onClick={() => setShowInter(false)}
          >
            {" "}
            Back
          </button>
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
                <div className="row justify-content-center">
                  {monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No Monsters in Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div className="card col-3 mx-1" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
                          <h5 className="card-title">{monster.toString()}</h5>
                          <button
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
                <div className="row justify-content-center">
                  {onMission.length < 1 ? (
                    <h5 id="modal-title" className="text-center">
                      No Monsters on Mission
                    </h5>
                  ) : (
                    onMission.map((monster, index) => (
                      <div className="card col-3 mx-1" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
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
