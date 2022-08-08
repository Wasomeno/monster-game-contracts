import React, { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { BigNumber, ethers } from "ethers";
import MonsterABI from "../src/api/Monsters.json";
import MoonLoader from "react-spinners/MoonLoader";
import FeedModal from "./FeedModal";

const MonsterContract = "0x90B9aCC7C0601224310f3aFCaa451c0D545a1b41";

const MonsterDetails = ({ tokenId, setShowDetails }) => {
  const [details, setDetails] = useState({});
  const [loading, setLoading] = useState(true);
  const [showFeed, setShowFeed] = useState(false);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const monsterContract = new ethers.Contract(
    MonsterContract,
    MonsterABI.abi,
    signer
  );

  async function getDetails() {
    await monsterContract.monsterStats(tokenId).then((response) => {
      setDetails({
        level: response.level.toString(),
        hunger: response.hunger.toString(),
        exp: response.exp.toString(),
        expCap: response.expCap.toString(),
        status: response.status.toString(),
        cooldown: response.cooldown.toString(),
      });
    });
    setLoading(false);
  }

  useEffect(() => {
    getDetails();
  }, []);

  return (
    <>
      <motion.div
        className="container h-75"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ type: "tween", duration: 0.25 }}
      >
        <img
          src="/back_icon.png"
          onClick={() => setShowDetails(false)}
          alt="back_button"
          width={"40px"}
        />
        <div className="row justify-content-center">
          <h2 id="modal-title" className="text-center p-3">
            Monster #{tokenId}
          </h2>
        </div>
        <div className="d-flex justify-content-center">
          <MoonLoader color="#8E3200" loading={loading} size={50} />
          {loading ? (
            <></>
          ) : (
            <>
              <div className="col">
                <div className="d-flex flex-column align-items-center justify-content-center">
                  <img alt="monster" src="/monster.png" width={"50%"} />
                  <button
                    className="btn btn-success col-4"
                    onClick={() => setShowFeed(true)}
                  >
                    Feed
                  </button>
                </div>
              </div>
              <div className="col-8">
                <div className="container">
                  <div className="d-flex align-items-center justify-content-between">
                    <div className="col-3">
                      <h5 className="m-0" id="modal-title">
                        Level :
                      </h5>
                    </div>
                    <div className="col-2 text-center">
                      <h5 className="m-0" id="modal-title">
                        {details.level} / 10
                      </h5>
                    </div>
                    <div className="col-7">
                      <div class="progress">
                        <div
                          className="progress-bar bg-success"
                          role="progressbar"
                          style={{
                            width:
                              ((details.level / 10) * 100).toString() + "%",
                          }}
                          aria-valuenow={details.level}
                          aria-valuemin="1"
                          aria-valuemax="10"
                        ></div>
                      </div>
                    </div>
                  </div>
                  <div className="d-flex align-items-center justify-content-between">
                    <div className="col-3">
                      <h5 className="m-0" id="modal-title">
                        Hunger :
                      </h5>
                    </div>
                    <div className="col-2">
                      <h5 className="m-0 text-center" id="modal-title">
                        {details.hunger} /100
                      </h5>
                    </div>
                    <div className="col-7">
                      <div class="progress">
                        <div
                          className="progress-bar bg-success"
                          role="progressbar"
                          style={{
                            width:
                              ((details.hunger / 100) * 100).toString() + "%",
                          }}
                          aria-valuenow={details.hunger}
                          aria-valuemin="1"
                          aria-valuemax="10"
                        ></div>
                      </div>
                    </div>
                  </div>
                  <div className="d-flex align-items-center justify-content-between">
                    <div className="col-3">
                      <h5 className="m-0" id="modal-title">
                        Exp :
                      </h5>
                    </div>
                    <div className="col-2">
                      <h5 className="m-0 text-center" id="modal-title">
                        {details.exp} / {details.expCap}
                      </h5>
                    </div>
                    <div className="col-7">
                      <div class="progress">
                        <div
                          className="progress-bar bg-success"
                          role="progressbar"
                          style={{
                            width:
                              (
                                (details.exp / details.expCap) *
                                100
                              ).toString() + "%",
                          }}
                          aria-valuenow={details.exp}
                          aria-valuemin="1"
                          aria-valuemax="10"
                        ></div>
                      </div>
                    </div>
                  </div>
                  <div className="d-flex align-items-center justify-content-between">
                    <div className="col-3">
                      <h5 className="m-0" id="modal-title">
                        Status :
                      </h5>
                    </div>
                    <div className="col">
                      {details.status === "1" ? (
                        <h5 className="m-0 text-center" id="modal-title">
                          On a Mission
                        </h5>
                      ) : details.status === "2" ? (
                        <h5 className="m-0 text-center" id="modal-title">
                          On Nursery
                        </h5>
                      ) : details.status === "3" ? (
                        <h5 className="m-0 text-center" id="modal-title">
                          On Dungeon
                        </h5>
                      ) : (
                        <h5 className="m-0 text-center" id="modal-title">
                          Nothing
                        </h5>
                      )}
                    </div>
                  </div>
                  <div className="d-flex align-items-center justify-content-between">
                    <div className="col-3">
                      <h5 className="m-0" id="modal-title">
                        Cooldown :{" "}
                      </h5>
                    </div>
                    <div className="col">
                      <h5 className="m-0 text-center" id="modal-title">
                        {details.cooldown}
                      </h5>
                    </div>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>
      </motion.div>
      <FeedModal
        setShowFeed={setShowFeed}
        showFeed={showFeed}
        tokenId={tokenId}
        level={details.level}
      />
    </>
  );
};

export default MonsterDetails;
