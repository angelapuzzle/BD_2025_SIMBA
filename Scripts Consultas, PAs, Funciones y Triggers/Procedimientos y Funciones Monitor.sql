-- // ==========================================
-- // Sistema de administración de computadores
-- // ==========================================

DELIMITER &&

-- Ver sesiones en curso (Vista 1)
DROP PROCEDURE IF EXISTS sp_verSesionesActuales &&
CREATE PROCEDURE sp_verSesionesActuales(
    IN horaInicial time, IN idSala char(1), IN idComputador int,
    IN tiunEstudiante bigint, IN nombreEstudiante varchar(45), IN apellidoEstudiante varchar(45)
    IN filtrarIncidentes smallint
)
BEGIN
    SELECT *
    FROM vw_Sesiones
    WHERE
        (horaInicial is null or horaInicial<Ses_HoraFin)
        and (idSala is null or Sal_Id=idSala)
        and (idComputador is null or Com_Id=idComputador)
        and (tiunEstudiante is null or Est_Tiun LIKE CONCAT(tiunEstudiante, '%'))
        and (nombreEstudiante is null or Est_Nombre LIKE CONCAT('%', nombreEstudiante, '%'))
        and (apellidoEstudiante is null or Est_Apellido LIKE CONCAT('%', apellidoEstudiante, '%'))
        and (filtrarIncidentes is null or filtrarIncidentes = 0 or (Sal_Comentarios is not null and Sal_Comentarios != ''))
        and (Ses_Fecha = CURRENT_DATE() and Ses_HoraFin is null);
END &&

-- Ver historial de sesiones on filtro (Vista 1)
DROP PROCEDURE IF EXISTS sp_verSesionesHistorial &&
CREATE PROCEDURE sp_verSesionesHistorial(
    IN dia date, IN horaInicial time, IN horaFinal, time, IN idSala char(1), IN idComputador int,
    IN tiunEstudiante bigint, IN nombreEstudiante varchar(45), IN apellidoEstudiante varchar(45)
    IN filtrarIncidentes smallint
)
BEGIN
    SELECT *
    FROM vw_Sesiones
    WHERE
        (@dia_sesion is null or Ses_Fecha=@dia_sesion)
        and (horaInicial is null or horaInicial<Ses_HoraFin)
        and (@hora_final is null or @hora_final>Ses_HoraInicio)
        and (idSala is null or Sal_Id=idSala)
        and (idComputador is null or Com_Id=idComputador)
        and (tiunEstudiante is null or Est_Tiun LIKE CONCAT(tiunEstudiante, '%'))
        and (nombreEstudiante is null or Est_Nombre LIKE CONCAT('%', nombreEstudiante, '%'))
        and (apellidoEstudiante is null or Est_Apellido LIKE CONCAT('%', apellidoEstudiante, '%'))
        and (filtrarIncidentes is null or filtrarIncidentes = 0 or (Sal_Comentarios is not null and Sal_Comentarios != ''));
END &&

-- Aquí irá lo de la Mariana
-- te quiero Mariana <3

-- // ==========================================
-- // Reserva de salas 
-- // ==========================================

DELIMITER &&

-- Ver reservas filtradas (Vista 6)
DROP PROCEDURE IF EXISTS sp_verReservas;
CREATE PROCEDURE sp_verReservas(
    IN dia date, IN horaInicial time, IN horaFinal time, IN idSala char(1),
    IN tiunEmpleado bigint, IN nombreEmpleado varchar(45), apellidoEmpleado varchar(45), IN correoEmpleado varchar(45),
    IN estadoReserva varchar(45)
)
BEGIN
    SELECT Act_Comentarios, Act_Fecha, Act_HoraInicio, Act_HoraFin, Sal_Id, Emp_Nombre, Emp_Apellido, Emp_Correo, Fac_Nombre, Estado_Actividad
    FROM vw_Actividades_Detalladas
    WHERE
        (dia is null or Act_Fecha=dia)
        and (horaInicial is null or horaInicial<Act_HoraFin)
        and (horaFinal is null or horaFinal>Act_HoraInicio)
        and (idSala is null or Sal_Id=idSala)
        and (tiunEmpleado is null or Emp_Tiun LIKE CONCAT(tiunEmpleado, '%'))
        and (nombreEmpleado is null or Emp_Nombre LIKE CONCAT('%', nombreEmpleado, '%'))
        and (apellidoEmpleado is null or Emp_Apellido LIKE CONCAT('%', apellidoEmpleado, '%'))
        and (correoEmpleado is null or Emp_Correo LIKE CONCAT(correoEmpleado, '%'))
        and (estadoReserva is null or Estado_Actividad=estadoReserva);
