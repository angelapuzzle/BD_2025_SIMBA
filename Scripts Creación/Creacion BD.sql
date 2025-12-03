drop schema if exists SIM_BA;
create schema SIM_BA;
use SIM_BA;

drop table if exists Supervision;
drop table if exists Administrador;
drop table if exists Actividad;
drop table if exists Empleado;
drop table if exists Turno_Mon;
drop table if exists Sesion;
drop table if exists Sala;
drop table if exists Computador;
drop table if exists Monitor;
drop table if exists Estudiante;
drop table if exists Programa;
drop table if exists Facultad;


create table Sala
(
	Sal_Id				char(1) primary key not null,
    Sal_Disponibilidad	bit default 1
);
insert into Sala values('A',1);
insert into Sala values('C',1);
insert into Sala values('B',1);
insert into Sala values('D',0);


create table Computador
(
	Com_Id				int not null,
    Comp_Disponibilidad	bit default 1,
    Sal_Id				char(1) not null,
    Primary Key         (Com_Id,Sal_id),
    foreign key         (Sal_ID) references Sala(Sal_Id)
);
insert into Computador values(1234,1,'A');
insert into Computador values(1235,1,'A');
insert into Computador values(1236,1,'A');
insert into Computador values(1237,0,'A');
insert into Computador values(1238,null,'A');

insert into Computador values(2239,1,'B');
insert into Computador values(2240,1,'B');
insert into Computador values(2241,1,'B');
insert into Computador values(2242,1,'B');
insert into Computador values(2243,1,'B');
insert into Computador values(2244,1,'B');

insert into Computador values(3245,1,'C');
insert into Computador values(3246,1,'C');
insert into Computador values(3247,1,'C');
insert into Computador values(3248,1,'C');
insert into Computador values(3249,1,'C');
insert into Computador values(3250,1,'C');
insert into Computador values(3251,0,'C');
insert into Computador values(3252,null,'C');
insert into Computador values(3253,null,'C');
insert into Computador values(3254,1,'C');
insert into Computador values(3255,null,'C');
insert into Computador values(3256,0,'C');

insert into Computador values(4257,1,'D');
insert into Computador values(4258,1,'D');
insert into Computador values(4259,1,'D');
insert into Computador values(4260,1,'D');
insert into Computador values(4261,1,'D');


create table Facultad
(
	Fac_Codigo	int not null primary key,
    Fac_Nombre	varchar(70)	not null
);
-- insert into Facultad values (2048,"Facultad de Agronomia");
insert into Facultad values(2049,"Facultad de Artes");
insert into Facultad values(2050,"Facultad de Ciencias");
insert into Facultad values(2728,"Facultad de Ciencias Agrarias");
insert into Facultad values(2051,"Facultad de Ciencias Economicas");
insert into Facultad values(2052,"Facultad de Ciencias Humanas");
insert into Facultad values(2053,"Facultad de Derecho, Ciencias Politicas y Sociales");
insert into Facultad values(2054,"Facultad de Enfermeria");
insert into Facultad values(2055,"Facultad de Ingenieria");
insert into Facultad values(2056,"Facultad de Medicina");
insert into Facultad values(2057,"Facultad de Medicina Veterinaria y Zootecnia");
insert into Facultad values(2058,"Facultad de Odontologia");


create table Programa
-- Observación, en el buscador del cursos del SIA ingeniería Agronómica es parte de la facultad de Ciencias Agrarias y Agronomía
(
	Pro_Codigo	char(4) not null primary key,
    Pro_Nombre	varchar(45) not null,
    Fac_Codigo	int not null,
    foreign key (Fac_Codigo) references Facultad(Fac_Codigo)
);
-- insert into Programa values("2505", "Ingenieria Agronomica",2048);
insert into Programa values("2508", "Cine y Television",2049);
insert into Programa values("2933", "Ciencias De La Computacion",2050);
insert into Programa values("2505", "Ingenieria Agronomica",2728);
insert into Programa values("2534", "Estudios Literarios",2052);
insert into Programa values("2539", "Derecho",2053);
insert into Programa values("2A74", "Ingenieria De Sistemas",2055);
insert into Programa values("2552", "Facultad de Medicina",2056);
insert into Programa values("2555", "Medicina Veterinaria",2057);
insert into Programa values("2557", "Odontologia",2058);


