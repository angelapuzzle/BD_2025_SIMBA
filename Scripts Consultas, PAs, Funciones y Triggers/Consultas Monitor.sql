use sim_ba;

-- // ==========================================
-- // Sistema de administración de computadores
-- // ==========================================

-- Ver sesiones en curso (Vista 1)
    -- Dato de prueba: Sesión activa en el día actual
    replace into Sesion values(current_date(),'13:00:00',null,3245,'C',1,1234567893,null);
    UPDATE Computador SET Comp_Disponibilidad=0 WHERE Com_Id='3245' and Sal_Id='C';
    
    SELECT * FROM vw_Sesiones_En_Curso;


-- Ver historial de sesiones por atributos filtrado (Vista 2)
-- Atributos (todos opcionales): dia_sesion, hora_inicial, hora_final, sala,
--  computador, tiun_estudiante, nombre_estudiante, apellido_estudiante
    -- Atributos de prueba 1: Día y franja horaria
    SET @dia_sesion = '2023-10-30';
    SET @hora_inicial = cast('11:45:00' AS TIME);
    SET @hora_final = cast('16:00:00' AS TIME);
    SET @sala = null;
    SET @computador = null;
    SET @tiun_estudiante = null;
    SET @nombre_estudiante = null;
    SET @apellido_estudiante = null;
    -- Atributos de prueba 2: Día y nombre de estudiante (incompleto)
    SET @dia_sesion = '2023-10-30';
    SET @hora_inicial = null;
    SET @hora_final = null;
    SET @sala = null;
    SET @computador = null;
    SET @tiun_estudiante = null;
    SET @nombre_estudiante = 'CAMI';
    SET @apellido_estudiante = null;
    
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
        
-- Ver sesiones con comentarios/incidentes (Vista 3)
    SELECT * FROM vw_Sesiones_Con_Incidentes;


-- Ver información de uso de cada sala por fecha (Vista 4)
    SELECT * FROM vw_Ocupacion_Diaria;
    

-- Ver estadísticas de uso por computador filtradas (Vista 5)
-- Atributos: sala, computador (opcional)
    -- Atributos de prueba
    SET @sala = 'B';
    SET @computador = null;
    
    SELECT *
    FROM vw_Estadisticas_Computadores
    WHERE
        (Sal_Id=@sala)
        and (@computador is null or Com_Id=@computador);
        
        
-- Ver historial de uso de un computador (Vista 2)
-- Atributos: computador, sala, dias_atras (opcional)
    SET @computador = 3245;
    SET @sala = 'C';
    SET @dias_atras = 7;

    SELECT 
        Ses_Fecha,
        Ses_HoraInicio,
        Ses_HoraFin,
        Est_Nombre,
        Est_Apellido,
        Monitor_Nombre,
        Monitor_Apellido,
        Duracion_Minutos,
        Sal_Comentarios
    FROM vw_Historial_Sesiones
    WHERE Com_Id = @computador 
      AND Sal_Id = @sala
      AND Ses_Fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL @dias_atras DAY)
    ORDER BY Ses_Fecha DESC, Ses_HoraInicio DESC;


-- Inhabilitar o bloquear computador y cerrar sesión (Utiliza Vista 1)
-- Atributos: inhabilitar (defecto false), sala, computador
    -- Dato de prueba: Sesión activa en el día actual
    replace into Sesion values(current_date(),'13:00:00',null,3245,'C',1,1234567893,null);
    UPDATE Computador SET Comp_Disponibilidad=0 WHERE Com_Id='3245' and Sal_Id='C';
    -- Atributos de prueba
    SET @inhabilitar = false;
    SET @sala = 'C';
    SET @computador = 3245;
    
    
    CREATE TEMPORARY TABLE tmp_sesiones
    SELECT Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id
    FROM vw_Sesiones_En_Curso
    WHERE Sal_Id=@sala and Com_Id=@computador;
    
    UPDATE Sesion
    SET Ses_HoraFin = current_time()
    WHERE (Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id) IN (
        SELECT * FROM tmp_sesiones
    );
    
    UPDATE Computador
    SET Comp_Disponibilidad = IF(@inhabilitar, null, 1)
    WHERE (Com_Id, Sal_Id) IN (
        SELECT Com_Id, Sal_Id FROM tmp_Sesiones
    );
    
    DROP TEMPORARY TABLE tmp_sesiones;
    
    -- Verificar
    SELECT * FROM vw_Sesiones_En_Curso;
    SELECT * FROM Computador WHERE Com_Id=@computador;
    
    
