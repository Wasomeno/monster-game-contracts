import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import { BigNumber, ethers } from "ethers";
import { motion } from "framer-motion";
import MonsterABI from "../src/api/Monsters.json";
import NurseryABI from "../src/api/Nursery.json";
import MoonLoader from "react-spinners/MoonLoader";

const NurseryContract = "0xCe1641A6d54F67859AF935164E6Aa1F1Bd1a463A";
const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const NurseryModal = ({
  showShop,
  showNursery,
  setShowNursery,
  setShowShop,
}) => {
  const [monsters, setMonsters] = useState([]);
  const [onNursery, setOnNursery] = useState([]);
  const [duration, setDuration] = useState([]);
  const [loadingMonster, setLoadingMonster] = useState(false);
  const [loadingOnNursery, setLoadingOnNursery] = useState(false);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );
  const nurseryContract = new ethers.Contract(
    NurseryContract,
    NurseryABI.abi,
    signer
  );

  async function sendToNursery(monster, index) {
    const price = 100000 * duration[index];
    const durationBigInt = BigNumber.from(duration[index]);
    await nurseryContract
      .putOnNursery(monster, signer.getAddress(), durationBigInt, {
        value: ethers.utils.parseUnits(price.toString(), "gwei"),
      })
      .then((response) => {
        provider.waitForTransaction(response.hash).then(() => {
          getMonsters();
          getOnNursery();
        });
      });
  }

  async function goBackHome(monster) {
    await nurseryContract
      .goBackHome(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then((response) => {
          getMonsters();
          getOnNursery();
        });
      });
  }

  async function getMonsters() {
    let monstersTemp = [];
    let durations = [];
    setLoadingMonster(true);
    const myMonsters = await monsterContract.getMyMonster(signer.getAddress());
    for (let i = 0; i < myMonsters.length; i++) {
      const status = await monsterContract.getMonsterStatus(myMonsters[i]);
      durations.push(1);
      if (status.toString() === "0") {
        monstersTemp.push(myMonsters[i]);
      }
    }
    setDuration(durations);
    setMonsters(monstersTemp);
    setLoadingMonster(false);
  }

  async function getOnNursery() {
    setLoadingOnNursery(true);
    await nurseryContract
      .getMyMonsters(signer.getAddress())
      .then((response) => {
        setOnNursery(response);
      });
    setLoadingOnNursery(false);
  }

  const increment = (index) => {
    let test = [...duration];
    if (test[index] >= 5) return;
    test[index] = test[index] + 1;
    setDuration(test);
  };

  const decrement = (index) => {
    let test = [...duration];
    if (test[index] <= 1) return;
    test[index] = test[index] - 1;
    setDuration(test);
  };

  useEffect(() => {
    getMonsters();
    getOnNursery();
  }, []);

  if (!showNursery && !showShop) return;
  return ReactDom.createPortal(
    <>
      {showNursery ? (
        <>
          <motion.div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowNursery(false)}
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
                Nursery
              </h2>
            </div>
            <div className="row justify-content-center">
              <div className="col">
                <h4 className="text-center" id="modal-title">
                  Your Monster
                </h4>
                <div
                  id="monsters-container"
                  className="d-flex justify-content-center flex-wrap"
                >
                  {loadingMonster ? (
                    <MoonLoader size={50} loading={loadingMonster} />
                  ) : monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No monster on Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div
                        className="card col-4 m-1 text-center d-flex justify-content-center align-items-center"
                        key={index}
                        style={{ backgroundColor: "#D8CCA3" }}
                      >
                        <img
                          src="/monster.png"
                          width={"50%"}
                          alt="monster-img"
                        />
                        <div className="card-body py-1 text-center">
                          <h5
                            className="card-title text-center"
                            id="modal-title"
                          >
                            Monster #{monster.toString()}
                          </h5>
                          <div className="d-flex justify-content-center">
                            <button
                              className="btn btn-danger col"
                              onClick={() => decrement(index)}
                            >
                              -
                            </button>
                            <input
                              type="text"
                              className="form-control text-center col"
                              value={duration[index]}
                              name={index}
                            />
                            <button
                              className="btn btn-success col"
                              onClick={() => increment(index)}
                            >
                              +
                            </button>
                          </div>

                          <button
                            id="modal-title"
                            className="btn btn-success m-3"
                            onClick={() => sendToNursery(monster, index)}
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
                <h4 className="text-center" id="modal-title">
                  Monsters on Nursery
                </h4>
                <div className="d-flex justify-content-center flex-wrap">
                  {loadingOnNursery ? (
                    <MoonLoader size={50} loading={loadingOnNursery} />
                  ) : onNursery.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No Monsters on Nursery
                    </h5>
                  ) : (
                    onNursery.map((monster, index) => (
                      <div
                        className="card col-4 d-flex justify-content-center align-items-center"
                        key={index}
                        style={{ backgroundColor: "#D8CCA3" }}
                      >
                        <img src="/monster.png" width={"50%"} alt="..." />
                        <div className="card-body text-center py-1">
                          <h5 className="card-title" id="modal-title">
                            Monster #{monster.monster.toString()}
                          </h5>
                          <button
                            id="modal-title"
                            className="btn btn-danger"
                            onClick={() => goBackHome(monster.monster)}
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
        <></>
      )}
    </>,
    document.getElementById("modal")
  );
};

export default NurseryModal;
