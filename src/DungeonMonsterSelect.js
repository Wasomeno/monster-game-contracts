import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import { toast } from "react-toastify";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";
// import env from "./helpers/env";

const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const DungeonMonsterSelect = ({
  showDungeonSelect,
  setShowDungeonSelect,
  dungeonSelected,
  setDungeonSelected,
}) => {
  const [monsters, setMonsters] = useState([]);
  const [loadingMonster, setLoadingMonster] = useState(false);
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
    for (let monster of myMonsters) {
      const status = await monsterContract.getMonsterStatus(monster);
      if (status.toString() === "0") {
        const level = await monsterContract.getMonsterLevel(monster);
        const exp = await monsterContract.getMonsterExp(monster);
        const expCap = await monsterContract.getMonsterExpCap(monster);
        const hunger = await monsterContract.getMonsterHunger(monster);
        monstersTemp.push({
          id: monster.toString(),
          level: level.toString(),
          exp: exp.toString(),
          expCap: expCap.toString(),
          hunger: hunger.toString(),
        });
      }
    }
    setMonsters(monstersTemp);
    setLoadingMonster(false);
  }
  function checkSelectedMonsters(monster) {
    let result = true;
    if (dungeonSelected.length < 1) {
      setDungeonSelected((currentSelected) => [...currentSelected, monster]);
    } else {
      for (let i = 0; i < dungeonSelected.length; i++) {
        if (monster === dungeonSelected[i]) {
          result = false;
          toast.error("Monster #" + monster + " already selected", {
            autoClose: 2000,
          });
        }
      }
      return result;
    }
    console.log(dungeonSelected);
  }

  function selectMonster(index) {
    if (dungeonSelected.length >= 6) return;
    let monster = monsters[index];
    let result = checkSelectedMonsters(monster.id.toString());
    if (!result) return;
    setDungeonSelected((currentSelected) => [
      ...currentSelected,
      monster.id.toString(),
    ]);
  }

  function deselectMonster(index) {
    let monster = dungeonSelected[index];
    setDungeonSelected((currentSelected) =>
      currentSelected.filter((monsterSelected) => monsterSelected !== monster)
    );
  }

  useEffect(() => {
    getMonsters();
  }, []);

  if (!showDungeonSelect) return;
  return (
    <div className="row justify-content-center">
      <div className="col-8">
        <h3 id="modal-title" className="text-center">
          Select Your Monsters
        </h3>
        <div
          id="monsters-container"
          className="d-flex flex-wrap justify-content-center"
        >
          <div className="d-flex flex-wrap justify-content-center">
            {loadingMonster ? (
              <MoonLoader size={50} loading={loadingMonster} />
            ) : monsters.length < 1 ? (
              <h5 className="text-center" id="modal-title">
                No Monsters in Inventory
              </h5>
            ) : (
              monsters.map((monster, index) => (
                <>
                  <div
                    className="card col-3 d-flex m-2 justify-content-center align-items-center"
                    key={index}
                    style={{ backgroundColor: "#D8CCA3" }}
                    onClick={() => selectMonster(index)}
                  >
                    <img src="/monster.png" width={"50%"} alt="..." />
                    <div className="card-body py-1 text-center">
                      <h5 className="card-title" id="modal-title">
                        Monster #{monster.id}
                      </h5>
                      <div className="">
                        <h5 style={{ fontFamily: "Monogram" }}>
                          Level : {monster.level} / 10;
                        </h5>
                        <h5 style={{ fontFamily: "Monogram" }}>
                          Exp : {monster.exp} / {monster.expCap};
                        </h5>
                        <h5 style={{ fontFamily: "Monogram" }}>
                          Hunger : {monster.hunger} / 100;
                        </h5>
                      </div>
                    </div>
                  </div>
                </>
              ))
            )}
            <div className="col-4 m-2" />
          </div>
        </div>
      </div>
      <div className="col">
        <div className="row justify-content-center align-items-start">
          <h4 className="text-center" id="modal-title">
            {dungeonSelected.length} Monster Selected
          </h4>
        </div>
        <div className="row flex-column justify-content-start align-items-center">
          {dungeonSelected.map((monster, index) => (
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
                {dungeonSelected[index] !== undefined ? monster : <h6> + </h6>}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default DungeonMonsterSelect;
