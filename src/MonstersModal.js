import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import { ethers } from "ethers";
import { motion } from "framer-motion";
import MonsterABI from "../src/api/Monsters.json";
import MonsterDetails from "./MonsterDetails";

const MonsterContract = "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35";

const MonstersModal = ({ showMonsters, setShowMonsters }) => {
  const [monsters, setMonsters] = useState([]);
  const [showDetails, setShowDetails] = useState(false);
  const [tokenId, setTokenId] = useState("");
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );
  async function getMonsters() {
    await monsterContract.getMyMonster(signer.getAddress()).then((response) => {
      setMonsters(response);
    });
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
          <div className="row justify-content-center p-3">
            {monsters.map((monster, index) => (
              <div
                className="card col-2 mx-1"
                key={index}
                onClick={() => monsterDetails(monster.toString())}
              >
                <div className="card-body">
                  <h5 className="card-title">{monster.toString()}</h5>
                </div>
              </div>
            ))}
          </div>
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
