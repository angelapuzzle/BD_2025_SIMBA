use sim_ba;

-- Valores de Prueba:
-- Crear un nuevo estudiante
SET @Tiun = '1234567880';
SET @Nombre = 'Eduardo';
SET @Apellido = 'Leal';
SET @Correo = 'elea@unal.edu.edu.co';
SET @Programa = '2A74';

-- Crea y cierra la sesión
SET @dia = '2023-10-31';
SET @hora_inicial = cast('13:15:36' as time);
SET @hora_final = cast('15:45:41' as time);
SET @computador = '2242';
SET @sala = 'B';
SET @monitor = '1';
SET @tiun_estudiante = @Tiun;

-- Consulta:
-- Crear un nuevo estudiante
INSERT INTO estudiante VALUES (@Tiun, @Nombre, @Apellido, @Correo, @Programa);

-- Consultar que computadores estan disponibles de las salas habilidadas
SELECT * FROM vw_com_disp;

-- Crear una nueva sesión
INSERT INTO sesion(Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id, Mon_Numero, Est_Tiun) VALUES (@dia, @hora_inicial, @computador, @sala, @monitor, @tiun_estudiante);
UPDATE vw_com_disp SETComp_Disponibilidad=0 WHERE Com_Id=@computador AND Sal_Id=@sala;
select * from vw_com_disp;

-- Cierra la sesión
UPDATE sesion SET Ses_HoraFin=@hora_final WHERE Est_Tiun=@tiun_estudiante and Ses_HoraFin is null;
UPDATE vw_com_sala SET Comp_Disponibilidad=1 WHERE Com_Id=@computador and Sal_Id=@sala;
SELECT * FROM vw_com_disp;