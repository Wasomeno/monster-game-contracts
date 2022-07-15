import "./App.css";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import CityRoutes from "./Routes";

function App() {
  return (
    <div className="App vh-100">
      <BrowserRouter>
        <CityRoutes />
      </BrowserRouter>
    </div>
  );
}

export default App;
