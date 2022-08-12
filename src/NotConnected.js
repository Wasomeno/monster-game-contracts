import React from "react";

const NotConnected = ({ account, setAccount }) => {
  async function connectAccount() {
    if (window.ethereum) {
      const account = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAccount(account);
    }
  }
  return (
    <div className="d-flex flex-column justify-content-center align-items-center h-100 w-100 text-center">
      <h2 className="p-2 text-white">Connect Your Wallet</h2>
      <div className="row justify-content-center align-items-center">
        <button
          className="btn btn-primary px-3 rounded-pill"
          onClick={connectAccount}
        >
          Connect
        </button>
      </div>
    </div>
  );
};

export default NotConnected;
