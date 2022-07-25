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
          <button
            className="btn btn-warning"
            onClick={() => setShowInventory(true)}
          >
            {" "}
            Inventory
          </button>
        </div>
        <div className="col-2">
          <button
            className="btn btn-warning"
            onClick={() => setShowMonsters(true)}
          >
            {" "}
            My Monsters
          </button>
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
