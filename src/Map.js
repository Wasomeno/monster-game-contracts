import React from "react";
import { Link } from "react-router-dom";
import { motion } from "framer-motion";

const Map = () => {
  return (
    <motion.div
      className="container-fluid h-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      <div className="row justify-content-center">
        <h1>Map</h1>
      </div>

      <div className="row justify-content-center h-75 align-items-center">
        <div className="col-4">
          <Link className="btn btn-primary" to={"/hall"}>
            City Hall
          </Link>
        </div>
        <div className="col-4">
          <Link className="btn btn-primary" to={"/dungeon"}>
            Dungeon
          </Link>
        </div>
        <div className="col-4">
          <Link className="btn btn-primary" to={"/nursery"}>
            Nursery
          </Link>
        </div>
        <div className="col-4">
          <Link className="btn btn-primary" to={"/altar"}>
            Summoning Altar
          </Link>
        </div>
      </div>
    </motion.div>
  );
};

export default Map;
