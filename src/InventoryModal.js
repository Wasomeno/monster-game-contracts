import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import ReactDom from "react-dom";
import { motion } from "framer-motion";
import ItemsABI from "../src/api/Items.json";

const ItemsContract = "0x1c83A0119Fc52E6Ff5F9E1d1A6B39e54c422646f";

function InventoryModal({ showInventory, setShowInventory }) {
  const [inventory, setInventory] = useState([]);

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const itemsContract = new ethers.Contract(
    ItemsContract,
    ItemsABI.abi,
    signer
  );

  async function getInventory() {
    await itemsContract.getInventory(signer.getAddress()).then((response) => {
      setInventory(response);
    });
  }

  useEffect(() => {
    getInventory();
  }, []);

  if (!showInventory) return;
  return ReactDom.createPortal(
    <>
      <motion.div
        id="modal-screen"
        className="h-100 w-100 bg-dark bg-opacity-75"
        onClick={() => setShowInventory(false)}
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
        <div className="row justify-content-center p-3">
          {inventory.map((item, index) => (
            <div className="card col-2 mx-1">
              <div className="card-body">
                <h5 className="card-title" key={index}>
                  {item.toString()}
                </h5>
              </div>
            </div>
          ))}
        </div>
      </motion.div>
    </>,
    document.getElementById("modal")
  );
}

export default InventoryModal;
