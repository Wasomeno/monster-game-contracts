import "./App.css";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import CityRoutes from "./Routes";
import { useState } from "react";
import Navbar from "./Navbar";

function App() {
  const [account, setAccount] = useState([]);
  return (
    <div className="App vh-100 bg-dark">
      <BrowserRouter>
        <CityRoutes account={account} setAccount={setAccount} />
      </BrowserRouter>
    </div>
  );
}

export default App;
