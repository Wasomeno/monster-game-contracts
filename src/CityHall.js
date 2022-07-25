import React, { createRef, useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import NotConnected from "./NotConnected";
import CityHallModal from "./CityHallModal";

const CityHall = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  const [shopShow, setShopShow] = useState(false);
  const [traderShow, setTraderShow] = useState(false);
  const canvasRef = useRef(null);
  const contextRef = useRef(null);
  const image = new Image();
  image.src = "/hall.png";

  function getCanvas() {
    var wrh = image.width / image.height;
    var newWidth = canvasRef.current.width;
    var newHeight = newWidth / wrh;
    if (newHeight > canvasRef.current.height) {
      newHeight = canvasRef.current.height;
      newWidth = newHeight * wrh;
    }
    var xOffset =
      newWidth < canvasRef.current.width
        ? (canvasRef.current.width - newWidth) / 2
        : 0;
    var yOffset =
      newHeight < canvasRef.current.height
        ? (canvasRef.current.height - newHeight) / 2
        : 0;
    contextRef.current.drawImage(image, xOffset, yOffset, newWidth, newHeight);
  }

  useEffect(() => {
    if (isConnected) {
      const canvas = canvasRef.current;
      canvas.width = 1000;
      canvas.height = window.innerHeight;
      const context = canvas.getContext("2d");
      contextRef.current = context;
      getCanvas();
    }
  }, []);
  return (
    <motion.div
      id="hall-container"
      className="container h-100 p-0"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1.25 }}
    >
      {isConnected ? (
        <>
          <canvas className="hall-canvas" ref={canvasRef} />
          <div id="hall-buttons" className="row justify-content-center">
            <div className="col-3">
              <button
                id="trader-button"
                type="button"
                className="btn btn-primary"
                data-toggle="modal"
                data-target="#exampleModal"
                onClick={() => setTraderShow(true)}
              >
                Trader
              </button>
            </div>
            <div className="col-3">
              <button
                id="shop-button"
                type="button"
                className="btn btn-primary"
                data-toggle="modal"
                data-target="#exampleModal"
                onClick={() => setShopShow(true)}
              >
                Shop
              </button>
            </div>
          </div>
          <CityHallModal
            shopShow={shopShow}
            traderShow={traderShow}
            setShopShow={setShopShow}
            setTraderShow={setTraderShow}
          />
        </>
      ) : (
        <NotConnected />
      )}
    </motion.div>
  );
};

export default CityHall;
