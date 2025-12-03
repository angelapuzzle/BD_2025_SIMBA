/*--------------------------------------------------------
		VISTAS GENERALES PARA EL SISTEMA SIM_BA
--------------------------------------------------------*/

USE SIM_BA;

-- ========================================
-- VISTAS PARA ESTUDIANTES
-- ========================================

-- Vista: Computadores disponibles en salas habilitadas
    DROP VIEW IF EXISTS vw_com_disp;
    CREATE VIEW vw_com_disp AS
    SELECT 
        c.Sal_Id,
        c.Com_Id,
        c.Comp_Disponibilidad,
        s.Sal_Disponibilidad
    FROM computador c
    NATURAL JOIN sala s
    WHERE c.Comp_Disponibilidad = 1 
      AND s.Sal_Disponibilidad = 1
    ORDER BY c.Sal_Id, c.Com_Id;

-- Vista: Todos los computadores de salas habilitadas (incluye disponibles y ocupados)
    DROP VIEW IF EXISTS vw_com_sala;
    CREATE VIEW vw_com_sala AS
    SELECT 
        c.Com_Id,
        c.Comp_Disponibilidad,
        c.Sal_Id,
        s.Sal_Disponibilidad
    FROM computador c
    NATURAL JOIN sala s
    WHERE s.Sal_Disponibilidad = 1 
      AND c.Comp_Disponibilidad IS NOT NULL
    ORDER BY c.Sal_Id, c.Com_Id;

-- Vista: Resumen de ocupación por sala
    DROP VIEW IF EXISTS vw_Ocupacion_Salas;
    CREATE VIEW vw_Ocupacion_Salas AS
    SELECT 
        s.Sal_Id,
        s.Sal_Disponibilidad,
        COUNT(c.Com_Id) AS Total_Computadores,
        SUM(CASE WHEN c.Comp_Disponibilidad = 1 THEN 1 ELSE 0 END) AS Disponibles,
        SUM(CASE WHEN c.Comp_Disponibilidad = 0 THEN 1 ELSE 0 END) AS Ocupados,
        SUM(CASE WHEN c.Comp_Disponibilidad IS NULL THEN 1 ELSE 0 END) AS Bloqueados,
        ROUND(
            (SUM(CASE WHEN c.Comp_Disponibilidad = 0 THEN 1 ELSE 0 END) / COUNT(c.Com_Id)) * 100, 
            2
        ) AS Porcentaje_Ocupacion
    FROM Sala s
    LEFT JOIN Computador c ON s.Sal_Id = c.Sal_Id
    GROUP BY s.Sal_Id, s.Sal_Disponibilidad
    ORDER BY s.Sal_Id;

-- ========================================
-- VISTAS PARA MONITORES
-- ========================================

-- Vista 1: Ver sesiones en curso
    DROP VIEW IF EXISTS vw_Sesiones_En_Curso;
    CREATE VIEW vw_Sesiones_En_Curso AS
    SELECT 
        s.Ses_Fecha,
        s.Ses_HoraInicio,
        s.Ses_HoraFin,
        s.Com_Id,
        s.Sal_Id,
        s.Mon_Numero,
        s.Est_Tiun,
        s.Sal_Comentarios,
        e.Est_Nombre,
        e.Est_Apellido,
        e.Est_Correo,
        e.Pro_Codigo,
        p.Pro_Nombre,
        TIMESTAMPDIFF(MINUTE, s.Ses_HoraInicio, CURRENT_TIME()) AS Duracion_Minutos
    FROM Sesion s
    NATURAL JOIN Estudiante e
    NATURAL JOIN Programa p
    WHERE s.Ses_Fecha = CURRENT_DATE() 
      AND s.Ses_HoraFin IS NULL
    ORDER BY s.Ses_HoraInicio;
    
