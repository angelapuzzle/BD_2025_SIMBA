-- // ==========================================
-- // Sistema de administración de computadores
-- // ==========================================

DELIMITER &&

-- Ver sesiones en curso (Vista 1)
CREATE PROCEDURE sp_monVerSesionesActuales(
    IN horaInicial time, IN idSala char(1), IN idComputador int,
    IN tiunEstudiante bigint, IN nombreEstudiante varchar(45), IN apellidoEstudiante varchar(45)
)
BEGIN
    SELECT *
    FROM vw_Sesiones
    WHERE
        (@hora_inicial is null or @hora_inicial<Ses_HoraFin)
        and (@sala is null or Sal_Id=@sala)
        and (@computador is null or Com_Id=@computador)
        and (@tiun_estudiante is null or Est_Tiun LIKE CONCAT(@tiun_estudiante, '%'))
        and (@nombre_estudiante is null or Est_Nombre LIKE CONCAT('%', @nombre_estudiante, '%'))
        and (@apellido_estudiante is null or Est_Apellido LIKE CONCAT('%', @apellido_estudiante, '%'))
        and (@filtrar_incidentes is null or (Sal_Comentarios is not null and Sal_Comentarios != ''))
        and (Ses_Fecha = CURRENT_DATE() and Ses_HoraFin is null);
END &&

-- Ver historial de sesiones on filtro (Vista 1)
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
        and (@hora_inicial is null or @hora_inicial<Ses_HoraFin)
        and (@hora_final is null or @hora_final>Ses_HoraInicio)
        and (@sala is null or Sal_Id=@sala)
        and (@computador is null or Com_Id=@computador)
        and (@tiun_estudiante is null or Est_Tiun LIKE CONCAT(@tiun_estudiante, '%'))
        and (@nombre_estudiante is null or Est_Nombre LIKE CONCAT('%', @nombre_estudiante, '%'))
        and (@apellido_estudiante is null or Est_Apellido LIKE CONCAT('%', @apellido_estudiante, '%'))
        and (@filtrar_incidentes is null or (Sal_Comentarios is not null and Sal_Comentarios != ''));
END &&