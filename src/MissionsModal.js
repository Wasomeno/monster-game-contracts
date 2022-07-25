import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import MonsterGameABI from "../src/api/MonsterGame.json";

const MonsterGameContract = "0xA082a931a3d927407Cc64575B76dF2DC27DEe370";
const MissionsModal = ({
  showBeginner,
  showInter,
  setShowBeginner,
  setShowInter,
}) => {
  const [onMission, setOnMission] = useState([]);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterGameContract = new ethers.Contract(
    MonsterGameContract,
    MonsterGameABI.abi,
    signer
  );

  async function getMonsters() {
    await monsterGameContract
      .myMonsterOnBeg(signer.getAddress())
      .then((response) => {
        console.log(response);
      });
  }

  useEffect(() => {
    getMonsters();
  }, []);
  if (!showBeginner && !showInter) return;
  return (
    <>
      {showBeginner ? (
        <>
          <button
            className="btn btn-danger"
            onClick={() => setShowBeginner(false)}
          >
            Back
          </button>
          <motion.div
            className="container"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 id="modal-title" className="text-center">
                Beginner Mission
              </h2>
            </div>
            <div className="row justify-content-center">
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Your Monster
                </h4>
                <div className="row justify-content-center">
                  <div className="card col-3">
                    <img src="..." className="card-img-top" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">Monster #1</h5>
                      <button className="btn btn-success">Send</button>
                    </div>
                  </div>
                </div>
              </div>
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Monster on Mission
                </h4>
                <div className="row justify-content-center">
                  <div className="card col-3">
                    <img src="..." className="card-img-top" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">Monster #1</h5>
                      <button className="btn btn-danger">Home</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      ) : (
        <>
          <button
            className="btn btn-danger"
            onClick={() => setShowInter(false)}
          >
            {" "}
            Back
          </button>
          <motion.div
            className="container"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 id="modal-title" className="text-center">
                Intermediate Mission
              </h2>
            </div>
            <div className="row justify-content-center">
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Your Monster
                </h4>
                <div className="row justify-content-center">
                  <div className="card col-3">
                    <img src="..." className="card-img-top" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">Monster #1</h5>
                      <button className="btn btn-success">Send</button>
                    </div>
                  </div>
                </div>
              </div>
              <div className="col">
                <h4 id="modal-title" className="text-center">
                  Monster on Mission
                </h4>
                <div className="row justify-content-center">
                  <div className="card col-3">
                    <img src="..." className="card-img-top" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">Monster #1</h5>
                      <button className="btn btn-danger">Home</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </>
  );
};

export default MissionsModal;
