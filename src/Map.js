import React from "react";
import { Link } from "react-router-dom";

const Map = () => {
  return (
    <div className="container-fluid h-100">
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
    </div>
  );
};

export default Map;
