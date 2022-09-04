import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import MonsterGameABI from "../src/api/MonsterGame.json";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";
import BeginnerMissionMonsterSelect from "./BeginnerMissionMonsterSelect";
import IntermediateMissionMonsterSelect from "./IntermediateMissionMonsterSelect";

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
  const [loadingOnMission, setLoadingOnMission] = useState(false);
  const [beginnerSelected, setBeginnerSelected] = useState([]);
  const [interSelected, setInterSelected] = useState([]);
  const [showBeginnerSelect, setShowBeginnerSelect] = useState(false);
  const [showInterMediateSelect, setShowInterMediateSelect] = useState(false);

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

  async function sendToBeginner(monster) {
    await monsterGameContract
      .beginnerMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
        });
      });
  }

  async function claimBeginner(monster) {
    await monsterGameContract
      .claimBeginnerMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
        });
      });
  }

  async function sendToIntermediate(monster) {
    await monsterGameContract
      .intermediateMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
        });
      });
  }

  async function claimIntermediate(monster) {
    await monsterGameContract
      .claimIntermediateMission(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnMissions();
        });
      });
  }

  useEffect(() => {
    getMonstersOnMissions();
  }, []);
  if (!showBeginner && !showInter) return;
  return (
    <>
      {showBeginner ? (
        <>
          <img
            src="/back_icon.png"
            onClick={() =>
              showBeginnerSelect
                ? setShowBeginnerSelect(false)
                : setShowBeginner(false)
            }
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
            {!showBeginnerSelect ? (
              <>
                <div className="row justify-content-center">
                  <h2 id="modal-title" className="text-center">
                    Beginner Mission
                  </h2>
                </div>
                <div className="row justify-content-center">
                  <div className="col-6 text-center border border-2 border-dark rounded">
                    <h5 id="modal-title" className="py-2">
                      Beginner mission will give you less rewards than
                      intermediate mission. But there's no level requirement
                      when sending monster to beginner mission. So start sending
                      your monsters to beginner mission until they hit the
                      requirement level for intermediate mission.
                    </h5>
                  </div>
                </div>
                <div className="row justify-content-center my-3">
                  <div className="p-3 col-6 d-flex justify-content-center align-items-center border border-dark border-2 rounded">
                    {beginnerSelected.length !== 0 ? (
                      beginnerSelected.map((monster, index) => (
                        <div
                          key={index}
                          className="p-2 mx-2 text-center d-flex justify-content-center align-items-center"
                          style={{
                            backgroundColor: "#D8CCA3",
                            width: "4rem",
                            height: "4rem",
                          }}
                        >
                          {monster}
                        </div>
                      ))
                    ) : (
                      <h5 id="modal-title">No Monsters Selected</h5>
                    )}
                  </div>
                </div>
                <div className="row justify-content-center p-2 my-3">
                  <button
                    style={{ fontSize: "20px", fontFamily: "Monogram" }}
                    className="btn btn-primary p-2 col-3 m-2"
                    onClick={() => setShowBeginnerSelect(true)}
                  >
                    Select Monsters
                  </button>
                  {onMission.length < 1 ? (
                    <button
                      style={{ fontSize: "20px", fontFamily: "Monogram" }}
                      className="btn btn-success p-2 col-3 m-2"
                    >
                      Send Monsters
                    </button>
                  ) : (
                    <button
                      style={{ fontSize: "20px", fontFamily: "Monogram" }}
                      className="btn btn-danger p-2 col-3 m-2"
                    >
                      Bring back Monsters
                    </button>
                  )}
                </div>
              </>
            ) : (
              <BeginnerMissionMonsterSelect
                showBeginnerSelect={showBeginnerSelect}
                setShowBeginnerSelect={setShowBeginnerSelect}
                monsterSelected={beginnerSelected}
                setMonsterSelected={setBeginnerSelected}
              />
            )}
          </motion.div>
        </>
      ) : (
        <>
          <img
            src="/back_icon.png"
            onClick={() =>
              showInterMediateSelect
                ? setShowInterMediateSelect(false)
                : setShowInter(false)
            }
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
            {!showInterMediateSelect ? (
              <>
                <div className="row justify-content-center">
                  <h2 id="modal-title" className="text-center">
                    Intermediate Mission
                  </h2>
                </div>
                <div className="row justify-content-center">
                  <div className="col-6 text-center border border-2 border-dark rounded">
                    <h5 id="modal-title" className="py-2">
                      Intermediate mission will give you more rewards than
                      beginner mission. There's level requirement when sending
                      monster to intermediate mission. Make sure your monsters
                      match the required level.
                    </h5>
                  </div>
                </div>
                <div className="row justify-content-center my-3">
                  <div className="p-3 col-6 d-flex justify-content-center align-items-center border border-dark border-2 rounded">
                    {interSelected.length !== 0 ? (
                      interSelected.map((monster, index) => (
                        <div
                          key={index}
                          className="p-2 mx-2 text-center d-flex justify-content-center align-items-center"
                          style={{
                            backgroundColor: "#D8CCA3",
                            width: "4rem",
                            height: "4rem",
                          }}
                        >
                          {monster}
                        </div>
                      ))
                    ) : (
                      <h5 id="modal-title">No Monsters Selected</h5>
                    )}
                  </div>
                </div>
                <div className="row justify-content-center p-2 my-3">
                  <button
                    style={{ fontSize: "20px", fontFamily: "Monogram" }}
                    className="btn btn-primary p-2 col-3 m-2"
                    onClick={() => setShowInterMediateSelect(true)}
                  >
                    Select Monsters
                  </button>
                  {onMission.length < 1 ? (
                    <button
                      className="btn btn-success col-3 m-2"
                      style={{ fontSize: "20px", fontFamily: "Monogram" }}
                    >
                      Send Monsters
                    </button>
                  ) : (
                    <button
                      style={{ fontSize: "20px", fontFamily: "Monogram" }}
                      className="btn btn-danger col-3 m-2"
                    >
                      Bring back Monsters
                    </button>
                  )}
                </div>
              </>
            ) : (
              <IntermediateMissionMonsterSelect
                showInterMediateSelect={showInterMediateSelect}
                setShowInterMediateSelect={setShowInterMediateSelect}
                monsterSelected={interSelected}
                setMonsterSelected={setInterSelected}
              />
            )}
          </motion.div>
        </>
      )}
    </>
  );
};

export default MissionsModal;