END

-- Agregar reserva
DROP PROCEDURE IF EXISTS sp_agregarReserva;
CREATE PROCEDURE sp_agregarReserva(
    IN dia date, IN horaInicial time, IN horaFinal time,
    IN idSala char(1), IN comentarios longtext, IN tiunEmpleado bigint
)
sp: BEGIN
    DECLARE totalColisiones INT DEFAULT 0;

    START TRANSACTION;

    -- Ver colisiones con otras reservas
    SELECT COUNT(*)
    INTO totalColisiones
    FROM Actividad
    WHERE Act_Fecha=dia and Sal_Id=idSala and horaInicial<Act_HoraFin and horaFinal>Act_HoraInicio;

    IF totalColisiones > 0 THEN
        SELECT * FROM vw_Actividades_Detalladas
        WHERE Act_Fecha=dia and Sal_Id=idSala and horaInicial<Act_HoraFin and horaFinal>Act_HoraInicio;

        ROLLBACK;
        LEAVE sp;
    END IF;

    -- Registrar reserva
    INSERT INTO Actividad values(dia, horaInicial, horaFinal, idSala, tiunEmpleado, comentarios);
    COMMIT;
END &&

-- Cancelar reserva
DROP PROCEDURE IF EXISTS sp_cancelarReserva &&
CREATE PROCEDURE sp_cancelarReserva(IN dia date, IN horaInicial time, IN idSala char(1))
BEGIN    
    DELETE FROM Actividad WHERE Act_Fecha=dia and Act_HoraInicio=horaInicial and Sal_Id=idSala;
END &&

-- Deshabilitar sala manualmente (y cerrar sesiones activas)
DROP PROCEDURE IF EXISTS sp_deshabilitarSala &&
CREATE PROCEDURE sp_deshabilitarSala(IN idSala char(1))
BEGIN
    START TRANSACTION;
    
    UPDATE Sala SET Sal_Disponibilidad = 0 WHERE Sal_Id=idSala;

    -- Basta con actualizar las Sesiones ya que el trigger tr_cierreSesion
    -- se encarga de habilitar los computadores
    UPDATE Sesion
    SET Ses_HoraFin = current_time()
    WHERE (
        Sal_Id=@sala
        and Ses_Fecha = CURRENT_DATE()
        and Ses_HoraFin is null
    );

    COMMIT;
END &&

-- Habilitar sala manualmente
CREATE PROCEDURE sp_habilitarSala(IN idSala char(1))
BEGIN
    UPDATE Sala SET Sal_Disponibilidad = 1 WHERE Sal_Id=idSala;
END &&

DELIMITER ;

-- // ==========================================
-- // Registro monitor (al iniciar sesión)
-- // ==========================================

DELIMITER &&

-- Registrar nuevo turno en login ---> Genera llave artificial
DROP FUNCTION IF EXISTS fn_monitorLogin &&
CREATE FUNCTION fn_monitorLogin(fechaTurno date, horaInicial time, idSala char(1), numMonitor int)
RETURNS int DETERMINISTIC
READS SQL DATA
BEGIN    
    INSERT INTO Turno_Mon(Tur_Fecha, Tur_HoraInicio, Sal_Id, Mon_Numero)
    VALUES (fechaTurno, horaInicial, idSala, numMonitor);

    RETURN last_insert_id();
END &&

-- Actualizar turno en logout
DROP PROCEDURE IF EXISTS sp_monitorLogout &&
CREATE PROCEDURE sp_monitorLogout(IN idTurno int, IN horaFinal time)
BEGIN
    UPDATE Turno_Mon SET Tur_HoraFinal=horaFinal WHERE Tur_Id=idTurno;
END &&

DELIMITER ;
