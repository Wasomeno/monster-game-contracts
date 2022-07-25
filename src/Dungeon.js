import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import NotConnected from "./NotConnected";
import DungeonModal from "./DungeonModal";

const Dungeon = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  const [showDungeon, setShowDungeon] = useState(false);
  const [showMission, setShowMission] = useState(false);

  async function getCanvas() {
    const canvas = document.querySelector(".dungeon-canvas");
    canvas.width = 1000;
    canvas.height = window.innerHeight;
    const c = canvas.getContext("2d");
    const image = new Image();
    image.src = "/dungeon.png";
    var wrh = image.width / image.height;
    var newWidth = canvas.width;
    var newHeight = newWidth / wrh;
    if (newHeight > canvas.height) {
      newHeight = canvas.height;
      newWidth = newHeight * wrh;
    }
    var xOffset = newWidth < canvas.width ? (canvas.width - newWidth) / 2 : 0;
    var yOffset =
      newHeight < canvas.height ? (canvas.height - newHeight) / 2 : 0;
    image.onload = () => {
      c.drawImage(image, xOffset, yOffset, newWidth, newHeight);
    };
  }

  useEffect(() => {
    getCanvas();
  }, []);
  return (
    <motion.div
      id="dungeon-container"
      className="container h-100"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ type: "tween", duration: 1 }}
    >
      {isConnected ? (
        <>
          <canvas className="dungeon-canvas" />
          <div id="dungeon-buttons" className="row justify-content-center">
            <div className="col-3">
              <button
                id="dungeon-button"
                className="btn btn-primary"
                onClick={() => setShowDungeon(true)}
              >
                Dungeon
              </button>
            </div>
            <div className="col-3">
              <button
                id="missions-button"
                className="btn btn-primary"
                onClick={() => setShowMission(true)}
              >
                Missions
              </button>
            </div>
          </div>
          <DungeonModal
            showDungeon={showDungeon}
            showMission={showMission}
            setShowDungeon={setShowDungeon}
            setShowMission={setShowMission}
          />
        </>
      ) : (
        <NotConnected />
      )}
    </motion.div>
  );
};

export default Dungeon;
