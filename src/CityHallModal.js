import { motion } from "framer-motion";
import React, { useEffect, useState } from "react";
import ReactDom from "react-dom";
import TraderABI from "./api/Trader.json";
import { BigNumber, ethers } from "ethers";

const TraderContract = "0x73A153E68F275e0a9Cf4c9A6c2e437300e4f768E";
const MonsterGameContract = "0x0Adc18E217D04479a157aB26d6BE610edA4Ba820";

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

  async function getShop() {
    await traderContract.getDailyShop().then((response) => {
      setDailyShop(response);
    });
  }

  async function getTrades() {
    let result = [];
    for (let i = 0; i < 3; i++) {
      await traderContract.traderTrades(i).then((response) => {
        result.push(response);
      });
    }
    setTrades(result);
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
    return totalTemp.toString();
  }

  async function buy() {
    let items = [];
    if (quantity.length < 1 || bag.length < 1) return;
    for (let i = 0; i < bag.length; i++) {
      items.push(bag[i].itemBigNumb);
    }
    await traderContract
      .buyItem(items, quantity, signer.getAddress(), {
        value: ethers.utils.parseEther(getTotal()),
      })
      .then((response) => {
        setBag([]);
        setQuantity([1, 1, 1]);
      });
  }

  async function tradeItem(index) {
    const indexBig = BigNumber.from(index);
    await traderContract
      .tradeItem(indexBig, quantity[index], signer.getAddress())
      .then((response) => {
        console.log(response);
      });
  }

  const increment = (index) => {
    let test = [...quantity];
    if (test[index] >= 3) return;
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
            className="container w-75 h-75"
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
                      {ethers.utils.formatEther(shop.price)}) Eth
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
                        onClick={() => increment(index)}
                      >
                        +
                      </button>
                    </div>
                    <button
                      className="btn btn-primary m-2"
                      onClick={() =>
                        addToBag(
                          shop.item.toString(),
                          ethers.utils.formatEther(shop.price),
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
            className="container w-75 h-75 p-4"
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
                    <th scope="col">Item (Received)</th>
                    <th scope="col">Trade for</th>
                    <th scope="col">Quantity</th>
                    <th scopr="col">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {trades.map((trade, index) => (
                    <tr key={index}>
                      <td>
                        {trade.itemReceived.toString()} (
                        {trade.quantityReceived.toString()})
                      </td>
                      <td>
                        {trade.itemTrade.toString()} (
                        {trade.quantityTrade.toString()})
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
                          className="btn btn-success"
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
