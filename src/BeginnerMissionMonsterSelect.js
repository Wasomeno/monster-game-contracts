import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";

const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const BeginnerMissionMonsterSelect = ({
  showBeginnerSelect,
  setShowBeginnerSelect,
  monsterSelected,
  setMonsterSelected,
}) => {
  const [onMission, setOnMission] = useState([]);
  const [monsters, setMonsters] = useState([]);
  const [loadingMonster, setLoadingMonster] = useState(false);
  const [loadingOnMission, setLoadingOnMission] = useState(false);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );

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

  function checkSelectedMonsters(monster) {
    let result = true;
    if (monsterSelected.length < 1) {
      setMonsterSelected((currentSelected) => [...currentSelected, monster]);
    } else {
      for (let i = 0; i < monsterSelected.length; i++) {
        if (monster === monsterSelected[i]) {
          result = false;
        }
      }
      return result;
    }
    console.log(monsterSelected);
  }

  function selectMonster(index) {
    if (monsterSelected.length >= 6) return;
    let monster = monsters[index];
    let result = checkSelectedMonsters(monster.toString());
    if (!result) return;
    setMonsterSelected((currentSelected) => [
      ...currentSelected,
      monster.toString(),
    ]);
  }

  function deselectMonster(index) {
    let monster = monsterSelected[index];
    setMonsterSelected((currentSelected) =>
      currentSelected.filter((monsterSelected) => monsterSelected !== monster)
    );
  }

  useEffect(() => {
    getMonsters();
  }, []);
  if (!showBeginnerSelect) return;
  return (
    <>
      <motion.div
        className="container w-75 h-75"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ type: "tween", duration: 0.25 }}
      >
        <div className="row justify-content-center">
          <div className="col-8">
            <h4 id="modal-title" className="text-center">
              Your Monsters
            </h4>
            <div
              id="monsters-container"
              className="d-flex 
                  justify-content-center align-items-center flex-wrap"
            >
              <div
                className="d-flex 
                  justify-content-center flex-wrap"
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
                      className="card col-4 m-2 d-flex justify-content-center align-items-center shadow-sm"
                      key={index}
                      style={{ backgroundColor: "#D8CCA3" }}
                      onClick={() => selectMonster(index)}
                    >
                      <img src="/monster.png" alt="..." width={"50%"} />
                      <div className="card-body text-center py-1">
                        <h5 className="card-title" id="modal-title">
                          Monster #{monster.toString()}
                        </h5>
                      </div>
                    </div>
                  ))
                )}
                <div className="col-4 m-2" />
              </div>
            </div>
          </div>
          <div className="col">
            <div className="row justify-content-center align-items-center">
              <h4 className="p-3 text-center" id="modal-title">
                {monsterSelected.length} Monster Selected
              </h4>
            </div>
            <div className="row flex-column justify-content-start align-items-center">
              {monsterSelected.map((monster, index) => (
                <div
                  key={index}
                  className="p-2 my-2 text-cnter d-flex justify-content-center align-items-start"
                >
                  <button
                    className="btn btn-danger rounded-circle"
                    onClick={() => deselectMonster(index)}
                  >
                    X
                  </button>
                  <div
                    className="p-2 my-2 text-cnter d-flex justify-content-center align-items-center"
                    style={{
                      backgroundColor: "#D8CCA3",
                      width: "4rem",
                      height: "4rem",
                    }}
                  >
                    {monsterSelected[0] !== undefined ? monster : <h6> + </h6>}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </motion.div>
    </>
  );
};

export default BeginnerMissionMonsterSelect;
