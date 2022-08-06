import { motion } from "framer-motion";
import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import TraderABI from "./api/Trader.json";
import ItemsABI from "./api/Items.json";
import { BigNumber, ethers, Signer } from "ethers";

const TraderContract = "0x3CCEc613890E907ACF32a8Eb4DbD18DB700C4b64";
const ItemsContract = "0x633c04c362381BbD1C9B8762065318Cb4F207989";

const CityHallModal = ({
  shopShow,
  traderShow,
  setShopShow,
  setTraderShow,
}) => {
  const [bag, setBag] = useState([]);
  const [dailyShop, setDailyShop] = useState([]);
  const [trades, setTrades] = useState([]);
  const [quantity, setQuantity] = useState([1, 1, 1]);

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const traderContract = new ethers.Contract(
    TraderContract,
    TraderABI.abi,
    signer
  );

  const itemsContract = new ethers.Contract(
    ItemsContract,
    ItemsABI.abi,
    signer
  );

  async function getShop() {
    await traderContract.getDailyShop().then((response) => {
      setDailyShop(response);
    });
  }

  async function getTrades() {
    await traderContract.getDailyTrades().then((response) => {
      setTrades(response);
    });
  }

  const addToBag = (item, price, quantity) => {
    let bagTemp = [...bag];
    if (bagTemp.length >= 3) return;
    const itemBigNumb = BigNumber.from(item);
    bagTemp.push({ itemBigNumb, price, quantity });
    setBag(bagTemp);
  };

  function getTotal() {
    let totalTemp = 0;
    for (let i = 0; i < bag.length; i++) {
      totalTemp += bag[i].price * bag[i].quantity;
    }
    console.log(totalTemp.toString());
    return totalTemp.toString();
  }

  async function buy() {
    let items = [];
    if (quantity.length < 1 || bag.length < 1) return;
    for (let i = 0; i < bag.length; i++) {
      items.push(bag[i].itemBigNumb);
    }
    await traderContract
      .buyItems(items, quantity, signer.getAddress(), {
        value: getTotal(),
      })
      .then(() => {
        setBag([]);
        setQuantity([1, 1, 1]);
      });
  }

  async function tradeItem(index) {
    const isApproved = await itemsContract.isApprovedForAll(
      signer.getAddress(),
      TraderContract
    );
    if (isApproved) {
      const indexBig = BigNumber.from(index);
      await traderContract
        .tradeItem(indexBig, quantity[index], signer.getAddress())
        .then((response) => {
          console.log(response);
        });
    } else {
      const indexBig = BigNumber.from(index);
      await itemsContract.setApprovalForAll(TraderContract, true).then(() => {
        traderContract
          .tradeItem(indexBig, quantity[index], signer.getAddress())
          .then((response) => {
            console.log(response);
          });
      });
    }
  }

  const increment = (index, limit) => {
    let test = [...quantity];
    if (test[index] >= limit) return;
    test[index] = test[index] + 1;
    setQuantity(test);
  };

  const decrement = (index) => {
    let test = [...quantity];
    if (test[index] <= 1) return;
    test[index] = test[index] - 1;
    setQuantity(test);
  };

  useEffect(() => {
    getShop();
    getTrades();
  }, [quantity]);

  if (!shopShow && !traderShow) return;

  return ReactDom.createPortal(
    <>
      {shopShow ? (
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
            className="container h-75"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 id="modal-title" className="text-center">
                Shop
              </h2>
            </div>
            <div className="row justify-content-center">
              {dailyShop.map((shop, index) => (
                <div
                  id="item-card"
                  className="card col-2 mx-2 text-center"
                  key={index}
                >
                  <img src="" alt="..." />
                  <div className="card-body">
                    <h5 className="card-title">
                      {shop.item.toString()} (
                      {ethers.utils.formatUnits(shop.price, "gwei")}) Eth
                    </h5>
                    <div className="d-flex">
                      <button
                        className="btn btn-danger"
                        onClick={() => decrement(index)}
                      >
                        -
                      </button>
                      <input
                        type="text"
                        className="form-control text-center"
                        value={quantity[index]}
                        name={index}
                      />
                      <button
                        className="btn btn-success"
                        onClick={() => increment(index, shop.quantity)}
                      >
                        +
                      </button>
                    </div>
                    <button
                      className="btn btn-primary m-2"
                      onClick={() =>
                        addToBag(
                          shop.item.toString(),
                          shop.price,
                          quantity[index]
                        )
                      }
                    >
                      Add to Bag
                    </button>
                  </div>
                </div>
              ))}
            </div>
            <div
              id="bag-container"
              className="col-3 d-flex justify-content-center p-3"
            >
              <button className="btn btn-success" onClick={buy}>
                Bag ({bag.length})
              </button>
            </div>
          </motion.div>
        </>
      ) : (
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
            className="container h-75 p-4"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ type: "tween", duration: 0.25 }}
          >
            <div className="row justify-content-center">
              <h2 id="modal-title" className="text-center">
                Trader
              </h2>
            </div>
            <div className="row justify-content-center">
              <table className="table text-center">
                <thead>
                  <tr>
                    <th scope="col" id="modal-title">
                      Item (Received)
                    </th>
                    <th scope="col" id="modal-title">
                      Trade for
                    </th>
                    <th scope="col" id="modal-title">
                      Quantity
                    </th>
                    <th scopr="col" id="modal-title">
                      Action
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {trades.map((trade, index) => (
                    <tr key={index}>
                      <td>
                        <img
                          src={trade.itemReceived.toString() + ".png"}
                          alt="items-img"
                          width={"45px"}
                        />
                        <h5 id="modal-title">
                          {trade.itemReceived.toString() === "0"
                            ? "Gold Coins"
                            : trade.itemReceived.toString() === "1"
                            ? "Berry"
                            : trade.itemReceived.toString() === "2"
                            ? "Hunger Potion"
                            : trade.itemReceived.toString() === "3"
                            ? "Exp Potion"
                            : trade.itemReceived.toString() === "4"
                            ? "Token Crystal"
                            : ""}{" "}
                          x{trade.quantityReceived.toString()}
                        </h5>
                      </td>
                      <td>
                        <img
                          src={trade.itemTrade.toString() + ".png"}
                          alt="items-img"
                          width={"45px"}
                        />
                        <h5 id="modal-title">
                          {trade.itemTrade.toString() === "0"
                            ? "Gold Coins"
                            : trade.itemTrade.toString() === "1"
                            ? "Berry"
                            : trade.itemTrade.toString() === "2"
                            ? "Hunger Potion"
                            : trade.itemTrade.toString() === "3"
                            ? "Exp Potion"
                            : trade.itemTrade.toString() === "4"
                            ? "Token Crystal"
                            : ""}{" "}
                          x{trade.quantityTrade.toString()}
                        </h5>
                      </td>
                      <td className="d-flex justify-content-center">
                        <div className="d-flex w-25">
                          <button
                            className="btn btn-danger"
                            onClick={() => decrement(index)}
                          >
                            -
                          </button>
                          <input
                            type="text"
                            className="form-control text-center"
                            value={quantity[index]}
                            name={index}
                          />
                          <button
                            className="btn btn-success"
                            onClick={() => increment(index)}
                          >
                            +
                          </button>
                        </div>
                      </td>
                      <td>
                        <button
                          className="btn"
                          id="modal-title"
                          style={{ backgroundColor: "#A64B2A", color: "#fff" }}
                          onClick={() => tradeItem(index)}
                        >
                          Trade
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </motion.div>
        </>
      )}
    </>,
    document.getElementById("modal")
  );
};

export default CityHallModal;
