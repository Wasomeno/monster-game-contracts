import React, { useState } from "react";
import { motion } from "framer-motion";
const Dungeon = () => {
  const [showDungeon, setShowDungeon] = useState(false);
  return (
    <motion.div
      className="container h-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      {showDungeon ? (
        <>
          <div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowDungeon(false)}
          />
          <div id="shop-modal" className="container w-75 h-75">
            <div className="row justify-content-center">
              <div className="col">
                <h3>Your Monster</h3>
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
                <h4>Monster on Nursery</h4>
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
          </div>
        </>
      ) : (
        <>
          <div className="row justify-content-center">
            <h1>Dungeon</h1>
          </div>
          <div className="row justify-content-center">
            <div className="col-3">
              <button
                className="btn btn-primary"
                onClick={() => setShowDungeon(true)}
              >
                Dungeon
              </button>
            </div>
          </div>
        </>
      )}
    </motion.div>
  );
};

export default Dungeon;
