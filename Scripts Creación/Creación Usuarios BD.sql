-- CREACIÓN DEL USUARIO ESTUDIANTE
    create user	'Estudiante'@'localhost' identified by 'estudiante';
    grant select, update on sim_ba.vw_com_disp to 'Estudiante'@'localhost';
    grant select, insert, update on sim_ba.sesion to 'Estudiante'@'localhost';
    grant insert on sim_ba.estudiante to 'Estudiante'@'localhost';
    grant select, update on sim_ba.vw_com_sala to 'Estudiante'@'localhost';

-- CREACIÓN DEL USUARIO MONITOR
    create user 'Monitor 1'@'localhost' identified by 'securepass1';
    -- Permisos sobre las vistas
    grant select on sim_ba.vw_Sesiones_En_Curso to 'Monitor 1'@'localhost';
    grant select on sim_ba.vw_Historial_Sesiones to 'Monitor 1'@'localhost';
    grant select on sim_ba.vw_Sesiones_Con_Incidentes to 'Monitor 1'@'localhost';
    grant select on sim_ba.vw_Ocupacion_Diaria to 'Monitor 1'@'localhost';
    grant select on sim_ba.vw_Estadisticas_Computadores to 'Monitor 1'@'localhost';
    grant select on sim_ba.vw_Actividades_Detalladas to 'Monitor 1'@'localhost';
    grant select on sim_ba.vw_Ocupacion_Salas to 'Monitor 1'@'localhost';
    -- Permisos para crear tablas temporales
    grant create temporary tables on *.* to 'Monitor 1'@'localhost';
    -- Permisos sobre las tablas principales
    grant select, update on sim_ba.Sesion to 'Monitor 1'@'localhost';
    grant select, update on sim_ba.Computador to 'Monitor 1'@'localhost';
    grant select, insert, delete on sim_ba.Empleado to 'Monitor 1'@'localhost';
    grant select, insert, update, delete on sim_ba.Actividad to 'Monitor 1'@'localhost';
    grant select, update on sim_ba.Sala to 'Monitor 1'@'localhost';
    grant select, insert, update on turno_mon to 'Monitor 1'@'localhost';
    
-- CREACIÓN DEL USUARIO ADMINISTRADOR
    CREATE USER 'Administrador'@'localhost' IDENTIFIED BY 'admin_secure_pass_2025';
    -- Permisos sobre todas las tablas principales
    GRANT SELECT, INSERT, UPDATE, DELETE ON sim_ba.Sala TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE, DELETE ON sim_ba.Computador TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE, DELETE ON sim_ba.Sesion TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE, DELETE ON sim_ba.Actividad TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE, DELETE ON sim_ba.Turno_Mon TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE, DELETE ON sim_ba.Turno_Adm TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE ON sim_ba.Empleado TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE ON sim_ba.Estudiante TO 'Administrador'@'localhost';
    GRANT SELECT, INSERT, UPDATE ON sim_ba.Monitor TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.Administrador TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.Facultad TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.Programa TO 'Administrador'@'localhost';
    -- Permisos sobre vistas
    GRANT SELECT ON sim_ba.vw_Dashboard_Estadisticas TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.vw_Supervisiones_Admin TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.vw_Supervision_Monitor_Admin TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.vw_Turnos_Monitores TO 'Administrador'@'localhost';
    GRANT SELECT ON sim_ba.vw_Desempeno_Monitores TO 'Administrador'@'localhost';
    GRANT SELECT ON vw_Verificar_Conflictos_Reservas TO 'Administrador'@'localhost';
    -- Permisos sobre vistas (mismos de Monitor)
    grant select on sim_ba.vw_Sesiones_En_Curso to 'Administrador'@'localhost';
    grant select on sim_ba.vw_Historial_Sesiones to 'Administrador'@'localhost';
    grant select on sim_ba.vw_Sesiones_Con_Incidentes to 'Administrador'@'localhost';
    grant select on sim_ba.vw_Ocupacion_Diaria to 'Administrador'@'localhost';
    grant select on sim_ba.vw_Estadisticas_Computadores to 'Administrador'@'localhost';
    grant select on sim_ba.vw_Actividades_Detalladas to 'Administrador'@'localhost';
    grant select on sim_ba.vw_Ocupacion_Salas to 'Administrador'@'localhost';

    -- Permisos para crear tablas temporales
    GRANT CREATE TEMPORARY TABLES ON sim_ba.* TO 'Administrador'@'localhost';
    
flush privileges;