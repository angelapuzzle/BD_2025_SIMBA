-- CREACIÓN DEL USUARIO ESTUDIANTE
    create user	'Estudiante'@'localhost' identified by 'estudiante';

    grant execute on procedure sp_nuevaSesion to 'Estudiante'@'localhost';
    grant execute on procedure sp_cerrarSesion to 'Estudiante'@'localhost';
    grant select, update on sim_ba.vw_com_disp to 'Estudiante'@'localhost';
    

-- CREACIÓN DEL USUARIO MONITOR
    create user 'Monitor 1'@'localhost' identified by 'securepass1';

    grant execute on procedure sp_verSesionesActuales to 'Monitor1'@'localhost';
    grant execute on procedure sp_verSesionesHistorial to 'Monitor1'@'localhost';
    grant select on sim_ba.vw_Ocupacion_Diaria to 'Monitor 1'@'localhost';
    grant execute on procedure sp_monVerEstadisticasComp to 'Monitor1'@'localhost';
    grant execute on procedure sp_monVerHistorialPc to 'Monitor1'@'localhost';
    grant execute on procedure sp_compHabilitarInhabilitar to 'Monitor1'@'localhost';
    grant execute on procedure sp_agregarComentarioSesion to 'Monitor1'@'localhost';

    grant execute on procedure sp_buscarEmpleado to 'Monitor1'@'localhost';
    grant execute on procedure sp_monNuevoEmpleado to 'Monitor1'@'localhost';
    grant execute on procedure sp_monEditarEmpleado to 'Monitor1'@'localhost';
    grant execute on procedure sp_verReservas to 'Monitor1'@'localhost';
    grant select on sim_ba.vw_Ocupacion_Salas to 'Monitor 1'@'localhost';
    grant execute on procedure sp_agregarReserva to 'Monitor1'@'localhost';
    grant execute on procedure sp_cancelarReserva to 'Monitor1'@'localhost';
    grant execute on procedure sp_deshabilitarSala to 'Monitor1'@'localhost';
    grant execute on procedure sp_habilitarSala to 'Monitor1'@'localhost';

    grant execute on function fn_monitorLogin to 'Monitor1'@'localhost';
    grant execute on procedure sp_monitorLogout to 'Monitor1'@'localhost';

    
-- CREACIÓN DEL USUARIO ADMINISTRADOR
    CREATE USER 'Administrador'@'localhost' IDENTIFIED BY 'admin_secure_pass_2025';
    
    grant execute on procedure sp_verTurnosMonitores to 'Administrador'@'localhost';
    grant execute on procedure sp_verSupervisiones to 'Administrador'@'localhost';
    grant execute on procedure sp_verSupervisados to 'Administrador'@'localhost';

    grant execute on procedure sp_adminLogin to 'Administrador'@'localhost';
    grant execute on procedure sp_adminLogout to 'Administrador'@'localhost';
    grant execute on procedure sp_verTurnosAdmins to 'Administrador'@'localhost';

    
flush privileges;