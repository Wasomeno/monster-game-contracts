import React from "react";
import { motion } from "framer-motion";
import ReactDOM from "react-dom";

const SmelterModal = ({ showSmelter, setShowSmelter }) => {
  if (!showSmelter) return;
  return ReactDOM.createPortal(
    <>
      <motion.div
        id="modal-screen"
        className="h-100 w-100 bg-dark bg-opacity-75"
        onClick={() => setShowSmelter(false)}
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
        <div className="row justify-content-center align-items-center text-center">
          <h2 id="modal-title">Smelter</h2>
        </div>
        <div className="d-flex flex-wrap justify-content-center align-items-center h-75">
          <div className="col d-flex justify-content-center align-items-center">
            <div className="p-3 bg-success w-25 d-flex justify-content-center align-items-center">
              <img src="4.png" width={"60%"} alt="diamond-icon" />
            </div>
          </div>
          <div className="col-2 d-flex justify-content-center align-items-center">
            <img src="back_icon.png" width={"30%"} alt="arrow-icon" />
          </div>
          <div className="col d-flex justify-content-center align-items-center">
            <div className="p-3 bg-success w-25 d-flex justify-content-center align-items-center">
              <img src="4.png" width={"60%"} alt="diamond-icon" />
            </div>
          </div>
        </div>
      </motion.div>
    </>,
    document.getElementById("modal")
  );
};

export default SmelterModal;
