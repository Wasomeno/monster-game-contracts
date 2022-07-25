import React, { useState } from "react";
import { motion } from "framer-motion";
import ReactDom from "react-dom";
import MissionsModal from "./MissionsModal";

const DungeonModal = ({
  showDungeon,
  showMission,
  setShowDungeon,
  setShowMission,
}) => {
  const [showBeginner, setShowBeginner] = useState(false);
  const [showInter, setShowInter] = useState(false);

  if (!showDungeon && !showMission) return;
  return ReactDom.createPortal(
    <>
      {showDungeon ? (
        <>
          <motion.div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowDungeon(false)}
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
              <div className="col">
                <h2 id="modal-title">Your Monster</h2>
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
                <h2 id="modal-title">Monster on Dungeon</h2>
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
          <motion.div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowMission(false)}
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
            {!showBeginner && !showInter ? (
              <motion.div
                className="container h-100 w-100"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ type: "tween", duration: 0.25 }}
              >
                <div className="row justify-center align-items-center h-25">
                  <h2 id="modal-title" className="text-center">
                    Missions
                  </h2>
                </div>
                <div className="row justify-content-center">
                  <div className="col-3 d-flex justify-content-center">
                    <button
                      id="missions-button"
                      className="btn btn-primary"
                      onClick={() => setShowBeginner(true)}
                    >
                      Beginner Mission
                    </button>
                  </div>
                  <div className="col-3 d-flex justify-content-center">
                    <button
                      id="missions-button"
                      className="btn btn-primary"
                      onClick={() => setShowInter(true)}
                    >
                      Intermediate Mission
                    </button>
                  </div>
                </div>
              </motion.div>
            ) : (
              <MissionsModal
                showBeginner={showBeginner}
                showInter={showInter}
                setShowBeginner={setShowBeginner}
                setShowInter={setShowInter}
              />
            )}
          </motion.div>
        </>
      )}
    </>,
    document.getElementById("modal")
  );
};

export default DungeonModal;
