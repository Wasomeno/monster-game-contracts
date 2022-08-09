import React, { useState } from "react";
import InventoryModal from "./InventoryModal";
import MonstersModal from "./MonstersModal";

const UtilityNavigation = () => {
  const [showInventory, setShowInventory] = useState(false);
  const [showMonsters, setShowMonsters] = useState(false);
  return (
    <div id="utility-navbar" className="container-fluid p-3">
      <div className="row justify-content-center">
        <div className="col-2">
          <img
            src="bag_icon.png"
            onClick={() => setShowInventory(true)}
            width={"30%"}
            alt="bag-icon"
          />

          <h5 className="m-0 p-2 text-white" id="modal-title">
            Inventory
          </h5>
        </div>
        <div className="col-2">
          <img
            src="/bag_icon.png"
            alt="bag-icon"
            width={"30%"}
            onClick={() => setShowMonsters(true)}
          />
          <h5 className="m-0 p-2 text-white" id="modal-title">
            Monsters
          </h5>
        </div>
      </div>
      <InventoryModal
        showInventory={showInventory}
        setShowInventory={setShowInventory}
      />
      <MonstersModal
        showMonsters={showMonsters}
        setShowMonsters={setShowMonsters}
      />
    </div>
  );
};

export default UtilityNavigation;
