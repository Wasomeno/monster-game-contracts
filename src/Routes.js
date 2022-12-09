import React from "react";
import { Routes, Route, useLocation } from "react-router-dom";
import Dungeon from "./Dungeon";
import Nursery from "./Nursery";
import CityHall from "./CityHall";
import Altar from "./Altar";
import Map from "./Map";
import Navigations from "./Navigations";
import { AnimatePresence } from "framer-motion";

const CityRoutes = ({ account, setAccount }) => {
  const location = useLocation();
  return (
    <AnimatePresence>
      <Routes location={location} key={location.pathname}>
        <Route
          path="/"
          element={<Navigations account={account} setAccount={setAccount} />}
        >
          <Route
            index
            element={<Map account={account} setAccount={setAccount} />}
          />
          <Route
            path="hall"
            element={<CityHall account={account} setAccount={setAccount} />}
          />
          <Route
            path="dungeon"
            element={<Dungeon account={account} setAccount={setAccount} />}
          />
          <Route
            path="nursery"
            element={<Nursery account={account} setAccount={setAccount} />}
          />
          <Route
            path="altar"
            element={<Altar account={account} setAccount={setAccount} />}
          />
        </Route>
      </Routes>
    </AnimatePresence>
  );
};

export default CityRoutes;
