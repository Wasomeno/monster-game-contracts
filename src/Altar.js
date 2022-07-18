import React, { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";

const Altar = ({ account, setAccount }) => {
  const [showAltar, setShowAltar] = useState(false);
  const isConnected = Boolean(account[0]);
  const canvasRef = useRef(null);
  const image = new Image();
  image.src = "/Altar.png";

  function getCanvas() {
    if (isConnected) {
      const canvas = canvasRef.current;
      canvas.width = 1000;
      canvas.height = window.innerHeight;
      const c = canvas.getContext("2d");
      var wrh = image.width / image.height;
      var newWidth = canvas.width;
      var newHeight = newWidth / wrh;
      if (newHeight > canvas.height) {
        newHeight = canvas.height;
        newWidth = newHeight * wrh;
      }
      var xOffset = newWidth < canvas.width ? (canvas.width - newWidth) / 2 : 0;
      var yOffset =
        newHeight < canvas.height ? (canvas.height - newHeight) / 2 : 0;
      c.drawImage(image, xOffset, yOffset, newWidth, newHeight);
      console.log(canvas);
    }
  }

  useEffect(() => {
    getCanvas();
  }, [isConnected]);
  return (
    <motion.div
      className="container-fluid h-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      <canvas className="altar-canvas" ref={canvasRef} />
      {showAltar ? (
        <>
          <motion.div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowAltar(false)}
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
            transition={{ type: "tween", duration: 0.5 }}
          >
            <div className="row justify-content-center">
              <h1>Monster Altar</h1>
            </div>
          </motion.div>
        </>
      ) : (
        <>
          <div id="altar-buttons" className="row justify-content-center">
            <motion.div
              className="col-3"
              initial={{ bottom: "30%" }}
              animate={{ bottom: "29%" }}
              transition={{
                repeat: "Infinity",
                repeatType: "reverse",
                duration: 1,
              }}
            >
              <button
                className="btn btn-primary"
                onClick={() => setShowAltar(true)}
              >
                Altar
              </button>
            </motion.div>
          </div>
        </>
      )}
    </motion.div>
  );
};

export default Altar;
