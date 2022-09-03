import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
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

  useEffect(() => {
    getMonsters();
  }, []);
  if (!showInterMediateSelect) return;
  return (
    <div>
      <div className="row justify-content-center">
        <div className="col">
          <h4 id="modal-title" className="text-center">
            Your Monster
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
                    className="card col-4 m-2 d-flex justify-content-center align-items-center"
                    style={{ backgroundColor: "#D8CCA3" }}
                    key={index}
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
      </div>
    </div>
  );
};

export default IntermediateMissionMonsterSelect;