-- Agregar comentario a una sesión
-- Atributos: fecha, hora_inicio, computador, sala, comentario
    -- Atributos de prueba
    SET @fecha = CAST('2023-10-30' AS DATE);
    SET @hora_inicial = CAST('09:05:57' AS TIME);
    SET @computador = 2239;
    SET @sala = 'B';
    SET @comentario = 'Insertó una memoria con virus en el computador';
    
    UPDATE Sesion SET Sal_Comentarios=@comentario
    WHERE Ses_Fecha=@fecha and Ses_HoraInicio=@hora_inicial and Com_Id=@computador and Sal_Id=@sala;
    
    -- Verificar
    SELECT * FROM Sesion
    WHERE Ses_Fecha=@fecha and Ses_HoraInicio=@hora_inicial and Com_Id=@computador and Sal_Id=@sala;



-- // ==========================================
-- // Reserva de salas 
-- // ==========================================

-- Buscar empleado en el sistema
-- Atributos (todos opcionales): tiun_empleado, nombre_empleado, apellido_empleado, correo_empleado
    -- Atributos de prueba
    SET @tiun_empleado = null;
    SET @nombre_empleado = null;
    SET @apellido_empleado = 'SIA';
    SET @correo_empleado = null;
    
    SELECT *
    FROM Empleado
    WHERE
        (@tiun_empleado is null or Emp_Tiun LIKE CONCAT(@tiun_empleado, '%'))
        and (@nombre_empleado is null or Emp_Nombre LIKE CONCAT('%', @nombre_empleado, '%'))
        and (@apellido_empleado is null or Emp_Apellido LIKE CONCAT('%', @apellido_empleado, '%'))
        and (@correo_empleado is null or Emp_Correo LIKE CONCAT(@correo_empleado, '%'));


-- Inserción de nuevos empleados
-- Atributos: tiun_empleado, nombre_empleado, apellido_empleado, correo_empleado, docente_planta, funcionario_cargo, facultad_codigo
    -- Atributos de prueba
    SET @tiun_empleado = 3123456797;
    SET @nombre_empleado = 'Abigail';
    SET @apellido_empleado = 'Perez';
    SET @correo_empleado = 'aper@unal.edu.co';
    SET @docente_planta = 1;
    SET @funcionario_cargo = null;
    SET @facultad_codigo = 2053;

    insert into Empleado values(@tiun_empleado, @nombre_empleado, @apellido_empleado, @correo_empleado, @docente_planta, @funcionario_cargo, @facultad_codigo);
    
    -- Verificar
    SELECT * FROM Empleado WHERE Emp_Tiun=@tiun_empleado;
    
-- Ver reservas filtradas (Vista 6)
-- Atributos: dia_actividad, hora_inicial, hora_final, sala, tiun_empleado, nombre_empleado, apellido_empleado, correo_empleado, estado
    -- Atributos de prueba (franja horaria)
    SET @dia_actividad = '2023-10-30';
    SET @hora_inicial = CAST('08:00:00' AS TIME);
    SET @hora_final = CAST('09:00:00' AS TIME);
    SET @sala = null;
    SET @tiun_empleado = null;
    SET @nombre_empleado = null;
    SET @apellido_empleado = null;
    SET @correo_empleado = null;
    SET @estado = null;
    -- Atributos de prueba (empleado)
    SET @dia_actividad = null;
    SET @hora_inicial = null;
    SET @hora_final = null;
    SET @sala = null;
    SET @tiun_empleado = null;
    SET @nombre_empleado = null;
    SET @apellido_empleado = 'MENDO';
    SET @correo_empleado = null;
    SET @estado = null;
    
    
    SELECT Act_Comentarios, Act_Fecha, Act_HoraInicio, Act_HoraFin, Sal_Id, Emp_Nombre, Emp_Apellido, Emp_Correo, Fac_Nombre, Estado_Actividad
    FROM vw_Actividades_Detalladas
    WHERE
        (@dia_actividad is null or Act_Fecha=@dia_actividad)
        and (@hora_inicial is null or @hora_inicial<Act_HoraFin)
        and (@hora_final is null or @hora_final>Act_HoraInicio)
        and (@sala is null or Sal_Id=@sala)
        and (@tiun_empleado is null or Emp_Tiun LIKE CONCAT(@tiun_empleado, '%'))
        and (@nombre_empleado is null or Emp_Nombre LIKE CONCAT('%', @nombre_empleado, '%'))
        and (@apellido_empleado is null or Emp_Apellido LIKE CONCAT('%', @apellido_empleado, '%'))
        and (@correo_empleado is null or Emp_Correo LIKE CONCAT(@correo_empleado, '%'))
        and (@estado is null or Estado_Actividad=@estado);
    
    
-- Ver información principal de las salas (Vista 7)
    SELECT * FROM vw_Ocupacion_Salas;
    
    
