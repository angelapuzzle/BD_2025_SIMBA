use sim_ba;

drop trigger if exists tr_nuevaSesion
DELIMITER &&
create trigger tr_nuevaSesion after INSERT on Sesion for each row
BEGIN
	update Computador set Comp_Disponibilidad=0 where Com_Id=new.Com_Id and Sal_Id=new.Sal.Id;
END &&
DELIMITER ;

drop trigger if exists tr_cierreSesion
DELIMITER &&
create trigger tr_cierreSesion after UPDATE on Sesion for each row
BEGIN
	if (not(new.ses_horaFin=null)) 
    THEN
		update Computador set Comp_Disponibilidad=1 where Com_Id=old.Com_Id and Sal_Id=old.Sal.Id;
    END IF;
END &&
DELIMITER ;

drop procedure if exists sp_nuevaSesion;
DELIMITER &&
CREATE PROCEDURE sp_nuevaSesion (tiun bigint, sala char(1), compu int)
BEGIN
    declare existe_est boolean;
	declare mon int;
    DECLARE msg varchar(255);
    set existe_est = (select exists (select 1 from estudiante where Est_Tiun));
    select mon_numero into mon from Turno_Mon where Tur_fecha=current_date() and Sal_Id=sala and Tur_HoraFinal=null;
    insert into sesion (ses_fecha, ses_horaInicio, com_id, sal_id, mon_numero, est_tiun) values (current_date(), current_time(), compu, sala, mon, tiun);
END &&
DELIMITER ;

drop procedure if exists sp_cerrarSesion;
DELIMITER &&
CREATE PROCEDURE sp_cerrarSesion (tiun bigint)
BEGIN
	update Sesion SET ses_Hora_fin=current_time() where est_tiun=tiun and ses_fecha=current_date();
END &&
DELIMITER ;

drop procedure if exists sp_anadirEstudiante;
DELIMITER &&
CREATE PROCEDURE sp_añadirEstudiante (tiun bigint, nombre varchar(45), apellido varchar(45), correo varchar(45), programa char(4))
BEGIN
	INSERT INTO estudiante VALUES (tiun, nombre, apellido, correo, programa);
END &&
DELIMITER ;
