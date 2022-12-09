import React, { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import NotConnected from "./NotConnected";
import DungeonModal from "./DungeonModal";

const Dungeon = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  const [showDungeon, setShowDungeon] = useState(false);
  const [showMission, setShowMission] = useState(false);
  const [image, setImage] = useState(null);
  const canvasRef = useRef(null);

  const drawCanvas = (context, xOffset, yOffset, newWidth, newHeight) => {
    context.drawImage(image, xOffset, yOffset, newWidth, newHeight);
  };

  useEffect(() => {
    if (isConnected) {
      const dungeonImage = new Image();
      dungeonImage.src = "/dungeon.png";
      dungeonImage.onload = () => {
        setImage(dungeonImage);
      };
    }
  }, [isConnected]);

  useEffect(() => {
    if (image && canvasRef) {
      const canvas = canvasRef.current;
      const c = canvas.getContext("2d");
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
      drawCanvas(c, xOffset, yOffset, newWidth, newHeight);
    }
  }, [drawCanvas]);

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
          <canvas
            className="dungeon-canvas"
            ref={canvasRef}
            width={1000}
            height={window.innerHeight}
          />
          <div className="col-2">
            <button
              id="dungeon-button"
              className="btn btn-primary"
              onClick={() => setShowDungeon(true)}
            >
              Dungeon
            </button>
          </div>
          <div className="col-2">
            <button
              id="missions-button"
              className="btn btn-primary d-flex justify-content-center align-items-center text-center"
              onClick={() => setShowMission(true)}
            >
              <img
                src="sword_icon.png"
                className="p-1"
                width={"35px"}
                alt="sword-icon"
              />
              Missions
            </button>
          </div>
          <DungeonModal
            showDungeon={showDungeon}
            showMission={showMission}
            setShowDungeon={setShowDungeon}
            setShowMission={setShowMission}
          />
        </>
      ) : (
        <NotConnected account={account} setAccount={setAccount} />
      )}
    </motion.div>
  );
};

export default Dungeon;
