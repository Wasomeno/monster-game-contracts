import React from "react";
import { Routes, Route, useLocation } from "react-router-dom";
import Dungeon from "./Dungeon";
import Nursery from "./Nursery";
import CityHall from "./CityHall";
import Altar from "./Altar";
import Map from "./Map";
import { AnimatePresence } from "framer-motion";

function CityRoutes() {
  const location = useLocation();
  return (
    <AnimatePresence>
      <Routes location={location} key={location.pathname}>
        <Route path="/" element={<Map />} />
        <Route path="/hall" element={<CityHall />} />
        <Route path="/dungeon" element={<Dungeon />} />
        <Route path="/nursery" element={<Nursery />} />
        <Route path="/altar" element={<Altar />} />
      </Routes>
    </AnimatePresence>
  );
}

export default CityRoutes;
