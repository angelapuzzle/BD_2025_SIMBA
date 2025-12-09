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

drop procedure if exists sp_nuevaSesión;
DELIMITER &&
CREATE PROCEDURE sp_nuevaSesion (tiun bigint, fecha date, hora time, sala char(1), compu int)
BEGIN
    declare existe_est boolean;
	declare mon int;
    DECLARE msg varchar(255);
    set existe_est = (select exists (select 1 from estudiante where Est_Tiun));
    select mon_numero into mon from Turno_Mon where Tur_fecha=fecha;
    IF (existe_est=1) THEN
		insert into sesion (ses_fecha, ses_horaInicio, com_id, sal_id, mon_numero, est_tiun) values (fecha, hora, compu, sala, mon, tiun);
	ELSE
		SET msg = concat('El estudiante con tiun ', tiun,' no se encuentra en la base de datos');
        SIGNAL sqlstate '45000' SET message_text = msg;
	END IF;
END &&
DELIMITER ;

drop procedure if exists sp_cerrarSesión;
DELIMITER &&
CREATE PROCEDURE sp_cerrarSesion (tiun bigint, fecha date, hora time, sala char(1), compu int)
BEGIN
	update Sesion SET ses_Hora_fin=hora where est_tiun=tiun and ses_fecha=fecha and Com_Id=compu and Sal_Id=sala;
END &&
DELIMITER ;
