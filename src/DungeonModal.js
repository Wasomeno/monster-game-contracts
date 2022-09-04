import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import ReactDom from "react-dom";
import MissionsModal from "./MissionsModal";
import DungeonABI from "../src/api/Dungeon.json";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";
import DungeonMonsterSelect from "./DungeonMonsterSelect";

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
  const [showDungeonSelect, setShowDungeonSelect] = useState(false);
  const [onDungeon, setOnDungeon] = useState([]);
  const [dungeonSelected, setDungeonSelected] = useState([]);
  const [loadingOnDungeon, setLoadingOnDungeon] = useState(false);

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const dungeonContract = new ethers.Contract(
    DungeonContract,
    DungeonABI.abi,
    signer
  );
  async function getMonstersOnDungeon() {
    setLoadingOnDungeon(true);
    await dungeonContract
      .getMyMonsters(signer.getAddress())
      .then((response) => {
        setOnDungeon(response);
      });
    console.log(onDungeon);
    setLoadingOnDungeon(false);
  }

  async function sendToBossFight(monster) {
    await dungeonContract
      .bossFight(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnDungeon();
        });
      });
  }

  async function claimBossFight(monster) {
    await dungeonContract
      .claimBossFight(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonstersOnDungeon();
        });
      });
  }

  useEffect(() => {
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
            <img
              src="/back_icon.png"
              onClick={() =>
                showDungeonSelect
                  ? setShowDungeonSelect(false)
                  : setShowDungeon(false)
              }
              width={"45px"}
              alt="back-img"
            />
            {showDungeonSelect ? (
              <DungeonMonsterSelect
                showDungeonSelect={showDungeonSelect}
                setShowDungeonSelect={setShowDungeonSelect}
                dungeonSelected={dungeonSelected}
                setDungeonSelected={setDungeonSelected}
              />
            ) : (
              <>
                <div className="row justify-content-center">
                  <h2 className="text-center" id="modal-title">
                    Dungeon
                  </h2>
                </div>
                <div className="row justify-content-center">
                  <div className="col-6 text-center border border-2 border-dark rounded">
                    <h5 className="py-2" id="modal-title">
                      Send your monsters to fight bosses in the dungeon.Dungeon
                      will give better rewards than the missions. There's a
                      percentage of what reward that you can get based on the
                      level of your monster. So no level requirement but the
                      higher the level of a monster will increase the chances of
                      getting better rewards.
                    </h5>
                  </div>
                </div>
                <div className="row justify-content-center my-3">
                  <div className="p-3 col-6 d-flex justify-content-center align-items-center border border-dark border-2 rounded">
                    {dungeonSelected.length !== 0 ? (
                      dungeonSelected.map((monster, index) => (
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
                    onClick={() => setShowDungeonSelect(true)}
                  >
                    Select Monsters
                  </button>
                  {onDungeon.length < 1 ? (
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
            )}
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
                <div className="row justify-center align-items-center">
                  <h2 id="modal-title" className="text-center">
                    Missions
                  </h2>
                </div>
                <div className="row justify-content-center">
                  <div className="col-6 text-center border border-2 border-dark rounded">
                    <h5 id="modal-title" className="py-2">
                      Send your monsters to a mission! you can choose between
                      beginner mission and intermediate mission. The rewards
                      between beginner and intermediate mission will be
                      different, the intermediate one of course will reward you
                      more. But there's a level 3 requirement for your monsters
                      to enter the intermediate mission.
                    </h5>
                  </div>
                </div>
                <div className="row justify-content-center my-3 p-2">
                  <div className="col-6 d-flex justify-content-between ">
                    <button
                      id="beginner-mission-button"
                      className="btn btn-success border border-2 border-dark col-5"
                      onClick={() => setShowBeginner(true)}
                    >
                      Beginner Mission
                    </button>
                    <button
                      id="intermediate-mission-button"
                      className="btn btn-success border border-2 border-dark col-5"
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