-- Vista 2: Historial completo de sesiones con información del estudiante y monitor
    DROP VIEW IF EXISTS vw_Historial_Sesiones;
    CREATE VIEW vw_Historial_Sesiones AS
    SELECT 
        s.Ses_Fecha,
        s.Ses_HoraInicio,
        s.Ses_HoraFin,
        s.Com_Id,
        s.Sal_Id,
        s.Sal_Comentarios,
        e.Est_Tiun,
        e.Est_Nombre,
        e.Est_Apellido,
        e.Est_Correo,
        p.Pro_Codigo,
        p.Pro_Nombre,
        f.Fac_Nombre,
        s.Mon_Numero,
        em.Est_Nombre AS Monitor_Nombre,
        em.Est_Apellido AS Monitor_Apellido,
        CASE 
            WHEN s.Ses_HoraFin IS NULL THEN 'Activa'
            ELSE 'Finalizada'
        END AS Estado_Sesion,
        CASE 
            WHEN s.Ses_HoraFin IS NULL THEN TIMESTAMPDIFF(MINUTE, s.Ses_HoraInicio, CURRENT_TIME())
            ELSE TIMESTAMPDIFF(MINUTE, s.Ses_HoraInicio, s.Ses_HoraFin)
        END AS Duracion_Minutos
    FROM Sesion s
    JOIN Estudiante e ON s.Est_Tiun = e.Est_Tiun
    JOIN Programa p ON e.Pro_Codigo = p.Pro_Codigo
    JOIN Facultad f ON p.Fac_Codigo = f.Fac_Codigo
    LEFT JOIN Monitor m ON s.Mon_Numero = m.Mon_Numero
    LEFT JOIN Estudiante em ON m.Est_Tiun = em.Est_Tiun
    ORDER BY s.Ses_Fecha DESC, s.Ses_HoraInicio DESC;
    
-- Vista 3: Sesiones con comentarios/incidentes
    DROP VIEW IF EXISTS vw_Sesiones_Con_Incidentes;
    CREATE VIEW vw_Sesiones_Con_Incidentes AS
    SELECT 
        s.Ses_Fecha,
        s.Ses_HoraInicio,
        s.Ses_HoraFin,
        s.Com_Id,
        s.Sal_Id,
        s.Sal_Comentarios,
        e.Est_Nombre,
        e.Est_Apellido,
        p.Pro_Nombre,
        em.Est_Nombre AS Monitor_Nombre,
        em.Est_Apellido AS Monitor_Apellido
    FROM Sesion s
    JOIN Estudiante e ON s.Est_Tiun = e.Est_Tiun
    JOIN Programa p ON e.Pro_Codigo = p.Pro_Codigo
    LEFT JOIN Monitor m ON s.Mon_Numero = m.Mon_Numero
    LEFT JOIN Estudiante em ON m.Est_Tiun = em.Est_Tiun
    WHERE s.Sal_Comentarios IS NOT NULL 
      AND s.Sal_Comentarios != ''
    ORDER BY s.Ses_Fecha DESC, s.Ses_HoraInicio DESC;
    
-- Vista 4: Reporte de ocupación diaria
    DROP VIEW IF EXISTS vw_Ocupacion_Diaria;
    CREATE VIEW vw_Ocupacion_Diaria AS
    SELECT 
        s.Ses_Fecha AS Fecha,
        s.Sal_Id,
        COUNT(DISTINCT s.Com_Id) AS Computadores_Usados,
        COUNT(*) AS Total_Sesiones,
        ROUND(
            SUM(TIMESTAMPDIFF(MINUTE, s.Ses_HoraInicio, COALESCE(s.Ses_HoraFin, CURRENT_TIME()))) / 60.0,
            2
        ) AS Horas_Totales_Uso,
        COUNT(DISTINCT s.Est_Tiun) AS Estudiantes_Unicos,
        SUM(CASE WHEN s.Sal_Comentarios IS NOT NULL THEN 1 ELSE 0 END) AS Incidentes_Reportados
    FROM Sesion s
    GROUP BY s.Ses_Fecha, s.Sal_Id
    ORDER BY s.Ses_Fecha DESC, s.Sal_Id;
    
-- Vista 5: Estadísticas de uso por computador
    DROP VIEW IF EXISTS vw_Estadisticas_Computadores;
    CREATE VIEW vw_Estadisticas_Computadores AS
    SELECT 
        c.Com_Id,
        c.Sal_Id,
        c.Comp_Disponibilidad,
        CASE 
            WHEN c.Comp_Disponibilidad = 1 THEN 'Disponible'
            WHEN c.Comp_Disponibilidad = 0 THEN 'Ocupado'
            WHEN c.Comp_Disponibilidad IS NULL THEN 'Inhabilitado'
        END AS Estado_Texto,
        COUNT(s.Ses_Fecha) AS Total_Sesiones,
        SUM(TIMESTAMPDIFF(MINUTE, s.Ses_HoraInicio, COALESCE(s.Ses_HoraFin, CURRENT_TIME()))) AS Minutos_Totales_Uso,
        ROUND(
            SUM(TIMESTAMPDIFF(MINUTE, s.Ses_HoraInicio, COALESCE(s.Ses_HoraFin, CURRENT_TIME()))) / 60.0,
            2
        ) AS Horas_Totales_Uso,
        MAX(s.Ses_Fecha) AS Ultima_Sesion_Fecha,
        MAX(s.Ses_HoraInicio) AS Ultima_Sesion_Hora,
        SUM(CASE WHEN s.Sal_Comentarios IS NOT NULL THEN 1 ELSE 0 END) AS Total_Incidentes
    FROM Computador c
    LEFT JOIN Sesion s ON c.Com_Id = s.Com_Id AND c.Sal_Id = s.Sal_Id
    GROUP BY c.Com_Id, c.Sal_Id, c.Comp_Disponibilidad
    ORDER BY c.Sal_Id, c.Com_Id;
    
