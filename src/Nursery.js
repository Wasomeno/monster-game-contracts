import React, { useState } from "react";
import { motion } from "framer-motion";
const Nursery = () => {
  const [showNursery, setShowNursery] = useState(false);
  const [showShop, setShowShop] = useState(false);
  return (
    <motion.div
      className="container-fluid h-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      {showShop ? (
        <>
          <div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowShop(false)}
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
      ) : showNursery ? (
        <>
          <div
            id="modal-screen"
            className="h-100 w-100 bg-dark bg-opacity-75"
            onClick={() => setShowNursery(false)}
          />
          <div id="shop-modal" className="container w-75 h-75">
            <div className="row justify-content-center">
              <h4>Nursery</h4>
            </div>
            <div className="row justify-content-center">
              <div className="col">
                <h3>Your Monster</h3>
                <div className="row justify-content-center">
                  <div className="card col-3">
                    <img src="..." className="card-img-top" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">Monster #1</h5>
                      <button className="btn btn-success">Send</button>
                    </div>
                  </div>
                </div>
              </div>
              <div className="col">
                <h4>Monster on Nursery</h4>
                <div className="row justify-content-center">
                  <div className="card col-3">
                    <img src="..." className="card-img-top" alt="..." />
                    <div className="card-body">
                      <h5 className="card-title">Monster #1</h5>
                      <button className="btn btn-danger">Home</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </>
      ) : (
        <>
          <div className="row justify-content-center">
            <h1>Nursery</h1>
          </div>
          <div className="row justify-content-center">
            <div className="col-3">
              <button
                className="btn btn-primary"
                onClick={() => setShowNursery(true)}
              >
                Nursery
              </button>
            </div>
            <div className="col-3">
              <button
                className="btn btn-primary"
                onClick={() => setShowShop(true)}
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

export default Nursery;
