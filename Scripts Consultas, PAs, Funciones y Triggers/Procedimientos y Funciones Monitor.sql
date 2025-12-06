-- // ==========================================
-- // Sistema de administración de computadores
-- // ==========================================

DELIMITER &&

-- Ver sesiones en curso (Vista 1)
DROP PROCEDURE IF EXISTS sp_monVerSesionesActuales &&
CREATE PROCEDURE sp_monVerSesionesActuales(
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
DROP PROCEDURE IF EXISTS sp_monVerSesionesHistorial &&
CREATE PROCEDURE sp_monVerSesionesHistorial(
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

-- Cancelar reserva(WIP)
CREATE PROCEDURE sp_cancelarReserva()
BEGIN

END

-- Atributos: dia, hora_inicial, sala
    -- Atributos de prueba
    SET @dia_actividad = '2023-10-30';
    SET @hora_inicial = cast('13:05:00' AS TIME);
    SET @sala = 'D';
    
    DELETE FROM Actividad WHERE Act_Fecha=@dia_actividad and Act_HoraInicio=@hora_inicial and Sal_Id=@sala;

-- Deshabilitar sala manualmente (y cerrar sesiones activas)
DROP PROCEDURE IF EXISTS sp_deshabilitarSala &&
CREATE PROCEDURE sp_deshabilitarSala(IN idSala int)
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
CREATE PROCEDURE sp_habilitarSala(IN idSala int)
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
CREATE FUNCTION fn_monitorLogin(fechaTurno date, horaInicial time, idSala int, numMonitor int)
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