-- Vista 6: Actividades/Reservas con información del empleado
    DROP VIEW IF EXISTS vw_Actividades_Detalladas;
    CREATE VIEW vw_Actividades_Detalladas AS
    SELECT 
        a.Act_Fecha,
        a.Act_HoraInicio,
        a.Act_HoraFin,
        a.Sal_Id,
        a.Act_Comentarios,
        e.Emp_Tiun,
        e.Emp_Nombre,
        e.Emp_Apellido,
        e.Emp_Correo,
        e.Doc_Planta,
        e.Fun_Cargo,
        f.Fac_Codigo,
        f.Fac_Nombre,
        TIMESTAMPDIFF(HOUR, a.Act_HoraInicio, a.Act_HoraFin) AS Duracion_Horas,
        CASE 
            WHEN a.Act_Fecha = CURRENT_DATE() 
                 AND a.Act_HoraInicio <= CURRENT_TIME() 
                 AND a.Act_HoraFin >= CURRENT_TIME() 
            THEN 'En curso'
            WHEN a.Act_Fecha > CURRENT_DATE() 
                 OR (a.Act_Fecha = CURRENT_DATE() AND a.Act_HoraInicio > CURRENT_TIME())
            THEN 'Programada'
            ELSE 'Finalizada'
        END AS Estado_Actividad
    FROM Actividad a
    JOIN Empleado e ON a.Emp_Tiun = e.Emp_Tiun
    JOIN Facultad f ON e.Fac_Codigo = f.Fac_Codigo
    ORDER BY a.Act_Fecha DESC, a.Act_HoraInicio;
    
-- Vista 7: Resumen de ocupación por sala
    DROP VIEW IF EXISTS vw_Ocupacion_Salas;
    CREATE VIEW vw_Ocupacion_Salas AS
    SELECT 
        s.Sal_Id,
        s.Sal_Disponibilidad,
        COUNT(c.Com_Id) AS Total_Computadores,
        SUM(CASE WHEN c.Comp_Disponibilidad = 1 THEN 1 ELSE 0 END) AS Disponibles,
        SUM(CASE WHEN c.Comp_Disponibilidad = 0 THEN 1 ELSE 0 END) AS Ocupados,
        SUM(CASE WHEN c.Comp_Disponibilidad IS NULL THEN 1 ELSE 0 END) AS Inhabilitados,
        ROUND(
            (SUM(CASE WHEN c.Comp_Disponibilidad = 0 THEN 1 ELSE 0 END) / COUNT(c.Comp_Disponibilidad)) * 100, 
            2
        ) AS Porcentaje_Ocupacion
    FROM Sala s
    LEFT JOIN Computador c ON s.Sal_Id = c.Sal_Id
    GROUP BY s.Sal_Id, s.Sal_Disponibilidad
    ORDER BY s.Sal_Id;

-- ========================================
-- VISTAS PARA ADMINISTRADORES
-- ========================================

-- Vista 1: Dashboard - Estadísticas generales
    DROP VIEW IF EXISTS vw_Dashboard_Estadisticas;
    CREATE VIEW vw_Dashboard_Estadisticas AS
    SELECT 
        (SELECT COUNT(*) FROM Sesion WHERE Ses_Fecha = CURRENT_DATE() AND Ses_HoraFin IS NULL) AS Sesiones_Activas,
        (SELECT COUNT(*) FROM Computador WHERE Comp_Disponibilidad = 1) AS Computadores_Disponibles,
        (SELECT COUNT(*) FROM Computador WHERE Comp_Disponibilidad IS NOT NULL) AS Computadores_Totales,
        (SELECT COUNT(*) FROM Sala WHERE Sal_Disponibilidad = 1) AS Salas_Habilitadas,
        (SELECT COUNT(*) FROM Sala) AS Salas_Totales,
        (SELECT COUNT(DISTINCT tm.Mon_Numero) 
         FROM Turno_Mon tm 
         WHERE tm.Tur_Fecha = CURRENT_DATE() 
           AND tm.Tur_HoraInicio <= CURRENT_TIME() 
           AND (tm.Tur_HoraFinal IS NULL OR tm.Tur_HoraFinal >= CURRENT_TIME())) AS Monitores_Activos,
        (SELECT COUNT(*) FROM Monitor) AS Monitores_Totales;

