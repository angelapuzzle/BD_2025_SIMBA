import React, { useEffect, useState } from "react";
import { obtenerSalas } from "../services/api"; // Si luego agregamos sesiones, cambiar aquí

export default function SessionTable() {
  const [sesiones, setSesiones] = useState([]);

  useEffect(() => {
    // aquí ira una API real de sesiones cuando exista
    setSesiones([
      { id: 1, sala: "Sala 1", hora: "10:00 AM", estado: "Activa" },
      { id: 2, sala: "Sala 2", hora: "11:30 AM", estado: "Terminada" }
    ]);
  }, []);

  return (
    <div className="bg-white p-4 shadow rounded-lg">
      <h2 className="text-xl font-semibold mb-4">Sesiones</h2>

      <table className="w-full text-left border-collapse">
        <thead>
          <tr>
            <th>ID</th>
            <th>Sala</th>
            <th>Hora</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          {sesiones.map((s) => (
            <tr key={s.id} className="border-t">
              <td>{s.id}</td>
              <td>{s.sala}</td>
              <td>{s.hora}</td>
              <td>{s.estado}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
