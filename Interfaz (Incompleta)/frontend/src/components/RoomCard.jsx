import React, { useEffect, useState } from "react";
import { obtenerSalas } from "../services/api";

export default function RoomCard() {
  const [salas, setSalas] = useState([]);

  useEffect(() => {
    async function cargar() {
      try {
        const data = await obtenerSalas();
        setSalas(data);
      } catch (error) {
        console.error("Error cargando salas:", error);
      }
    }
    cargar();
  }, []);

  return (
    <div>
      <h2>Salas registradas</h2>

      {salas.length === 0 && <p>No hay datos.</p>}

      <ul>
        {salas.map((sala) => (
          <li key={sala.id}>
            {sala.id} - {sala.nombre}
          </li>
        ))}
      </ul>
    </div>
  );
}
