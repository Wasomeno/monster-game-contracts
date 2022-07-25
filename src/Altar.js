import React, { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import { ethers } from "ethers";
import NotConnected from "./NotConnected";
import MonsterABI from "../src/api/Monsters.json";

const MonsterContract = "0xBe145c9F694867BaC23Ec7e655A1A3AaE8047F35";

const Altar = ({ account, setAccount }) => {
  const [showAltar, setShowAltar] = useState(false);
  const [quantity, setQuantity] = useState(1);
  const isConnected = Boolean(account[0]);
  const canvasRef = useRef(null);
  const image = new Image();
  image.src = "/Altar.png";

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );

  const increment = () => {
    if (quantity >= 5) return;
    setQuantity(quantity + 1);
  };

  const decrement = () => {
    if (quantity <= 1) return;
    setQuantity(quantity - 1);
  };

  async function summonMonster() {
    const price = await monsterContract.price();
    await monsterContract
      .summon(quantity, { value: price * quantity })
      .then((response) => {
        setQuantity(1);
      });
  }

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
      {isConnected ? (
        showAltar ? (
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
              className="container w-50 h-50"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ type: "tween", duration: 0.5 }}
            >
              <div className="row justify-content-center">
                <h2 id="modal-title">Monster Altar</h2>
              </div>
              <div className="d-flex justify-content-center m-2">
                <button className="btn btn-danger" onClick={() => decrement()}>
                  {" "}
                  -{" "}
                </button>
                <input
                  type="text"
                  className="form-control w-25 mx-2 text-center"
                  value={quantity}
                />
                <button className="btn btn-success" onClick={() => increment()}>
                  {" "}
                  +{" "}
                </button>
              </div>
              <div className="row justify-content-center">
                <div>
                  <button
                    className="btn btn-warning m-2"
                    onClick={summonMonster}
                  >
                    Summon
                  </button>
                </div>
              </div>
            </motion.div>
          </>
        ) : (
          <>
            <canvas className="altar-canvas" ref={canvasRef} />
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
                  id="altar-button"
                  className="btn btn-primary"
                  onClick={() => setShowAltar(true)}
                >
                  Altar
                </button>
              </motion.div>
            </div>
          </>
        )
      ) : (
        <NotConnected />
      )}
    </motion.div>
  );
};

export default Altar;