create table Empleado
(
	Emp_Tiun		bigint not null Primary key,
    Emp_Nombre		varchar(45) not null,
    Emp_Apellido	varchar(45) not null,
    Emp_Correo		varchar(45) not null,
    Doc_Planta		bit null,
    Fun_Cargo		varchar(45) null,
    Fac_Codigo		int not null,
    foreign key	    (Fac_Codigo) references Facultad(Fac_Codigo)
);
insert into Empleado values(3123456790,"Isabella","Arbelaez","iarb@unal.edu.co",0,null,2050);
insert into Empleado values(3123456791,"Margaret","Gutierrez","mgut@unal.edu.co",1,null,2050);
insert into Empleado values(3123456792,"Hernan","Guatavita","hgua@unal.edu.co",1,null,2055);
insert into Empleado values(3123456793,"Barbara","Roberts","brob@unal.edu.co",1,null,2056);
insert into Empleado values(3123456794,"Angela","Siabato","asia@unal.edu.co",1,null,2051);
insert into Empleado values(3123456795,"Jhon","Mendoza","jmen@unal.edu.co",null,"Jefe ejecutivo de produccion agroindustrial",2728);
insert into Empleado values(3123456796,"Johana","Granados","jgra@unal.edu.co",null,"Supervisora de materiales",2058);


create table Estudiante
(
	Est_Tiun		bigint	Primary key,
    Est_Nombre		varchar(45) not null,
    Est_Apellido	varchar(45) not null,
    Est_Correo		varchar(45) not null,
    Pro_Codigo      char(4) not null,
    foreign key     (Pro_Codigo) references Programa(Pro_Codigo)
);
insert into Estudiante values(1234567891,"Mauricio","Medina","mmed@unal.edu.co","2A74");
insert into Estudiante values(1234567892,"Pablo","Mendoza","pmen@unal.edu.co","2505");
insert into Estudiante values(1234567893,"Ernesto","Avila","eavi@unal.edu.co","2933");
insert into Estudiante values(1234567894,"Patricia","Fernandez","pfer@unal.edu.co","2534");
insert into Estudiante values(1234567895,"Beatriz","Pinzon","bpin@unal.edu.co","2539");
insert into Estudiante values(1234567896,"Jaime","Garzon","jgar@unal.edu.co","2552");
insert into Estudiante values(1234567897,"Elena","Pinzon","epin@unal.edu.co","2555");
insert into Estudiante values(1234567898,"Camila","Casas","ccas@unal.edu.co","2557");
insert into Estudiante values(1234567890,"Maria","Cuadros","mcua@unal.edu.co","2508");


create table Monitor
(
	Mon_Numero		int primary key,
    Est_Tiun		bigint not null,
    foreign key	    (Est_Tiun)  references Estudiante(Est_Tiun)
);
insert into Monitor values(1,1234567898);
insert into Monitor values(2,1234567895);
insert into Monitor values(3,1234567896);
insert into Monitor values(4,1234567890);


create table Administrador
(
	Adm_Tiun		bigint	Primary key,
    Adm_Nombre		varchar(45) not null,
    Adm_Apellido	varchar(45) not null,
    Adm_Correo		varchar(45) not null
);
insert into administrador values(2134567891,"Carlos","Cuevas","ccue@unal.edu.co");
insert into administrador values(2134567892,"Fernanda","Cuervos","fcue@unal.edu.co");
insert into administrador values(2134567893,"Carolina","Ramirez","cram@unal.edu.co");
insert into administrador values(2134567894,"Julian","Villamizar","jvil@unal.edu.co");


create table Sesion
(
    Ses_Fecha		date not null,
	Ses_HoraInicio	time not null,
    Ses_HoraFin		time default null,
    Com_Id			int not null,
    Sal_Id			char(1) not null,
    Mon_Numero		int null,
    Est_Tiun		bigint not null,
    Sal_Comentarios	longtext default null,
    foreign key     (Com_Id) references Computador(Com_Id),
    foreign key     (Sal_Id) references Sala(Sal_Id),
    foreign key     (Mon_Numero) references Monitor(Mon_Numero),
    foreign key     (Est_Tiun) references Estudiante(Est_Tiun),
    Primary key	    (Ses_Fecha, Ses_HoraInicio, Com_Id, Sal_Id)
);
insert into Sesion values('2023-10-30','13:00:00','13:35:00',1235,'A',1,1234567891,'El estudiante regó agua en la sala, no ocurrieron daños');
insert into Sesion values('2023-10-30','14:00:00','16:00:00',1235,'A',1,1234567897,null);
insert into Sesion values('2023-10-30','16:05:56','17:42:00',1237,'A',3,1234567896,'La estudiante rompió el mouse');
insert into Sesion values('2023-10-30','16:05:56','17:42:00',1234,'A',3,1234567896,null);
insert into Sesion values('2023-10-30','16:05:56','17:42:00',1238,'A',3,1234567896,null);
insert into Sesion values('2023-10-30','16:05:56','17:42:00',1236,'A',3,1234567896,null);