-- Reservar en franja seleccionada, verificar no colisiones, devolver registros con colisión
-- Atributos: dia_actividad, hora_inicial, hora_final, sala, comentario, tiun_empleado
    -- Atributos de prueba (con colisión)
    SET @dia_actividad = '2023-10-30';
    SET @hora_inicial = cast('11:45:00' AS TIME);
    SET @hora_final = cast('14:00:00' AS TIME);
    SET @sala = 'D';
    SET @comentario = 'Curso de programación en Python';
    SET @tiun_empleado = '3123456794';
    -- Atributos de prueba (sin colisión)
    SET @dia_actividad = '2023-10-30';
    SET @hora_inicial = cast('11:45:00' AS TIME);
    SET @hora_final = cast('13:00:00' AS TIME);
    SET @sala = 'D';
    SET @comentario = 'Curso de programación en Python';
    SET @tiun_empleado = '3123456794';
    
    -- Ver colisiones
    -- Si devuelve 0 registros entonces podemos reservar la sala sin que haya colisiones,
    -- de lo contrario veremos que actividades colisionan con la franja solicitada
    SELECT *
    FROM vw_Actividades_Detalladas
    WHERE Act_Fecha=@dia_actividad and Sal_Id=@sala and @hora_inicial<Act_HoraFin and @hora_final>Act_HoraInicio;
    
    -- Registrar reserva (Requiere verificar la consulta anterior)
    INSERT INTO Actividad values(@dia_actividad, @hora_inicial, @hora_final, @sala, @tiun_empleado, @comentario);
    
    -- Verificar inserción
    SELECT * FROM Actividad WHERE Act_Fecha=@dia_actividad and Act_HoraInicio=@hora_inicial and Sal_Id=@sala;
    
    
-- Cancelar reserva
-- Atributos: dia, hora_inicial, sala
    -- Atributos de prueba
    SET @dia_actividad = '2023-10-30';
    SET @hora_inicial = cast('13:05:00' AS TIME);
    SET @sala = 'D';
    
    DELETE FROM Actividad WHERE Act_Fecha=@dia_actividad and Act_HoraInicio=@hora_inicial and Sal_Id=@sala;
    
    
-- Deshabilitar sala manualmente (y cerrar sesiones, requiere Vista 1)
-- Atributos: sala
    -- Atributos de prueba
    SET @sala = 'C';
    -- Dato de prueba: Sesión activa en el día actual
    replace into Sesion values(current_date(),'13:00:00',null,3245,'C',1,1234567893,null);
    UPDATE Computador SET Comp_Disponibilidad=0 WHERE Com_Id='3245' and Sal_Id='C';
    
    -- Marcar sala como no disponible
    UPDATE Sala SET Sal_Disponibilidad = 0 WHERE Sal_Id=@sala;
    
    -- Marcar computadores como disponibles
    UPDATE Computador SET Comp_Disponibilidad = 1
    WHERE Sal_Id=@sala AND Comp_Disponibilidad is not null;
    
    -- Cerrar sesiones activas de todos los computadores de la sala
    CREATE TEMPORARY TABLE tmp_sesiones
    SELECT Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id
    FROM vw_Sesiones_En_Curso
    WHERE Sal_Id=@sala and Com_Id IN (
        SELECT Com_Id
        FROM Computador
        WHERE Sal_Id=@sala AND Comp_Disponibilidad is not null
    );
    
    UPDATE Sesion
    SET Ses_HoraFin = current_time()
    WHERE (Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id) IN (
        SELECT * FROM tmp_sesiones
    );
    
    DROP TEMPORARY TABLE tmp_sesiones;
    
    -- Verificar
    SELECT * FROM vw_Ocupacion_Salas;
    SELECT * FROM Computador WHERE Sal_Id=@sala;
    SELECT * FROM vw_Sesiones_En_Curso;
    
    
-- Habilitar sala manualmente
-- Atributos: sala
    -- Atributos de prueba
    SET @sala = 'D';
    
    UPDATE Sala SET Sal_Disponibilidad = 1 WHERE Sal_Id=@sala;
    
    -- Verificar
    SELECT * FROM vw_Ocupacion_Salas;
    
-- // ==========================================
-- // Registro monitor (al iniciar sesión)
-- // ==========================================

-- Registrar nuevo turno en login --->  genera llave artificial
-- Atributos: id_turno, fecha_turno, hora_inicial, id_sala, numero_monitor
    -- Atributos de prueba (inicio)
    SET @fecha_turno = '2023-11-02';
    SET @hora_inicial = cast('15:23:00' AS TIME);
    SET @sala = 'C';
    SET @numero_monitor = 1;
    -- Atributos de prueba (final)
    SET @hora_final = cast('18:00:00' AS TIME) ;
    
    -- Inserción al iniciar el turno
    INSERT INTO Turno_Mon(Tur_Fecha, Tur_HoraInicio, Sal_Id, Mon_Numero) values(@fecha_turno, @hora_inicial, @sala, @numero_monitor);
    SET @id_turno = last_insert_id();
    
    -- Actualización de la hora de finalización
    -- Nota, id_turno corresponde con el id de la inserción
    UPDATE Turno_Mon SET Tur_HoraFinal=@hora_final WHERE Tur_Id=@id_turno;
    
    -- Verificar
    SELECT * FROM Turno_Mon WHERE Tur_Id = @id_turno;
    
    
