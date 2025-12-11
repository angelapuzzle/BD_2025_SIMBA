-- ===================
-- Dashboard Estadisticas
-- ===================

SELECT * FROM vw_Dashboard_Estadisticas;



-- ===================
-- Supervisiones detalladas
-- ===================

SELECT * FROM vw_Supervisiones_Admin;

CALL sp_verSupervisiones(null, null, null, null, 'Fernand', null, null);
CALL sp_verSupervisiones(null, null, null, null, null, null, 'C');



-- ===================
-- Supervisiones detalladas
-- ===================

SELECT * FROM vw_Supervision_Monitor_Admin;

CALL sp_verSupervisados(null, null, null, null, null, 'Cami', null, null, null, null, null, null);
CALL sp_verSupervisados(null, null, null, null, null, null, null, null, 'Juli', null, null, null);



-- ===================
-- Turnos de Monitores
-- ===================

SELECT * FROM vw_Turnos_Monitores;

CALL sp_verTurnosMonitores(null, null, null, null, null, null, null, 'Gar', null);
CALL sp_verTurnosMonitores(null, null, null, 'A', null, null, null, null, null);



-- ===================
-- Turnos de Administradores
-- ===================

SELECT * FROM vw_Turnos_Administradores;

CALL sp_verTurnosAdmins('2023-10-30', null, null, null, null, null, null);
CALL sp_verTurnosAdmins(null, null, null, null, 'CARLOS', null, null);



-- ===================
-- Iniciar y Cerrar Sesion Admin
-- ===================

-- Ver turnos monitores
CALL sp_verTurnosAdmins(null, null, null, null, null, null, null);

-- Iniciar turno monitor
CALL sp_adminLogin('2025-12-10', '12:00:00', 2134567892);

-- Finalizar turno monitor
CALL sp_adminLogout('2025-12-10', '12:00:00', 2134567892, '19:00:00');