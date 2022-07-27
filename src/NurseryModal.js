import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import { BigNumber, ethers } from "ethers";
import { motion } from "framer-motion";
import MonsterABI from "../src/api/Monsters.json";
import NurseryABI from "../src/api/Nursery.json";

const NurseryContract = "0x8FBfc3e16BC171E58C52a8303c8DD5De869501B1";
const MonsterContract = "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35";

const NurseryModal = ({
  showShop,
  showNursery,
  setShowNursery,
  setShowShop,
}) => {
  const [monsters, setMonsters] = useState([]);
  const [onNursery, setOnNursery] = useState([]);
  const [duration, setDuration] = useState([]);
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

  async function buy() {
    await buyItem();
  }

  async function sendToNursery(monster, index) {
    const price = ethers.utils.parseEther(
      (0.0001 * duration[index]).toString()
    );
    const durationBigInt = BigNumber.from(duration[index]);
    await nurseryContract
      .putOnNursery(monster, signer.getAddress(), durationBigInt, {
        value: price,
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
  }

  async function getOnNursery() {
    await nurseryContract
      .getMyMonsters(signer.getAddress())
      .then((response) => {
        setOnNursery(response);
      });
  }

  const increment = (index) => {
    let test = [...duration];
    if (test[index] >= 3) return;
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
                <div className="row justify-content-center">
                  {monsters.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No monster on Inventory
                    </h5>
                  ) : (
                    monsters.map((monster, index) => (
                      <div className="card col-4 mx-1 text-center" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
                          <h5 className="card-title text-center">
                            {monster.toString()}
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
                <div className="row justify-content-center">
                  {onNursery.length < 1 ? (
                    <h5 className="text-center" id="modal-title">
                      No Monsters on Nursery
                    </h5>
                  ) : (
                    onNursery.map((monster, index) => (
                      <div className="card col-3" key={index}>
                        <img src="..." className="card-img-top" alt="..." />
                        <div className="card-body">
                          <h5 className="card-title">
                            {monster.monster.toString()}
                          </h5>
                          <button
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
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowShop(false)}
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
                Shop
              </h2>
            </div>
            <div className="row justify-content-center">
              <div className="card col-2">
                <img src="..." className="card-img-top" alt="..." />
                <div className="card-body">
                  <h5 className="card-title">Shop Item</h5>
                  <div className="d-flex">
                    <button className="btn btn-danger">-</button>
                    <input type="text" className="form-control mx-2" />
                    <button className="btn btn-success">+</button>
                  </div>
                  <button className="btn btn-primary m-2">Buy</button>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </>,
    document.getElementById("modal")
  );
};

export default NurseryModal;
