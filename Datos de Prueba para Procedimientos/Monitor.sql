-- ===================
-- Cancelar Reserva
-- ===================

-- Ver reservas
SELECT * FROM vw_Actividades_Detalladas;

-- Cancelar reserva
CALL sp_cancelarReserva(
    '2023-10-31',   -- Día
    '09:30:00',     -- Hora
    'C'             -- Sala
);



-- ===================
-- Deshabilitar y Habilitar Sala
-- ===================

-- Inicializar sala correctamente
UPDATE Computador SET Comp_Disponibilidad = 1 WHERE Sal_Id='C' and Comp_Disponibilidad is not null;

-- Sesión de prueba
CALL sp_nuevaSesion(1234567890, 'C', 3245);

-- Ver estado salas
SELECT * FROM vw_Ocupacion_Salas;

-- Ver sesiones en curso
CALL sp_verSesionesActuales(null, null, null, null, null, null, null);

-- Deshabilitar Sala
CALL sp_deshabilitarSala('C');

-- Habilitar Sala
CALL sp_habilitarSala('C');



-- ===================
-- Iniciar y Cerrar Sesion Monitor
-- ===================

-- Ver turnos monitores
CALL sp_verTurnosMonitores(null, null, null, null, null, null, null, null, null);

-- Iniciar turno monitor
SET @monIdTurno = fn_monitorLogin('A', 3);

SELECT @monIdTurno;

-- Finalizar turno monitor
CALL sp_monitorLogout(@monIdTurno);