import React from 'react';

export default function AdminPanel() {
  const [sesiones, setSesiones] = React.useState([]);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    fetch("http://localhost:8000/api/sesiones") // actualizado para SP
      .then((res) => res.json())
      .then((data) => {
        setSesiones(Array.isArray(data) ? data : []);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Error cargando datos:", err);
        setLoading(false);
      });
  }, []);

  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <h1 className="text-3xl font-bold mb-6">Sesiones Activas</h1>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white shadow-md rounded-2xl p-4">
          <h2 className="text-lg font-semibold mb-1">Sesiones Activas Ahora</h2>
          <p className="text-4xl font-bold text-green-600">{sesiones.length}</p>
        </div>

        <div className="bg-white shadow-md rounded-2xl p-4">
          <h2 className="text-lg font-semibold mb-1">Sesiones (+2h)</h2>
          <p className="text-4xl font-bold text-orange-500">
            {sesiones.filter((s) => s.duracion_minutos > 120).length}
          </p>
        </div>

        <div className="bg-white shadow-md rounded-2xl p-4">
          <h2 className="text-lg font-semibold mb-1">Promedio Duración</h2>
          <p className="text-4xl font-bold text-blue-600">
            {sesiones.length
              ? (
                  sesiones.reduce((a, b) => a + b.duracion_minutos, 0) /
                  sesiones.length /
                  60
                ).toFixed(1) + "h"
              : "0h"}
          </p>
        </div>

        <div className="bg-white shadow-md rounded-2xl p-4">
          <h2 className="text-lg font-semibold mb-1">Con Incidentes</h2>
          <p className="text-4xl font-bold text-red-600">
            {sesiones.filter((s) => s.incidente === 1).length}
          </p>
        </div>
      </div>

      <div className="bg-white shadow-md rounded-2xl p-6">
        <h2 className="text-2xl font-semibold mb-4">Lista de Sesiones</h2>

        {loading ? (
          <p>Cargando...</p>
        ) : sesiones.length === 0 ? (
          <p>No hay sesiones activas</p>
        ) : (
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-200">
                <th className="border-b p-2">Estudiante</th>
                <th className="border-b p-2">Sala</th>
                <th className="border-b p-2">PC</th>
                <th className="border-b p-2">Hora Inicio</th>
                <th className="border-b p-2">Duración</th>
                <th className="border-b p-2">Monitor</th>
              </tr>
            </thead>
            <tbody>
              {sesiones.map((s, i) => (
                <tr key={i}>
                  <td className="border-b p-2">{s.estudiante}</td>
                  <td className="border-b p-2">{s.sala}</td>
                  <td className="border-b p-2">{s.pc}</td>
                  <td className="border-b p-2">{s.hora_inicio}</td>
                  <td className="border-b p-2 text-green-600 font-semibold">{s.duracion}</td>
                  <td className="border-b p-2">{s.monitor}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}