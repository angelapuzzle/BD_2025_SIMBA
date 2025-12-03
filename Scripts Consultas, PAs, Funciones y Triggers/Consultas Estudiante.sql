use sim_ba;

-- Valores de Prueba:
-- Crear un nuevo estudiante
set @Tiun = '1234567880';
set @Nombre = 'Eduardo';
set @Apellido = 'Leal';
set @Correo = 'elea@unal.edu.edu.co';
set @Programa = '2A74';

-- Crea y cierra la sesión
set @dia = '2023-10-31';
set @hora_inicial = cast('13:15:36' as time);
set @hora_final = cast('15:45:41' as time);
set @computador = '2242';
set @sala = 'B';
set @monitor = '1';
set @tiun_estudiante = @Tiun;

-- Consulta:
-- Crear un nuevo estudiante
insert into estudiante values (@Tiun, @Nombre, @Apellido, @Correo, @Programa);

-- Consultar que computadores estan disponibles de las salas habilidadas
select * from vw_com_disp;

-- Crear una nueva sesión
insert into sesion(Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id, Mon_Numero, Est_Tiun) values (@dia, @hora_inicial, @computador, @sala, @monitor, @tiun_estudiante);
update vw_com_disp set Comp_Disponibilidad=0 where Com_Id=@computador and Sal_Id=@sala;
select * from vw_com_disp;

-- Cierra la sesión
update sesion set Ses_HoraFin=@hora_final where Est_Tiun=@tiun_estudiante and Ses_HoraFin is null;
update vw_com_sala set Comp_Disponibilidad=1 where Com_Id=@computador and Sal_Id=@sala;
select * from vw_com_disp;