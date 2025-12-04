-- // ==========================================
-- // Sistema de administración de computadores
-- // ==========================================

DELIMITER &&

-- Ver sesiones en curso (Vista 1)
CREATE PROCEDURE sp_monVerSesionesActuales()
BEGIN
    SELECT * FROM vw_Sesiones_En_Curso;
END &&

-- Ver historial de sesiones on filtro (Vista 2)
CREATE PROCEDURE sp_monVerSesionesHistorial(
    IN dia date, IN horaInicial time, IN horaFinal, time, IN idSala char(1), IN idComputador int,
    IN tiunEstudiante bigint, IN nombreEstudiante varchar(45), IN apellidoEstudiante varchar(45)
)
BEGIN
    SELECT *
    FROM vw_Historial_Sesiones
    WHERE
        (@dia_sesion is null or Ses_Fecha=@dia_sesion)
        and (@hora_inicial is null or @hora_inicial<Ses_HoraFin)
        and (@hora_final is null or @hora_final>Ses_HoraInicio)
        and (@sala is null or Sal_Id=@sala)
        and (@computador is null or Com_Id=@computador)
        and (@tiun_estudiante is null or Est_Tiun LIKE CONCAT(@tiun_estudiante, '%'))
        and (@nombre_estudiante is null or Est_Nombre LIKE CONCAT('%', @nombre_estudiante, '%'))
        and (@apellido_estudiante is null or Est_Apellido LIKE CONCAT('%', @apellido_estudiante, '%'));
END &&

-- Ver historial de sesiones con comentarios, con filtro (Vista 3)
CREATE PROCEDURE sp_monVerSesionesConComentarios(
    IN dia date, IN horaInicial time, IN horaFinal, time, IN idSala char(1), IN idComputador int,
    IN tiunEstudiante bigint, IN nombreEstudiante varchar(45), IN apellidoEstudiante varchar(45)
)
BEGIN
    SELECT *
    FROM vw_Sesiones_Con_Incidentes
    WHERE
        (@dia_sesion is null or Ses_Fecha=@dia_sesion)
        and (@hora_inicial is null or @hora_inicial<Ses_HoraFin)
        and (@hora_final is null or @hora_final>Ses_HoraInicio)
        and (@sala is null or Sal_Id=@sala)
        and (@computador is null or Com_Id=@computador)
        and (@tiun_estudiante is null or Est_Tiun LIKE CONCAT(@tiun_estudiante, '%'))
        and (@nombre_estudiante is null or Est_Nombre LIKE CONCAT('%', @nombre_estudiante, '%'))
        and (@apellido_estudiante is null or Est_Apellido LIKE CONCAT('%', @apellido_estudiante, '%'));
END &&