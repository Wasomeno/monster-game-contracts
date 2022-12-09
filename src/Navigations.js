import React, { useEffect } from "react";
import MapButton from "./components/Buttons/MapButton";
import NotConnected from "./NotConnected";
import UserPanel from "./UserPanel";

const Navbar = ({ account, setAccount }) => {
  const isConnected = Boolean(account[0]);

  useEffect(() => {}, []);

  return (
    <>
      {!isConnected ? (
        <NotConnected account={account} setAccount={setAccount} />
      ) : (
        <>
          <UserPanel account={account} /> <MapButton />
        </>
      )}
    </>
  );
};

export default Navbar;
