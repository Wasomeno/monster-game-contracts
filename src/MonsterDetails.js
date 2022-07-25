import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import MonsterABI from "../src/api/Monsters.json";

const MonsterContract = "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35";

const MonsterDetails = ({ tokenId, setShowDetails }) => {
  const [details, setDetails] = useState([]);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );

  async function getDetails() {
    await monsterContract.monsterStats(tokenId).then((response) => {
      setDetails(response);
    });
  }

  useEffect(() => {
    getDetails();
  }, []);

  return (
    <>
      <motion.div
        className="container w-75 h-75"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ type: "tween", duration: 0.25 }}
      >
        <button
          className="btn btn-danger"
          onClick={() => setShowDetails(false)}
        >
          Back
        </button>
        <div className="row justify-content-center">
          <h2 id="modal-title">Monster #{tokenId}</h2>
        </div>
        <div className="row justify-content-center">
          <div className="col">
            <img alt="monster" />
          </div>
          <div className="col">
            <ul>
              {details.map((detail, index) => (
                <li key={index}>{detail.toString()}</li>
              ))}
            </ul>
          </div>
        </div>
      </motion.div>
    </>
  );
};

export default MonsterDetails;
