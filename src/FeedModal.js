import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import ItemsABI from "../src/api/Items.json";
import MonsterGameABI from "../src/api/MonsterGame.json";
import { ethers } from "ethers";

const MonsterGameContract = "0x697049b6FcFDa75dE7bA4FBd9C364382c745BF8C";
const ItemsContract = "0x633c04c362381BbD1C9B8762065318Cb4F207989";

const FeedModal = ({ showFeed, setShowFeed, tokenId, level }) => {
  const [amount, setAmount] = useState(1);
  const [potion, setPotion] = useState(0);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterGameContract = new ethers.Contract(
    MonsterGameContract,
    MonsterGameABI.abi,
    signer
  );

  const itemsContract = new ethers.Contract(
    ItemsContract,
    ItemsABI.abi,
    signer
  );

  async function getPotion() {
    await itemsContract.balanceOf(signer.getAddress(), 2).then((response) => {
      setPotion(response);
    });
  }

  async function payToFeed() {
    const fee = ethers.utils.parseEther("0.0001");
    const totalFee = 10 * amount * fee * level;
    await monsterGameContract.feedMonster(tokenId, amount * 10, {
      value: totalFee,
    });
  }

  function decrement() {
    if (amount <= 1) return;
    setAmount(amount - 1);
  }
  function increment() {
    if (amount >= 10) return;
    setAmount(amount + 1);
  }

  useEffect(() => {
    getPotion();
  }, []);

  if (!showFeed) return;
  return (
    <>
      <motion.div
        id="modal-screen"
        className="h-100 w-100 bg-dark bg-opacity-75"
        onClick={() => setShowFeed(false)}
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
        transition={{ type: "tween", duration: 0.25 }}
      >
        <div className="row justify-content-center align-items-center">
          <h3 className="text-center p-2" id="modal-title">
            Feed Monsters
          </h3>
        </div>
        <div className="row justify-content-center align-items-center">
          <div className="col text-center">
            <h4 className="m-0 p-1" id="modal-title">
              Pay to Feed
            </h4>
            <div className="d-flex justify-content-center align-items-center">
              <button className="btn btn-danger" onClick={decrement}>
                -
              </button>
              <input
                type="text"
                className="form-control w-25 mx-1 text-center"
                value={amount}
                id="modal-title"
              />
              <button className="btn btn-success" onClick={increment}>
                +
              </button>
            </div>
            <button
              className="btn btn-success"
              id="modal-title"
              onClick={() => payToFeed()}
            >
              Feed
            </button>
          </div>
          <div className="col text-center">
            <h4 className="m-0 p-1" id="modal-title">
              Use Potion
            </h4>
            <div className="d-flex justify-content-center align-items-center">
              <img src="/2.png" width={"20%"} alt="potion-img" />
              <h5 className="m-0 p-1" id="modal-title">
                x {potion.toString()}
              </h5>
            </div>
            <button className="btn btn-success" id="modal-title">
              Use Potion
            </button>
          </div>
        </div>
      </motion.div>
    </>
  );
};

export default FeedModal;