insert into Sesion values('2023-10-30','09:05:57','12:42:00',2239,'B',1,1234567896,null);
insert into Sesion values('2023-10-30','09:05:58','12:42:00',2240,'B',1,1234567893,null);
insert into Sesion values('2023-10-30','09:05:53','12:42:00',2241,'B',1,1234567892,null);
insert into Sesion values('2023-10-30','09:05:52','12:42:00',2242,'B',1,1234567891,null);
insert into Sesion values('2023-10-30','09:05:51','12:42:00',2243,'B',1,1234567896,null);
insert into Sesion values('2023-10-30','09:05:56','12:42:00',2244,'B',1,1234567894,null);
insert into Sesion values('2023-10-31','07:05:51','08:42:00',2241,'B',1,1234567896,null);
insert into Sesion values('2023-10-31','07:05:56','08:42:00',2242,'B',1,1234567894,null);

insert into Sesion values('2023-10-30','07:05:52','08:00:00',3245,'C',1,1234567898,null);
insert into Sesion values('2023-10-30','08:05:52','09:00:00',3245,'C',1,1234567897,null);
insert into Sesion values('2023-10-30','09:05:52','10:00:00',3245,'C',1,1234567894,null);
insert into Sesion values('2023-10-30','10:05:52','11:00:00',3245,'C',1,1234567893,null);


create table Actividad
(
    Act_Fecha		date not null,
	Act_HoraInicio	time not null,
    Act_HoraFin		time not null,
    Sal_Id			char(1) not null,
    Emp_Tiun		bigint not null,
    Act_Comentarios	longtext not null,
    foreign key     (Sal_Id) references Sala(Sal_Id),
    foreign key     (Emp_Tiun) references Empleado(Emp_Tiun),
    Primary key     (Act_Fecha, Act_HoraInicio, Sal_Id)
    
);
insert into Actividad values('2023-10-30','13:05:00','17:40:00','D',3123456795,'Simposio de técnicas agroindustriales y prácticas orgánicas');
insert into Actividad values('2023-10-30','07:30:00','09:00:00','D',3123456791,'Aplicaciones computacionales de cálculo vectorial');
insert into Actividad values('2023-10-30','09:30:00','11:30:00','D',3123456790,'Introducción a químicos explosivos');
insert into Actividad values('2023-10-31','09:30:00','15:30:00','D',3123456795,'Segundo parcial de la asignatura cultivos hidropónicos');
insert into Actividad values('2023-10-31','12:30:00','18:00:00','D',3123456794,'Principios económicos en modelos estocásticos');


create table Turno_Mon
(
	Tur_id		 	bigint unsigned auto_increment  Primary key	,
	Tur_Fecha		date not null,
    Tur_HoraInicio	time not null,
    Tur_HoraFinal	time default null,
    Sal_Id			char(1) not null,
    Mon_Numero		int not null,
    foreign key     (Sal_Id) references Sala(Sal_Id),
    foreign key     (Mon_Numero) references Monitor(Mon_Numero)

);
insert into Turno_Mon values(123,'2023-10-30','07:00:00','15:00:00','C',1);
insert into Turno_Mon values(124,'2023-10-30','15:00:00','17:00:00','D',3);
insert into Turno_Mon values(125,'2023-10-31','08:00:00','11:00:00','B',2);
insert into Turno_Mon values(126,'2023-10-31','11:00:00','14:00:00','A',4);


create table Turno_Adm
(
	Sup_Fecha		date not null,
    Sup_HoraInicio	time not null,
    Sup_HoraFinal	time default null,
    Adm_Tiun		bigint not null,
    Primary key	    (Sup_Fecha, Sup_HoraInicio, Adm_Tiun),
    foreign key     (Adm_Tiun) references Administrador(Adm_Tiun)
);
-- Turnos de Carlos y Fernanda el jueves 30
insert into Turno_Adm values('2023-10-30','07:00:00','13:00:00',2134567891);
insert into Turno_Adm values('2023-10-30','13:00:00','15:00:00',2134567892);
-- Turnos de Carolina y Julián el viernes 31
insert into Turno_Adm values('2023-10-31','08:00:00','11:00:00',2134567893);
insert into Turno_Adm values('2023-10-31','11:00:00','14:00:00',2134567894);

create table System_Vars
(
	lastActiveDate	date not null,
    lastActiveTime	time not null
);
insert into System_Vars values('2023-10-31', '11:00:00');