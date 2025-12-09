USE SIM_BA;

-- // ==========================================
-- // DASHBOARD - ESTADÍSTICAS GENERALES
-- // ==========================================

-- Dashboard: Obtener todas las estadísticas
    SELECT * FROM vw_Dashboard_Estadisticas;


-- // ==========================================
-- // GESTIÓN DE TURNOS DE MONITORES
-- // ==========================================

-- Ver todos los turnos de monitores
    SELECT * FROM vw_Turnos_Monitores;

-- Ver turnos de un día específico
    SET @fecha = CAST('2023-10-30' AS DATE);
    SELECT * FROM vw_Turnos_Monitores WHERE Tur_Fecha = @fecha;

-- Ver turnos de un monitor específico
    SET @numero_monitor = 1;
    SELECT * FROM vw_Turnos_Monitores WHERE Mon_Numero = @numero_monitor;


-- // ==========================================
-- // GESTIÓN DE SUPERVISIONES
-- // ==========================================

-- Ver todas las supervisiones
    SELECT * FROM vw_Supervisiones_Admin;

-- Ver supervisiones de un administrador específico
    SET @tiun_admin = 2134567891;
    SELECT * FROM vw_Supervisiones_Admin WHERE Adm_Tiun = @tiun_admin;

-- Ver supervisión detallada (qué monitores supervisa)
    SELECT * FROM vw_Supervision_Monitor_Admin;

-- Ver qué monitores están siendo supervisados en un turno específico
    SET @fecha = CAST('2023-10-30' AS DATE);
    SET @hora_inicio_admin = CAST('07:00:00' AS TIME);
    SET @tiun_admin = 2134567891;

    SELECT 
        e.Est_Nombre AS Monitor_Nombre,
        e.Est_Apellido AS Monitor_Apellido,
        tm.Sal_Id,
        tm.Tur_HoraInicio,
        tm.Tur_HoraFinal
    FROM Turno_Adm ta
    JOIN Turno_Mon tm ON (
        ta.Sup_Fecha = tm.Tur_Fecha 
        and ta.Sup_HoraInicio < tm.Tur_HoraFinal 
        and ta.Sup_HoraFinal > tm.Tur_HoraInicio
    )
    JOIN Monitor m ON tm.Mon_Numero = m.Mon_Numero
    JOIN Estudiante e ON m.Est_Tiun = e.Est_Tiun
    WHERE ta.Sup_Fecha = @fecha 
        and ta.Sup_HoraInicio = @hora_inicio_admin 
        and ta.Adm_Tiun = @tiun_admin;

-- // ==========================================
-- // CONFLICTOS EN RESERVAS
-- // ==========================================
    SELECT * FROM vw_Verificar_Conflictos_Reservas;

-- // ==========================================
-- // TURNO DE ADMINISTRADOR
-- // ==========================================
-- Registrar nuevo turno en login --->  genera llave artificial
-- Atributos: id_turno, fecha_turno, hora_inicial
    -- Atributos de prueba (inicio)
    SET @fecha_turno = '2023-11-02';
    SET @hora_inicial = cast('13:00:00' AS TIME);
    SET @tiun_admin = 2134567893;
    -- Atributos de prueba (final)
    SET @hora_final = cast('18:00:00' AS TIME);
    
    -- Inserción al iniciar el turno
    INSERT INTO Turno_Adm(Sup_Fecha, Sup_HoraInicio, Adm_Tiun) VALUES(@fecha_turno, @hora_inicial, @tiun_admin);
    
    -- Actualización de la hora de finalización
    -- Nota, id_turno corresponde con el id de la inserción
    UPDATE Turno_Adm SET Sup_HoraFinal=@hora_final WHERE (Sup_Fecha, Sup_HoraInicio, Adm_Tiun) = (@fecha_turno, @hora_inicial, @tiun_admin);
    
    -- Verificar
    SELECT * FROM Turno_Adm WHERE (Sup_Fecha, Sup_HoraInicio, Adm_Tiun) = (@fecha_turno, @hora_inicial, @tiun_admin);
    
-- Ver historial de turnos filtrado por atributos
-- Atributos (todos opcionales): dia_turno, hora_inicial, hora_final, tiun_admin, nombre_admin,
--  apellido_admin, duracion_minima, duracion_maxima
    -- Atributos de prueba 1: Día y franja horaria
    SET @dia_turno = '2023-10-30';
    SET @hora_inicial = cast('11:45:00' AS TIME);
    SET @hora_final = cast('16:00:00' AS TIME);
    SET @tiun_admin = null;
    SET @nombre_admin = null;
    SET @apellido_admin = null;
    SET @duracion_minima = null;
    SET @duracion_maxima = null;
    -- Atributos de prueba 2: Turnos de entre 5 y 6 horas
    SET @dia_turno = null;
    SET @hora_inicial = null;
    SET @hora_final = null;
    SET @tiun_admin = null;
    SET @nombre_admin = null;
    SET @apellido_admin = null;
    SET @duracion_minima = 5;
    SET @duracion_maxima = 6;
    
    SELECT *
    FROM vw_Turnos_Administradores
    WHERE
        (@dia_turno is null or Sup_Fecha=@dia_turno)
        and (@hora_inicial is null or @hora_inicial<Sup_HoraFinal)
        and (@hora_final is null or @hora_final>Sup_HoraInicio)
        and (@tiun_admin is null or Adm_Tiun LIKE CONCAT(@tiun_admin, '%'))
        and (@nombre_admin is null or Adm_Nombre LIKE CONCAT('%', @nombre_admin, '%'))
        and (@apellido_admin is null or Adm_Apellido LIKE CONCAT('%', @apellido_admin, '%'))
        and (@duracion_minima is null or @duracion_minima<=Duracion_Horas)
        and (@duracion_maxima is null or @duracion_maxima>=Duracion_Horas);