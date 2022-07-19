import React, { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import NotConnected from "./NotConnected";
import TraderABI from "./api/Trader.json";

const TraderContract = "0x8Ee59110eb4800F00DBB5b10B845ef5224F6bC1D";
const MonsterGameContract = "0xbBbFf663f5E426f6C30DC697439060141E327025";
const ItemsContract = "0x1928e72E0a2Efe283DD4c6166EE3e083E1F98CB6";

const CityHall = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  const [buyDetails, setBuyDetails] = useState([]);
  const [dailyShop, setDailyShop] = useState([]);
  const [shopShow, setShopShow] = useState(false);
  const [traderShow, setTraderShow] = useState(false);
  const canvasRef = useRef(null);
  const contextRef = useRef(null);
  const image = new Image();
  image.src = "/hall.png";

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const traderContract = new ethers.Contract(
    TraderContract,
    TraderABI.abi,
    signer
  );

  async function getShop() {
    await traderContract.getDailyShop().then((response) => {
      setDailyShop(response);
    });
  }

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
      getShop();
    }
  }, [isConnected]);
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
        shopShow ? (
          <>
            <motion.div
              id="modal-screen"
              className="h-100 w-100 bg-dark bg-opacity-75"
              onClick={() => setShopShow(false)}
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
                <h2 id="modal-title">Shop</h2>
              </div>
              <div className="row justify-content-center">
                {dailyShop.map((shop, index) => (
                  <div id="item-card" className="card col-2 mx-2" key={index}>
                    <img src="" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">
                        {shop.item.toString()} (
                        {ethers.utils.formatEther(shop.price)}) Eth
                      </h5>
                      <div className="d-flex">
                        <button className="btn btn-danger">-</button>
                        <input type="text" className="form-control mx-2" />
                        <button className="btn btn-success">+</button>
                      </div>
                      <button className="btn btn-primary m-2">Buy</button>
                    </div>
                  </div>
                ))}
              </div>
            </motion.div>
          </>
        ) : traderShow ? (
          <>
            <motion.div
              id="modal-screen"
              className="h-100 w-100 bg-dark bg-opacity-75"
              onClick={() => setTraderShow(false)}
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
                <h2 id="modal-title">Trader</h2>
              </div>
              <div className="row justify-content-center">
                <table className="table">
                  <thead>
                    <tr>
                      <th scope="col">Item</th>
                      <th scope="col">Trade for</th>
                      <th scopr="col">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Item 1</td>
                      <td>item 2 & item 3</td>
                      <td>
                        <button className="btn btn-success">Trade</button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </motion.div>
          </>
        ) : (
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
          </>
        )
      ) : (
        <NotConnected />
      )}
    </motion.div>
  );
};

export default CityHall;
