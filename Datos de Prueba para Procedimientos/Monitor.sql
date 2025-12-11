-- // ==========================================
-- // Sistema de administración de computadores
-- // ==========================================


-- 1. Ver sesiones en curso con filtro (Vista 1)
	-- DATOS DE PRUEBA
	-- Creación de nuevas sesiones vigentes
		 CALL sp_nuevaSesion(1234567898,'C',3245);
		 CALL sp_nuevaSesion(1234567896,'C',3251);
	-- Llamado a vista para comparar
	SELECT * FROM vw_Sesiones;
	-- Uso del procedimiento
	CALL sp_verSesionesActuales (null,'C',null,null,null,null,null);
	CALL sp_verSesionesActuales (null,null,null,null,'Jaime',null,null);
    
-- ////////////////////////////////////////////////////

-- 2. Ver historial de sesiones con filtro (Vista 1)

-- DATOS DE PRUEBA
	-- 1. Historial completo de la Sala 'A'
	CALL sp_verSesionesHistorial (NULL, NULL, NULL, 'A', NULL, NULL, NULL, NULL, NULL);
	-- 2. Historial de sesiones con incidentes (Sal_Comentarios is not null)
	CALL sp_verSesionesHistorial (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1);
	-- 3. Historial de la Sala 'B' para el día '2023-10-30'
	CALL sp_verSesionesHistorial ('2023-10-30', NULL, NULL, 'B', NULL, NULL, NULL, NULL, NULL);
	-- 4. Sesiones donde participó el Estudiante con TIUN '1234567896' (Jaime Garzon)
	CALL sp_verSesionesHistorial (NULL, NULL, NULL, NULL, NULL, 1234567896, NULL, NULL, NULL);

-- ////////////////////////////////////////////////////

-- 3. Ver estadísticas de uso por computador filtradas (Vista 5)       

-- Datos de prueba
	-- 1. Estadísticas de todos los computadores de la Sala 'A'
	CALL sp_monVerEstadisticasComp ('A', NULL);

-- 2. Estadísticas de un computador específico (3256) en la Sala 'C'
	CALL sp_monVerEstadisticasComp ('C', 3256);

-- ////////////////////////////////////////////////////

-- 4. Ver historial de uso de un computador (Vista 1)

-- DATOS DE PRUEBA
	-- 1. Historial completo del Computador 1237 en la Sala 'A'
	CALL sp_monVerHistorialPc ('A', 1237, NULL);

	-- 2. Historial del Computador 2241 en la Sala 'B' de los últimos 2 días (Fecha: 2023-10-30 y 2023-10-31)
		-- Creación sesión de prueba
		-- CALL sp_nuevaSesion(1234567898,'B',2241);
		CALL sp_monVerHistorialPc ('B', 2241, 2);
        
-- ////////////////////////////////////////////////////

-- 5. Inhabilitar o bloquear computador y cerrar sesión

-- Datos de prueba
	-- Verificar estado actual del computador 1235-A (debe ser 1: Disponible)
		SELECT Com_Id, Sal_Id, Comp_Disponibilidad FROM Computador WHERE Com_Id = 1235 AND Sal_Id = 'A';

	-- 1. Inhabilitar (Bloquear) el computador 1235-A (inhabilitar=1).
	-- Nota: Si el PC tuviera una sesión activa, esta se cerraría con Ses_HoraFin = CURRENT_TIME().
		CALL sp_compHabilitarInhabilitar (1, 'A', 1235);
	-- 2. Verificar que la disponibilidad es NULL (Inhabilitado)
		SELECT Com_Id, Sal_Id, Comp_Disponibilidad FROM Computador WHERE Com_Id = 1235 AND Sal_Id = 'A';
	-- 3. Habilitar el computador 1235-A (inhabilitar=0).
		CALL sp_compHabilitarInhabilitar (0, 'A', 1235);
	-- 4. Verificar que la disponibilidad es 1 (Disponible)
		SELECT Com_Id, Sal_Id, Comp_Disponibilidad FROM Computador WHERE Com_Id = 1235 AND Sal_Id = 'A';

-- ////////////////////////////////////////////////////

-- 6. Agregar comentario a una sesión

-- Datos de prueba
	-- 1. Comprobación inicial
		SELECT * FROM Sesion 
		WHERE Ses_Fecha = '2023-10-30' AND Ses_HoraInicio = '14:00:00' AND Com_Id = 1235 AND Sal_Id = 'A';
	-- 2. Agregar comentario/incidente a la sesión
		CALL sp_agregarComentarioSesion ('2023-10-30', '14:00:00', 1235, 'A', 'El teclado presenta una falla intermitente.');

	-- 3. Verificar que el comentario se haya agregado
	SELECT * FROM Sesion 
	WHERE Ses_Fecha = '2023-10-30' AND Ses_HoraInicio = '14:00:00' AND Com_Id = 1235 AND Sal_Id = 'A';



-- // ==========================================
-- // Reserva de salas 
-- // ==========================================



-- ////////////////////////////////////////////////////

-- 7.  Buscar empleado en el sistema

-- Datos de prueba
	-- 1. Buscar por nombre y apellido: "Jhon Mendoza"
	CALL sp_buscarEmpleado (NULL, 'Jhon', 'Mendoza', NULL);

	-- 2. Buscar por correo que empiece con "hgua"
	CALL sp_buscarEmpleado (NULL, NULL, NULL, 'hgua');

-- ////////////////////////////////////////////////////

-- 8. Inserción de nuevos empleados

-- Datos de prueba
	-- 1. Verificación inicial
    SELECT * FROM Empleado WHERE Emp_Tiun = 312345679;
	-- 2. Insertar un nuevo empleado (TIUN 3123456799, de la Facultad de Ingeniería - 2055)
	CALL sp_monNuevoEmpleado (312345679, 'Leonardo', 'DaVinci', 'ldav@unal.edu.co', 1, NULL, 2055);

	-- 3. Verificar la inserción
	SELECT * FROM Empleado WHERE Emp_Tiun = 312345679;

-- ////////////////////////////////////////////////////

-- 9. Actualización datos empleados


-- Datos de prueba
	-- 1. Actualizar el cargo del nuevo empleado
	CALL sp_monEditarEmpleado (312345679, NULL, NULL, 'leodv@unal.edu.co', 0, 'Coordinador de Innovación', 2055);

	-- 2. Verificar la actualización
	SELECT * FROM Empleado WHERE Emp_Tiun = 312345679;

-- ////////////////////////////////////////////////////

-- 10. Ver reservas filtradas (Vista 6)

-- Datos de prueba
	-- 1. Filtro general
	CALL sp_verReservas (null, null,null,null,null,null,null,null,null);
    -- 2. Filtro por nombre
	CALL sp_verReservas (null, null,null,null,null,'Isabella',null,null,null);

-- ////////////////////////////////////////////////////

-- 11. Agregar reserva


-- Datos de prueba
	-- 1. Comprobación inicial.'2023-10-30','09:30:00','11:30:00','D',3123456790,'Introducción a químicos explosivos'
	SELECT * FROM Actividad WHERE Act_Fecha = '2023-11-29' AND Act_HoraInicio = '14:00:00' AND Sal_Id = 'D';
	-- 2. Crear la reserva.
	CALL sp_agregarReserva('2023-11-29', '14:00:00', '17:00:00','D', 'Taller de modelos de series de tiempo.',3123456794);
	-- 3. Comprobación final
    SELECT * FROM Actividad WHERE Act_Fecha = '2023-11-29' AND Act_HoraInicio = '14:00:00' AND Sal_Id = 'D';
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
