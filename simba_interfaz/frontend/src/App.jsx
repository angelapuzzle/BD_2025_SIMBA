import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

const API_URL = 'http://localhost:8000/api'

function App() {
  const [sesiones, setSesiones] = useState([])
  const [supervisiones, setSupervisiones] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [filtroSala, setFiltroSala] = useState('Todas')
  const [busqueda, setBusqueda] = useState('')

  // Cargar datos al iniciar
  useEffect(() => {
    cargarDatos()
  }, [])

  const cargarDatos = async () => {
    try {
      setLoading(true)
      setError(null)

      // Llamar a tus stored procedures
      const [sesionesRes, supervisionesRes] = await Promise.all([
        axios.get(`${API_URL}/sesiones`),
        axios.get(`${API_URL}/supervisiones`)
      ])

      console.log('Sesiones:', sesionesRes.data)
      console.log('Supervisiones:', supervisionesRes.data)

      setSesiones(Array.isArray(sesionesRes.data) ? sesionesRes.data : [])
      setSupervisiones(Array.isArray(supervisionesRes.data) ? supervisionesRes.data : [])

    } catch (err) {
      console.error('Error cargando datos:', err)
      setError('No se pudo conectar al backend. ¿Está corriendo en el puerto 8000?')
    } finally {
      setLoading(false)
    }
  }

  // Estadísticas calculadas
  const estadisticas = {
    sesionesActivas: sesiones.length,
    supervisiones: supervisiones.length,
  }

  // Salas - datos de ejemplo (puedes crear un SP para esto también)
  const [salas] = useState([
    { nombre: "Sala A", disponibles: 3, ocupados: 1, bloqueados: 1, total: 5 },
    { nombre: "Sala B", disponibles: 2, ocupados: 2, bloqueados: 0, total: 4 },
    { nombre: "Sala C", disponibles: 4, ocupados: 3, bloqueados: 1, total: 8 },
    { nombre: "Sala D", disponibles: 0, ocupados: 0, bloqueados: 5, total: 5, estado: "Bloqueada" },
  ])

  // Filtrar sesiones
  const sesionesesFiltradas = sesiones.filter(s => {
    const coincideBusqueda = busqueda === '' || 
      JSON.stringify(s).toLowerCase().includes(busqueda.toLowerCase())
    return coincideBusqueda
  })

  if (loading) {
    return (
      <div className="container">
        <div className="loading">
          <h1>🔄 Cargando datos del sistema SIMBA...</h1>
          <p>Conectando a la base de datos</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="container">
        <div className="error-screen">
          <h1>⚠️ Error de Conexión</h1>
          <p>{error}</p>
          <button onClick={cargarDatos} className="btn-refresh">
            🔄 Reintentar
          </button>
          <div className="error-help">
            <h3>¿Qué revisar?</h3>
            <ul>
              <li>✅ MySQL está corriendo (XAMPP o services.msc)</li>
              <li>✅ Backend ejecutándose: <code>uvicorn main:app --reload</code></li>
              <li>✅ Base de datos "simba_squema" existe</li>
              <li>✅ Stored Procedures importados correctamente</li>
            </ul>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="container">
      {/* Header */}
      <header className="header">
        <div className="header-logo">
          <div className="logo-box">UN</div>
          <div>
            <h1>SIMBA - Panel Administrador</h1>
            <p className="subtitle">Sala de Informática de Medicina - Base de administración</p>
          </div>
        </div>
        <div className="header-user">
          <strong>Carlos Cuevas</strong>
          <p>Administrador del Sistema</p>
        </div>
      </header>

      {/* Navigation Tabs */}
      <nav className="nav-tabs">
        <button className="tab active">Dashboard</button>
        <button className="tab">Sesiones Activas</button>
        <button className="tab">Gestión Computadores</button>
        <button className="tab">Reservas de Salas</button>
        <button className="tab">Turnos Monitores</button>
        <button className="tab">Supervisión</button>
        <button className="tab">Reportes</button>
      </nav>

      {/* Tarjetas de Estadísticas */}
      <div className="stats-grid">
        <div className="stat-card blue">
          <div className="stat-icon">👥</div>
          <div>
            <h3>{estadisticas.sesionesActivas}</h3>
            <p>Sesiones/Turnos Activos</p>
            <small>Datos en tiempo real</small>
          </div>
        </div>

        <div className="stat-card green">
          <div className="stat-icon">🔍</div>
          <div>
            <h3>{estadisticas.supervisiones}</h3>
            <p>Supervisiones Registradas</p>
            <small>Desde BD</small>
          </div>
        </div>

        <div className="stat-card purple">
          <div className="stat-icon">🏫</div>
          <div>
            <h3>3 de 4</h3>
            <p>Salas Habilitadas</p>
            <small>Sala D reservada</small>
          </div>
        </div>

        <div className="stat-card orange">
          <div className="stat-icon">💾</div>
          <div>
            <h3>Conectado</h3>
            <p>Base de Datos MySQL</p>
            <small>simba_squema</small>
          </div>
        </div>
      </div>

      {/* Estado de las Salas */}
      <section className="section">
        <div className="section-header">
          <h2>Estado de las Salas</h2>
          <button className="btn-nueva-reserva">+ Nueva Reserva</button>
        </div>
        <div className="salas-grid">
          {salas.map((sala, index) => (
            <div key={index} className={`sala-card ${sala.estado === 'Bloqueada' ? 'bloqueada' : ''}`}>
              <div className="sala-header">
                <h3>{sala.nombre}</h3>
                {sala.estado === 'Bloqueada' ? (
                  <span className="badge-bloqueado">🔒 Bloqueada</span>
                ) : (
                  <span className="badge-disponible">✓ Disponible</span>
                )}
              </div>
              
              {sala.estado === 'Bloqueada' ? (
                <div className="sala-bloqueada-info">
                  <p>⚠️ Sala No Disponible</p>
                  <p className="small">Reservada para actividades académicas del día</p>
                </div>
              ) : (
                <div className="sala-stats">
                  <div className="sala-stat">
                    <span className="sala-numero disponible">{sala.disponibles}</span>
                    <span className="sala-label">Disponibles</span>
                  </div>
                  <div className="sala-stat">
                    <span className="sala-numero ocupado">{sala.ocupados}</span>
                    <span className="sala-label">Ocupados</span>
                  </div>
                  <div className="sala-stat">
                    <span className="sala-numero bloqueado">{sala.bloqueados}</span>
                    <span className="sala-label">Bloqueados</span>
                  </div>
                  <div className="sala-stat">
                    <span className="sala-numero total">{sala.total}</span>
                    <span className="sala-label">Total</span>
                  </div>
                </div>
              )}
              
              {sala.estado !== 'Bloqueada' && (
                <div className="sala-progress">
                  <div 
                    className="sala-progress-bar" 
                    style={{width: `${(sala.ocupados/sala.total)*100}%`}}
                  ></div>
                </div>
              )}
            </div>
          ))}
        </div>
      </section>

      {/* Lista de Sesiones/Turnos desde BD */}
      <section className="section">
        <div className="section-header">
          <h2>Sesiones/Turnos desde Base de Datos ({sesionesesFiltradas.length} registros)</h2>
          <div className="filters">
            <input 
              type="text" 
              placeholder="🔍 Buscar..."
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              className="input-busqueda"
            />
            <button className="btn-refresh" onClick={cargarDatos}>🔄 Recargar</button>
          </div>
        </div>

        <div className="info-banner success">
          <span>✅</span>
          <p><strong>Conectado a MySQL</strong> - Datos obtenidos desde stored procedures. Base de datos: simba_squema</p>
        </div>

        {sesionesesFiltradas.length === 0 ? (
          <div className="empty-state">
            <p>📋 No hay datos disponibles en la base de datos</p>
            <small>Verifica que los stored procedures estén funcionando correctamente</small>
          </div>
        ) : (
          <div className="tabla-container">
            <table className="tabla">
              <thead>
                <tr>
                  {Object.keys(sesionesesFiltradas[0]).map(key => (
                    <th key={key}>{key}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {sesionesesFiltradas.map((item, index) => (
                  <tr key={index}>
                    {Object.values(item).map((value, i) => (
                      <td key={i}>{String(value)}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* Footer Note */}
      <div className="nota success">
        <p>✅ <strong>Sistema Conectado:</strong> Datos en tiempo real desde MySQL usando Stored Procedures</p>
      </div>
    </div>
  )
}

export default App