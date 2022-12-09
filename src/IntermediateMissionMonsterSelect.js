import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import { toast } from "react-toastify";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";

const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const IntermediateMissionMonsterSelect = ({
  showInterMediateSelect,
  setShowInterMediateSelect,
  monsterSelected,
  setMonsterSelected,
}) => {
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
    setLoadingMonster(true);
    await monsterContract.getMyMonster(signer.getAddress()).then((monsters) => {
      for (let i = 0; i < monsters.length; i++) {
        monsterContract.getMonsterStatus(monsters[i]).then((status) => {
          if (status.toString() === "0") {
            setMonsters((currentMonsters) => [...currentMonsters, monsters[i]]);
          }
        });
      }
    });
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
          toast.error("Monster #" + monster + " already selected", {
            autoClose: 2000,
          });
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
  if (!showInterMediateSelect) return;
  return (
    <>
      <motion.div
        className="container-fluid"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ type: "tween", duration: 0.25 }}
      >
        <div className="row justify-content-center">
          <div className="col-8">
            <h4 id="modal-title" className="text-center">
              Select Your Monsters
            </h4>
            <div
              id="monsters-container"
              className="d-flex justify-content-center align-items-center flex-wrap"
            >
              <div className="d-flex justify-content-center align-items-center flex-wrap">
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
                      key={index}
                      className="card col-3 m-2 d-flex justify-content-center align-items-center"
                      style={{ backgroundColor: "#D8CCA3" }}
                      onClick={() => selectMonster(index)}
                    >
                      <img src="/monster.png" width={"50%"} alt="..." />
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
            <div className="row justify-content-center align-items-start">
              <h4 className="text-center" id="modal-title">
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

export default IntermediateMissionMonsterSelect;
