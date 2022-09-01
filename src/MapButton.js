import React from "react";
import { Link } from "react-router-dom";

const MapButton = () => {
  return (
    <div>
      <Link
        id="back-map-button"
        className="border border-2 border-light p-2 px-3 text-white rounded-pill"
        to={"/"}
      >
        Go to Map
      </Link>
    </div>
  );
};

export default MapButton;
