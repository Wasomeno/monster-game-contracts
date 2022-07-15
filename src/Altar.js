import React, { useState } from "react";
import { motion } from "framer-motion";

const Altar = () => {
  const [showAltar, setShowAltar] = useState(false);
  return (
    <motion.div
      className="container-fluid h-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      {showAltar ? (
        <>
          <div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowAltar(false)}
          />
          <div id="shop-modal" className="container w-75 h-75">
            <div className="row justify-content-center">
              <h1>Monster Altar</h1>
            </div>
          </div>
        </>
      ) : (
        <>
          <div className="row justify-content-center">
            <h1>Summoning Altar</h1>
          </div>

          <div className="row justify-content-center">
            <div className="col-3">
              <button
                className="btn btn-primary"
                onClick={() => setShowAltar(true)}
              >
                Altar
              </button>
            </div>
          </div>
        </>
      )}
    </motion.div>
  );
};

export default Altar;
