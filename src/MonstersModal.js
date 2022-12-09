import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import { ethers } from "ethers";
import { motion } from "framer-motion";
import MonsterABI from "../src/api/Monsters.json";
import MonsterDetails from "./MonsterDetails";
import MoonLoader from "react-spinners/MoonLoader";

const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const MonstersModal = ({ showMonsters, setShowMonsters }) => {
  const [monsters, setMonsters] = useState([]);
  const [showDetails, setShowDetails] = useState(false);
  const [tokenId, setTokenId] = useState("");
  const [loading, setLoading] = useState(false);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );
  async function getMonsters() {
    let myMonsters = [];
    setLoading(true);
    await monsterContract.getMyMonster(signer.getAddress()).then((monsters) => {
      for (let i = 0; i < monsters.length; i++) {
        monsterContract.getMonsterStatus(monsters[i]).then((response) => {
          let stat = response;
          myMonsters.push({ monster: monsters[i], status: stat });
        });
      }
      setMonsters(myMonsters);
    });
    setLoading(false);
  }

  function monsterDetails(tokenId) {
    setShowDetails(true);
    setTokenId(tokenId);
  }

  useEffect(() => {
    getMonsters();
  }, []);
  if (!showMonsters) return;
  return ReactDom.createPortal(
    <>
      <motion.div
        id="modal-screen"
        className="h-100 w-100 bg-dark bg-opacity-75"
        onClick={() => setShowMonsters(false)}
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
        {!showDetails ? (
          <>
            <div className="row justify-content-center align-items-center">
              <div className="col-4">
                <img
                  src="back_icon.png"
                  alt="back-icon"
                  width={"14%"}
                  onClick={() => setShowMonsters(false)}
                />
              </div>
              <div className="col-4">
                <h2 className="text-center p-3" id="modal-title">
                  My Monsters
                </h2>
              </div>
              <div className="col-4" />
            </div>
            <div className="d-flex justify-content-center flex-wrap p-3">
              {loading ? (
                <MoonLoader size={50} loading={loading} />
              ) : monsters < 1 ? (
                <h5 className="m-0" id="modal-title">
                  You don't have a monster
                </h5>
              ) : (
                monsters.map((details, index) => (
                  <div
                    className="card col-2 mx-1 p-3 shadow-sm d-flex flex-column justify-content-end align-items-center"
                    key={index}
                    onClick={() => monsterDetails(details.monster.toString())}
                  >
                    {details.status.toString() === "1" ? (
                      <img
                        src="sword_icon.png"
                        width={"25%"}
                        alt="activity-icon"
                        className="align-self-end p-1 my-1 bg-primary bg-opacity-25 rounded-circle"
                      />
                    ) : details.status.toString() === "2" ? (
                      <img
                        src="love_icon.png"
                        width={"25%"}
                        alt="activity-icon"
                        className="align-self-end"
                      />
                    ) : details.status.toString() === "3" ? (
                      <img
                        src="chest_icon.png"
                        width={"25%"}
                        alt="activity-icon"
                        className="align-self-end"
                      />
                    ) : (
                      <></>
                    )}

                    <img src="/monster.png" alt="monster-img" width={"75%"} />
                    <div className="text-center p-0">
                      <h5 className="card-title" id="modal-title">
                        Monster #{details.monster.toString()}
                      </h5>
                    </div>
                  </div>
                ))
              )}
            </div>
          </>
        ) : (
          <MonsterDetails
            tokenId={tokenId}
            setShowDetails={setShowDetails}
            setTokenId={setTokenId}
            showDetails={showDetails}
          />
        )}
      </motion.div>
    </>,
    document.getElementById("modal")
  );
};

export default MonstersModal;
