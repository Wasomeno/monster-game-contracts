import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import { BigNumber, ethers } from "ethers";
import { motion } from "framer-motion";
import NurseryABI from "../src/api/Nursery.json";
import MoonLoader from "react-spinners/MoonLoader";
import { toast } from "react-toastify";
import NurseryMonsterSelect from "./NurseryMonsterSelect";
const NurseryContract = "0xCe1641A6d54F67859AF935164E6Aa1F1Bd1a463A";

const NurseryModal = ({ showNursery, setShowNursery }) => {
  const [onNursery, setOnNursery] = useState([]);
  const [showSelectMonster, setShowSelectMonster] = useState(false);
  const [monsterSelected, setMonsterSelected] = useState([]);
  const [loadingOnNursery, setLoadingOnNursery] = useState(false);
  const [duration, setDuration] = useState([]);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();

  const nurseryContract = new ethers.Contract(
    NurseryContract,
    NurseryABI.abi,
    signer
  );

  async function sendToNursery(monster, index) {
    const price = 100000 * duration[index];
    const durationBigInt = BigNumber.from(duration[index]);
    await toast
      .promise(
        nurseryContract.putOnNursery(
          monster,
          signer.getAddress(),
          durationBigInt,
          {
            value: ethers.utils.parseUnits(price.toString(), "gwei"),
          }
        ),
        {
          pending: "🗳️ Sending Monster #" + monster + " to nursery...",
          success: "Waiting for confirmation",
          error: "Failed sending monster to nursery",
        }
      )
      .then((response) => {
        toast
          .promise(provider.waitForTransaction(response.hash), {
            pending: "Waiting for confirmation",
            success: "Monster #" + monster + " rest on nursery",
            error: "Failed sending monster to nursery",
          })
          .then(() => {
            getOnNursery();
          });
      });
  }

  async function goBackHome(monster) {
    await nurseryContract
      .goBackHome(monster, signer.getAddress())
      .then((response) => {
        provider.waitForTransaction(response.hash).then((response) => {
          getOnNursery();
        });
      });
  }

  async function getOnNursery() {
    // setLoadingOnNursery(true);
    // await nurseryContract
    //   .getMyMonsters(signer.getAddress())
    //   .then((response) => {
    //     setOnNursery(response);
    //   });
    // setLoadingOnNursery(false);
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
    getOnNursery();
  }, []);

  if (!showNursery) return;
  return ReactDom.createPortal(
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
        <img
          src="/back_icon.png"
          onClick={() => setShowNursery(false)}
          width={"45px"}
          alt="back-img"
        />
        <div className="row justify-content-center">
          <h2 className="text-center" id="modal-title">
            Nursery
          </h2>
        </div>
        <div className="row justify-content-center">
          <h5 id="modal-title" className="col-6">
            You can put your monsters to rest at the nursery. Choose for how
            long your monsters will rest (hourly) and for each hour there's a
            fee that you need to pay. Max amount of monsters that you can send
            is 6.
          </h5>
        </div>
        <div className="row justify-content-center my-3">
          <div className="p-3 col-6 d-flex justify-content-center align-items-center border border-dark border-2 rounded">
            {monsterSelected.length !== 0 ? (
              monsterSelected.map((monster, index) => (
                <div
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
            className="btn btn-primary p-2 col-3 m-2"
            onClick={() => setShowSelectMonster(true)}
          >
            Select Monsters
          </button>
          {onNursery.length < 1 ? (
            <button className="btn btn-success p-2 col-3 m-2">
              Send Monsters
            </button>
          ) : (
            <button className="btn btn-danger p-2 col-3 m-2">
              Bring back Monsters
            </button>
          )}
        </div>
      </motion.div>
      <NurseryMonsterSelect
        showSelectMonster={showSelectMonster}
        setShowSelectMonster={setShowSelectMonster}
        monsterSelected={monsterSelected}
        setMonsterSelected={setMonsterSelected}
      />
    </>,
    document.getElementById("modal")
  );
};

export default NurseryModal;
