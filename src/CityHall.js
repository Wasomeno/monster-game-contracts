import React, { useState } from "react";
import { motion } from "framer-motion";

const CityHall = () => {
  const [buyDetails, setBuyDetails] = useState([]);
  const [shopShow, setShopShow] = useState(false);
  const [traderShow, setTraderShow] = useState(false);
  return (
    <motion.div
      className="container h-100 w-100 p-0"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1.25 }}
    >
      {shopShow ? (
        <>
          <div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShopShow(false)}
          />
          <div id="shop-modal" className="container w-75 h-75">
            <div className="row justify-content-center">
              <h3>Shop</h3>
            </div>
            <div className="row justify-content-center">
              <div className="card col-2">
                <img src="..." className="card-img-top" alt="..." />
                <div className="card-body">
                  <h5 className="card-title">Shop Item</h5>
                  <div className="d-flex">
                    <button className="btn btn-danger">-</button>
                    <input type="text" className="form-control mx-2" />
                    <button className="btn btn-success">+</button>
                  </div>
                  <button className="btn btn-primary m-2">Buy</button>
                </div>
              </div>
            </div>
          </div>
        </>
      ) : traderShow ? (
        <>
          <div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setTraderShow(false)}
          />
          <div id="shop-modal" className="container w-75 h-75">
            <div className="row justify-content-center">
              <h3>Trader</h3>
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
          </div>
        </>
      ) : (
        <>
          <div className="row justify-content-center">
            <h1>City Hall</h1>
          </div>

          <div className="row justify-content-center">
            <div className="col-3">
              <button
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
      )}
    </motion.div>
  );
};

export default CityHall;
