import React from "react";
import { Link, Outlet } from "react-router-dom";

const Navbar = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);
  async function connectAccount() {
    if (window.ethereum) {
      const account = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAccount(account);
    }
  }
  return (
    <>
      <div
        id="navigation"
        className="d-flex justify-content-between align-items-center"
      >
        <div className="col-2 d-flex align-items-center justify-content-center p-2">
          <Link id="back-button" to="/">
            Map
          </Link>
        </div>
        <div className="col-2 d-flex align-items-center justify-content-center p-2">
          {isConnected ? (
            <button id="connected-button" className="p-2 rounded-pill px-3">
              {account[0].slice(0, 6) + "..." + account[0].slice(36, 42)}
            </button>
          ) : (
            <>
              <button
                id="connect-button"
                className="p-2 rounded-pill px-3"
                onClick={connectAccount}
              >
                Connect Wallet
              </button>
            </>
          )}
        </div>
      </div>
      <Outlet />
    </>
  );
};

export default Navbar;
