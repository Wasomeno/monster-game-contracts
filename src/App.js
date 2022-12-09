import "./App.css";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import CityRoutes from "./Routes";
import { useState } from "react";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

function App() {
  const [account, setAccount] = useState([]);
  const isConnected = Boolean(account[0]);
  return (
    <div className="App vh-100 bg-dark">
      <BrowserRouter>
        <CityRoutes account={account} setAccount={setAccount} />
      </BrowserRouter>
      <ToastContainer position="bottom-center" closeOnClick={false} />
    </div>
  );
}

export default App;
