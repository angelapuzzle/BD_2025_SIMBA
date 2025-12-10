-- // ==========================================
-- // GESTIÓN DE TURNOS DE MONITORES
-- // ==========================================

DELIMITER &&

DROP PROCEDURE IF EXISTS sp_verTurnosMonitores &&
CREATE PROCEDURE sp_verTurnosMonitores(
    IN diaTurno date, IN horaInicial time, IN horaFinal time, IN idSala char(1), 
    IN numeroMonitor int, IN tiunMonitor bigint, IN nombreMonitor varchar(45), IN apellidoMonitor varchar(45),
    IN estadoTurno varchar(20)
)
BEGIN
    SELECT *
    FROM vw_Turnos_Monitores
    WHERE
        (diaTurno is null or Tur_Fecha=diaTurno)
        and (horaInicial is null or horaInicial<Tur_HoraFinal)
        and (horaFinal is null or horaFinal>Tur_HoraInicio)
        and (idSala is null or Sal_Id LIKE CONCAT(idSala, '%'))
        and (numeroMonitor is null or Mon_Numero=numeroMonitor)
        and (tiunMonitor is null or Est_Tiun LIKE CONCAT(tiunMonitor, '%'))
        and (nombreMonitor is null or Est_Nombre LIKE CONCAT('%', nombreMonitor, '%'))
        and (apellidoMonitor is null or Est_Apellido LIKE CONCAT('%', apellidoMonitor, '%'))
        and (estadoTurno is null or Estado_Turno=estadoTurno);
END &&

DELIMITER ;


-- // ==========================================
-- // GESTIÓN DE SUPERVISIONES
-- // ==========================================

DELIMITER &&

DROP PROCEDURE IF EXISTS sp_verSupervisiones &&
CREATE PROCEDURE sp_verSupervisiones(
    IN diaSupervision date, IN horaInicial time, IN horaFinal time,
    IN tiunAdmin bigint, IN nombreAdmin varchar(45), IN apellidoAdmin varchar(45),
    IN idSala char(1)
)
BEGIN
    SELECT *
    FROM vw_Supervisiones_Admin
    WHERE
        (diaSupervision is null or Sup_Fecha=diaSupervision)
        and (horaInicial is null or horaInicial<Sup_HoraFinal)
        and (horaFinal is null or horaFinal>Sup_HoraInicio)
        and (tiunAdmin is null or Adm_Tiun LIKE CONCAT(tiunAdmin, '%'))
        and (nombreAdmin is null or Adm_Nombre LIKE CONCAT('%', nombreAdmin, '%'))
        and (apellidoAdmin is null or Adm_Apellido LIKE CONCAT('%', apellidoAdmin, '%'))
        and (idSala is null or Salas LIKE CONCAT('%', idSala, '%'));
END &&

DROP PROCEDURE IF EXISTS sp_verSupervisados &&
CREATE PROCEDURE sp_verSupervisados(
    IN diaTurno date, IN turnoHoraInicial time, IN turnoHoraFinal time, IN idSala char(1), 
    IN tiunMonitor bigint, IN nombreMonitor varchar(45), IN apellidoMonitor varchar(45),
    IN tiunAdmin bigint, IN nombreAdmin varchar(45), IN apellidoAdmin varchar(45),
    IN supHoraInicial time, IN supHoraFinal time
)
BEGIN
    SELECT *
    FROM vw_Supervision_Monitor_Admin
    WHERE
        (diaTurno is null or Tur_Fecha=diaTurno)
        and (turnoHoraInicial is null or turnoHoraInicial<Tur_HoraFinal)
        and (turnoHoraFinal is null or turnoHoraFinal>Tur_HoraInicio)
        and (idSala is null or Sal_Id LIKE CONCAT(idSala, '%'))
        and (tiunMonitor is null or Est_Tiun LIKE CONCAT(tiunMonitor, '%'))
        and (nombreMonitor is null or Est_Nombre LIKE CONCAT('%', nombreMonitor, '%'))
        and (apellidoMonitor is null or Est_Apellido LIKE CONCAT('%', apellidoMonitor, '%'))
        and (tiunAdmin is null or Adm_Tiun LIKE CONCAT(tiunAdmin, '%'))
        and (nombreAdmin is null or Adm_Nombre LIKE CONCAT('%', nombreAdmin, '%'))
        and (apellidoAdmin is null or Adm_Apellido LIKE CONCAT('%', apellidoAdmin, '%'))
        and (supHoraInicial is null or supHoraInicial<Sup_HoraFinal)
        and (supHoraFinal is null or supHoraFinal>Sup_HoraInicio);
END &&

DELIMITER ;


-- // ==========================================
-- // TURNO DE ADMINISTRADOR
-- // ==========================================

DELIMITER &&

-- Registrar nuevo turno en login ---> Genera llave artificial
DROP PROCEDURE IF EXISTS sp_adminLogin &&
CREATE PROCEDURE sp_adminLogin(fechaTurno date, horaInicial time, tiunAdmin bigint)
BEGIN    
    INSERT INTO Turno_Adm(Sup_Fecha, Sup_HoraInicio, Adm_Tiun) 
    VALUES (fechaTurno, horaInicial, tiunAdmin);
END &&

-- Actualizar turno en logout
DROP PROCEDURE IF EXISTS sp_adminLogout &&
CREATE PROCEDURE sp_adminLogout(fechaTurno date, horaInicial time, tiunAdmin bigint, horaFinal time)
BEGIN
    UPDATE Turno_Adm SET Sup_HoraFinal=horaFinal
    WHERE (Sup_Fecha, Sup_HoraInicio, Adm_Tiun) = (fechaTurno, horaInicial, tiunAdmin);
END &&

-- Ver historial de turnos filtrado por atributos
DROP PROCEDURE IF EXISTS sp_verTurnosAdmins &&
CREATE PROCEDURE sp_verTurnosAdmins(
    IN diaSupervision date, IN horaInicial time, IN horaFinal time,
    IN tiunAdmin bigint, IN nombreAdmin varchar(45), IN apellidoAdmin varchar(45),
    IN estadoTurno varchar(20)
)
BEGIN
    SELECT *
    FROM vw_Turnos_Administradores
    WHERE
        (diaSupervision is null or Sup_Fecha=diaSupervision)
        and (horaInicial is null or horaInicial<Sup_HoraFinal)
        and (horaFinal is null or horaFinal>Sup_HoraInicio)
        and (tiunAdmin is null or Adm_Tiun LIKE CONCAT(tiunAdmin, '%'))
        and (nombreAdmin is null or Adm_Nombre LIKE CONCAT('%', nombreAdmin, '%'))
        and (apellidoAdmin is null or Adm_Apellido LIKE CONCAT('%', apellidoAdmin, '%'))
        and (estadoTurno is null or Estado_Turno=estadoTurno);
END &&

DELIMITER ;
