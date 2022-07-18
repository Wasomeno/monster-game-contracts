import React, { useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";

const Map = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  const canvasRef = useRef(null);
  const image = new Image();
  image.src = "/Map (2).png";

  function getCanvas() {
    if (isConnected) {
      const canvas = canvasRef.current;
      canvas.width = 1280;
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
      id="map-container"
      className="container-fluid h-100 w-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      {isConnected ? (
        <>
          <canvas ref={canvasRef} className="map-canvas" />
          <div id="map-buttons">
            <motion.div
              className="col-4"
              initial={{ top: "32.5%" }}
              animate={{ top: "31.5%" }}
              transition={{
                repeat: "Infinity",
                repeatType: "reverse",
                duration: 1,
              }}
            >
              <Link className="btn btn-primary" to={"/hall"}>
                City Hall
              </Link>
            </motion.div>
            <motion.div
              className="col-4"
              initial={{ bottom: "32.5%" }}
              animate={{ bottom: "31.5%" }}
              transition={{
                repeat: "Infinity",
                repeatType: "reverse",
                duration: 1,
              }}
            >
              <Link className="btn btn-primary" to={"/dungeon"}>
                Dungeon
              </Link>
            </motion.div>
            <motion.div
              className="col-4"
              initial={{ bottom: "33.5%" }}
              animate={{ bottom: "32.5%" }}
              transition={{
                repeat: "Infinity",
                repeatType: "reverse",
                duration: 1,
              }}
            >
              <Link className="btn btn-primary" to={"/nursery"}>
                Nursery
              </Link>
            </motion.div>
            <motion.div
              className="col-4"
              initial={{ top: "25%" }}
              animate={{ top: "26%" }}
              transition={{
                repeat: "Infinity",
                repeatType: "reverse",
                duration: 1,
              }}
            >
              <Link className="btn btn-primary" to={"/altar"}>
                Summoning Altar
              </Link>
            </motion.div>
          </div>
        </>
      ) : (
        <>
          <div className="d-flex justify-content-center align-items-center h-100">
            <h2 className="p-2 text-white">Connect Your Wallet</h2>
          </div>
        </>
      )}
    </motion.div>
  );
};

export default Map;
