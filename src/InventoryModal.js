import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import ReactDom from "react-dom";
import { motion } from "framer-motion";
import ItemsABI from "../src/api/Items.json";

const ItemsContract = "0x633c04c362381BbD1C9B8762065318Cb4F207989";

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
        <div className="row justify-content-center align-items-center">
          <h2 className="text-center p-3" id="modal-title">
            Inventory
          </h2>
        </div>
        <div className="row justify-content-center p-3">
          {inventory.map((item, index) =>
            item.toString() === "0" ? (
              <></>
            ) : (
              <>
                <div
                  className="card col-2 mx-1 d-flex flex-column justify-content-center align-items-center shadow-sm"
                  key={index}
                >
                  <div className="align-self-end p-2">
                    <h5 className="m-0" id="modal-title">
                      x{item.toString()}
                    </h5>
                  </div>
                  <img
                    src={index + ".png"}
                    alt="items-img"
                    width={"40%"}
                    className="p-2"
                  />
                  <div>
                    <h5 className="card-title" id="modal-title">
                      {index === 0
                        ? "Gold Coins"
                        : index === 1
                        ? "Berry"
                        : index === 2
                        ? "Hunger Potion"
                        : index === 3
                        ? "Exp Potion"
                        : index === 4
                        ? "Token Crystal"
                        : ""}{" "}
                    </h5>
                  </div>
                </div>
              </>
            )
          )}
        </div>
      </motion.div>
    </>,
    document.getElementById("modal")
  );
}

export default InventoryModal;
