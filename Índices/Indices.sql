-- Índice secundario sobre sesión agrupando por fechas
Create index indice_fechaSesiones on sesion(Ses_Fecha);

--  Indice secundario sobre actividad agrupando por fechas
create index indice_fechaActividades on actividad(Act_Fecha);

--  Indice secundario sobre Turno de monitor agrupando por fechas
create index indice_fechaTurnoMon on turno_mon(Tur_Fecha);

--  Indice secundario sobre Turno de administrador agrupando por fechas
create index indice_fechaActividades on turno_adm(Sup_Fecha);