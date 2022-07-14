import "./App.css";
import "bootstrap/dist/css/bootstrap.min.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Dungeon from "./Dungeon";
import Nursery from "./Nursery";
import CityHall from "./CityHall";
import Altar from "./Altar";
import Map from "./Map";

function App() {
  return (
    <div className="App vh-100">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Map />} />
          <Route path="/hall" element={<CityHall />} />
          <Route path="/dungeon" element={<Dungeon />} />
          <Route path="/nursery" element={<Nursery />} />
          <Route path="/altar" element={<Altar />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
