use sim_ba;

select * from estudiante;
call sp_añadirEstudiante(1231237897,"Ricardo","Villamizar","rivill@unal.edu.co", "2933");
select * from estudiante;

select * from sesion;
select * from vw_com_disp;
select * from vw_com_sala;
call sp_nuevaSesion(1231237897,'A', 1235);
select * from vw_com_disp;
select * from vw_com_sala;
select * from sesion;

call sp_cerrarSesion(1231237897);
select * from sesion;
select * from vw_com_disp;