-- Vista 2: Supervisiones con detalles completos
    DROP VIEW IF EXISTS vw_Supervisiones_Admin;
    CREATE VIEW vw_Supervisiones_Admin AS
    SELECT 
        ta.Sup_Fecha,
        ta.Sup_HoraInicio,
        ta.Sup_HoraFinal,
        a.Adm_Tiun,
        a.Adm_Nombre,
        a.Adm_Apellido,
        a.Adm_Correo,
        GROUP_CONCAT(DISTINCT CONCAT(e.Est_Nombre, ' ', e.Est_Apellido) SEPARATOR ', ') AS Monitores_Supervisados,
        GROUP_CONCAT(DISTINCT tm.Sal_Id SEPARATOR ', ') AS Salas,
        COUNT(DISTINCT tm.Mon_Numero) AS Cantidad_Monitores
    FROM Turno_Adm ta
    JOIN Administrador a ON ta.Adm_Tiun = a.Adm_Tiun
    LEFT JOIN Turno_Mon tm ON (
        ta.Sup_Fecha = tm.Tur_Fecha 
        AND ta.Sup_HoraInicio < tm.Tur_HoraFinal 
        AND ta.Sup_HoraFinal > tm.Tur_HoraInicio
    )
    LEFT JOIN Monitor m ON tm.Mon_Numero = m.Mon_Numero
    LEFT JOIN Estudiante e ON m.Est_Tiun = e.Est_Tiun
    GROUP BY ta.Sup_Fecha, ta.Sup_HoraInicio, ta.Sup_HoraFinal, a.Adm_Tiun, a.Adm_Nombre, a.Adm_Apellido, a.Adm_Correo
    ORDER BY ta.Sup_Fecha DESC, ta.Sup_HoraInicio DESC;

-- Vista 3: Supervisión de monitores por administradores
    DROP VIEW IF EXISTS vw_Supervision_Monitor_Admin;
    CREATE VIEW vw_Supervision_Monitor_Admin AS
    SELECT 
        tm.Tur_Fecha,
        tm.Tur_HoraInicio,
        tm.Tur_HoraFinal,
        tm.Sal_Id,
        e.Est_Tiun,
        e.Est_Nombre,
        e.Est_Apellido,
        e.Est_Correo,
        a.Adm_Tiun,
        a.Adm_Nombre,
        a.Adm_Apellido,
        a.Adm_Correo,
        ta.Sup_HoraInicio,
        ta.Sup_HoraFinal
    FROM Turno_Mon tm
    JOIN Turno_Adm ta ON (
        tm.Tur_Fecha = ta.Sup_Fecha 
        AND ta.Sup_HoraInicio < tm.Tur_HoraFinal 
        AND ta.Sup_HoraFinal > tm.Tur_HoraInicio
    )
    NATURAL JOIN Monitor m
    NATURAL JOIN Estudiante e
    NATURAL JOIN Administrador a
    ORDER BY tm.Tur_Fecha DESC, tm.Tur_HoraInicio;

