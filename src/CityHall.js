import React, { createRef, useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import NotConnected from "./NotConnected";
import CityHallModal from "./CityHallModal";

const CityHall = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  const [shopShow, setShopShow] = useState(false);
  const [traderShow, setTraderShow] = useState(false);
  const [image, setImage] = useState(null);
  const canvasRef = useRef(null);

  const drawCanvas = (context, xOffset, yOffset, newWidth, newHeight) => {
    context.drawImage(image, xOffset, yOffset, newWidth, newHeight);
  };

  useEffect(() => {
    if (isConnected) {
      const hallImage = new Image();
      hallImage.src = "/hall.png";
      hallImage.onload = () => {
        setImage(hallImage);
      };
    }
  }, [isConnected]);

  useEffect(() => {
    if (image && canvasRef) {
      const canvas = canvasRef.current;
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
      drawCanvas(c, xOffset, yOffset, newWidth, newHeight);
    }
  }, [drawCanvas]);

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
          <canvas
            className="hall-canvas"
            ref={canvasRef}
            width={1000}
            height={window.innerHeight}
          />
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