-- Vista 4: Turnos de monitores con información completa
    DROP VIEW IF EXISTS vw_Turnos_Monitores;
    CREATE VIEW vw_Turnos_Monitores AS
    SELECT 
        tm.Tur_id,
        tm.Tur_Fecha,
        tm.Tur_HoraInicio,
        tm.Tur_HoraFinal,
        tm.Sal_Id,
        tm.Mon_Numero,
        e.Est_Tiun,
        e.Est_Nombre,
        e.Est_Apellido,
        e.Est_Correo,
        p.Pro_Nombre,
        CASE 
            WHEN tm.Tur_HoraFinal IS NULL THEN 'En curso'
            ELSE 'Finalizado'
        END AS Estado_Turno,
        (SELECT COUNT(*) 
         FROM Sesion s 
         WHERE s.Mon_Numero = tm.Mon_Numero 
           AND s.Ses_Fecha = tm.Tur_Fecha
           AND s.Ses_HoraInicio >= tm.Tur_HoraInicio) AS Sesiones_Supervisadas,
        CASE 
            WHEN tm.Tur_HoraFinal IS NULL THEN TIMESTAMPDIFF(HOUR, tm.Tur_HoraInicio, CURRENT_TIME())
            ELSE TIMESTAMPDIFF(HOUR, tm.Tur_HoraInicio, tm.Tur_HoraFinal)
        END AS Duracion_Horas
    FROM Turno_Mon tm
    JOIN Monitor m ON tm.Mon_Numero = m.Mon_Numero
    JOIN Estudiante e ON m.Est_Tiun = e.Est_Tiun
    JOIN Programa p ON e.Pro_Codigo = p.Pro_Codigo
    ORDER BY tm.Tur_Fecha DESC, tm.Tur_HoraInicio DESC;

-- Vista 5: Turnos de administradores
    DROP VIEW IF EXISTS vw_Turnos_Administradores;
    CREATE VIEW vw_Turnos_Administradores AS
    SELECT 
        ta.Sup_Fecha,
        ta.Sup_HoraInicio,
        ta.Sup_HoraFinal,
        a.Adm_Tiun,
        a.Adm_Nombre,
        a.Adm_Apellido,
        a.Adm_Correo,
        CASE 
            WHEN ta.Sup_HoraFinal IS NULL THEN 'En curso'
            ELSE 'Finalizado'
        END AS Estado_Turno,
        CASE 
            WHEN ta.Sup_HoraFinal IS NULL THEN TIMESTAMPDIFF(HOUR, ta.Sup_HoraInicio, CURRENT_TIME())
            ELSE TIMESTAMPDIFF(HOUR, ta.Sup_HoraInicio, ta.Sup_HoraFinal)
        END AS Duracion_Horas
    FROM Turno_Adm ta
    JOIN Administrador a ON ta.Adm_Tiun = a.Adm_Tiun
    ORDER BY ta.Sup_Fecha DESC, ta.Sup_HoraInicio DESC;
    

-- Vista 6: Conflictos de horarios en reservas
    DROP VIEW IF EXISTS vw_Verificar_Conflictos_Reservas;
    CREATE VIEW vw_Verificar_Conflictos_Reservas AS
    SELECT 
        a1.Act_Fecha,
        a1.Act_HoraInicio AS Reserva1_Inicio,
        a1.Act_HoraFin AS Reserva1_Fin,
        a1.Sal_Id,
        a1.Act_Comentarios AS Actividad1,
        e1.Emp_Nombre AS Responsable1,
        a2.Act_HoraInicio AS Reserva2_Inicio,
        a2.Act_HoraFin AS Reserva2_Fin,
        a2.Act_Comentarios AS Actividad2,
        e2.Emp_Nombre AS Responsable2
    FROM Actividad a1
    JOIN Actividad a2 ON (
        a1.Act_Fecha = a2.Act_Fecha 
        AND a1.Sal_Id = a2.Sal_Id
        AND a1.Act_HoraInicio < a2.Act_HoraFin
        AND a1.Act_HoraFin > a2.Act_HoraInicio
        AND (a1.Act_HoraInicio != a2.Act_HoraInicio OR a1.Emp_Tiun != a2.Emp_Tiun)
    )
    JOIN Empleado e1 ON a1.Emp_Tiun = e1.Emp_Tiun
    JOIN Empleado e2 ON a2.Emp_Tiun = e2.Emp_Tiun
    ORDER BY a1.Act_Fecha DESC, a1.Act_HoraInicio;

/*--------------------------------------------------------
                    CONSULTAS DE PRUEBA
--------------------------------------------------------*/

-- Probar vistas principales
SELECT * FROM vw_com_disp LIMIT 10;
SELECT * FROM vw_Sesiones_En_Curso;
SELECT * FROM vw_Ocupacion_Salas;
SELECT * FROM vw_Historial_Sesiones LIMIT 10;
SELECT * FROM vw_Actividades_Detalladas LIMIT 5;
SELECT * FROM vw_Turnos_Monitores LIMIT 5;
SELECT * FROM vw_Sesiones_Con_Incidentes;
SELECT * FROM vw_Estadisticas_Computadores LIMIT 10;
SELECT * FROM vw_Ocupacion_Diaria;
SELECT * FROM vw_Desempeno_Monitores;