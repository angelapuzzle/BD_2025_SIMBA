from flask import Flask, render_template, request, redirect, url_for, flash, session
from db import get_connection
import functools
from datetime import date, time, datetime # Importar para fecha y hora del sistema

app = Flask(__name__)
app.secret_key = "simba_super_secreta" # Necesario para session y flash

@app.route("/")
def home():
    return render_template("index.html")

# Ruta ADMINISTRADOR 
@app.route("/admin")
def admin_dashboard():
    return render_template("admin/dashboard.html")
# ----------- LÓGICA MONITOR --------------
# ----------- LÓGICA MONITOR --------------
def monitor_required(view):
# ... (Función monitor_required sin cambios) ...
    """Decorador para proteger rutas, usando el ID de Turno como sesión."""
    @functools.wraps(view)
    def wrapped_view(*args, **kwargs):
        # La sesión del monitor ahora guarda el ID del turno (Tur_Id)
        if "monitor_turno_id" not in session: 
            flash("Acceso denegado. Inicia sesión como Monitor.", "danger")
            return redirect(url_for("monitor_login"))
        return view(*args, **kwargs)
    return wrapped_view

# 1. LOGIN Monitor (Registra el turno usando fn_monitorLogin)
@app.route("/monitor", methods=["GET", "POST"])
def monitor_login():
    if request.method == "POST":
        mon_numero = request.form["mon_numero"]
        sala_id = request.form["sala_id"]
        db = get_connection(user_profile='monitor') 
        if db is None:
            flash("Error: No se pudo conectar a la base de datos.", "danger")
            return render_template("monitor/login.html")
        cursor = db.cursor()
        turno_id = None
        try:
            fecha_actual = date.today()
            hora_inicio = datetime.now().strftime('%H:%M:%S') 
            query = "SELECT fn_monitorLogin(%s, %s, %s, %s)"
            cursor.execute(query, (fecha_actual, hora_inicio, sala_id, mon_numero))
            turno_id = cursor.fetchone()[0]
            db.commit()
            if turno_id > 0:
                session["monitor_turno_id"] = turno_id
                session["monitor_num"] = mon_numero
                session["sala_asignada"] = sala_id 
                flash(f"Turno {turno_id} iniciado. Bienvenido, Monitor.", "success")
                return redirect(url_for("monitor_dashboard"))
            else:
                flash("No se pudo iniciar el turno (ID no válido o función falló).", "danger")
        except Exception as e:
            print(f"Error durante el registro del turno del monitor: {e}")
            flash("Error de base de datos al iniciar el turno. Verifica que el Monitor exista y no tenga otro turno.", "danger")
        finally:
            cursor.close()
            db.close()
    # Aquí puedes obtener la lista de salas disponibles para el select en el login
    return render_template("monitor/login.html")

# 2. DASHBOARD Monitor (Ver Sesiones Activas)
@app.route("/monitor/dashboard")
@monitor_required
def monitor_dashboard():
    # ... (Caso 1 y Caso 2: Obtener sala y chequear db=None, que tienen RETURN) ...
    sala_asignada = session.get('sala_asignada')
    if not sala_asignada:
        flash("No se encontró una Sala asignada. Por favor, asegúrate de haber iniciado tu turno.", "warning")
        return render_template("monitor/dashboard.html", sala_id=None)
        
    db = get_connection(user_profile='monitor')
    if db is None:
        flash("Error de conexión.", "danger")
        return render_template("monitor/dashboard.html", sala_id=sala_asignada)
    
    # ... (Inicializaciones) ...
    sesiones_activas = []
    dashboard_data = {}
    cursor = db.cursor(dictionary=True)
    
    try:
        # 2. OBTENER LISTADO DETALLADO DE SESIONES ACTIVAS (USANDO sp_verSesionesActuales)
        cursor.callproc("sp_verSesionesActuales", (None, sala_asignada, None, None, 
                                                    None, None, None)) 
        
        # ... (Consumir resultados) ...
        for result in cursor.stored_results():
            if result.description is not None:
                sesiones_activas = result.fetchall()
                break 

        # 3. OBTENER DETALLE DE COMPUTADORES PARA LOS BOTONES
        # ... (Consulta de computadores) ...
        cursor.execute("""
            SELECT Com_Id, Comp_Disponibilidad
            FROM Computador
            WHERE Sal_Id = %s ORDER BY Com_Id;
        """, (sala_asignada,))
        dashboard_data['computadores'] = cursor.fetchall()
        
        # 4. Cálculo de Métricas de Cabecera
        # ... (Consulta de cabecera) ...
        cursor.execute("""
            SELECT 
                (SELECT COUNT(*) FROM Sesion 
                WHERE Sal_Id = %s AND Ses_Fecha = CURRENT_DATE() AND Ses_HoraFin IS NULL) AS Sesiones_Activas,
                (SELECT COUNT(*) FROM Computador 
                WHERE Sal_Id = %s AND Comp_Disponibilidad = 1) AS Computadores_Disponibles,
                (SELECT COUNT(*) FROM Computador 
                WHERE Sal_Id = %s) AS Computadores_Totales;
        """, (sala_asignada, sala_asignada, sala_asignada))
        
        dashboard_data['cabecera'] = cursor.fetchone()
        return render_template("monitor/dashboard.html", 
                                sala_id=sala_asignada, 
                                dashboard=dashboard_data,
                                sesiones_activas=sesiones_activas)


    except Exception as e:
        flash(f"Error al cargar el dashboard: {e}", "danger")
        print(f"Error en dashboard del monitor: {e}")
        # Caso C: Error en DB, pero con return.
        return render_template("monitor/dashboard.html", sala_id=sala_asignada, dashboard=None)
        
    finally:
        db.close()

# 4. LOGOUT Monitor (usa sp_monitorLogout)
@app.route("/monitor/logout")
@monitor_required 
def monitor_logout():
    turno_id = session.get("monitor_turno_id")
    db = get_connection(user_profile='monitor') 
    if db is None:
        flash("Error de DB al cerrar turno.", "danger")
        return redirect(url_for("monitor_login"))
    cursor = db.cursor()
    try:
        # Llama a sp_monitorLogout(idTurno, horaFinal)
        hora_fin = datetime.now().strftime('%H:%M:%S')
        cursor.callproc("sp_monitorLogout", [turno_id, hora_fin])
        db.commit() 
        flash("Turno cerrado correctamente.", "info")
    except Exception as e:
        print(f"Error al cerrar turno {turno_id}: {e}")
        flash("Error al cerrar el turno en la DB.", "danger")
    finally:
        cursor.close()
        db.close()
        
    session.pop("monitor_turno_id", None)
    session.pop("monitor_num", None)
    session.pop("sala_asignada", None) 
    return redirect(url_for("monitor_login"))
# ----------- LÓGICA ESTUDIANTE -----------

# 1. LOGIN (Punto de entrada y retorno)
@app.route("/estudiante", methods=["GET", "POST"])
def estudiante_login():
    if request.method == "POST":
        tiun = request.form["tiun"]
        db = get_connection(user_profile='estudiante') 
        if db is None:
            flash("Error: No se pudo conectar a la base de datos.", "danger")
            return render_template("estudiante/login.html", salas=[])
        cursor = db.cursor(dictionary=True) 
        cierre_exitoso = False
        # ... (Lógica de sp_cerrarSesion - MANTENER) ...
        try:
            cursor.callproc("sp_cerrarSesion", [tiun])
            mensaje = "Error al obtener mensaje."
            for result in cursor.stored_results():
                resultado = result.fetchone()
                mensaje = resultado['resultado'] if resultado else "Error al obtener mensaje."
            db.commit()
            if "cerrada correctamente" in mensaje:
                cierre_exitoso = True
                flash(f"{mensaje} ¡Hasta pronto!", "info")
        except Exception as e:
            # Si hay error en el cierre, aún podemos continuar con el intento de login
            print(f"Error al intentar ejecutar sp_cerrarSesion: {e}")
            flash("Error de la DB al intentar cerrar sesión. Intenta de nuevo.", "danger")
        finally:
            db.close()
        # Si el cierre fue exitoso, no hacemos nada más que refrescar la vista.
        # Si NO hubo cierre (quiere entrar), asumimos que quiere abrir sesión.
        session["tiun"] = tiun
        
        # Si se usa POST, redirigimos al mismo lugar para forzar el método GET y la recarga de salas
        return redirect(url_for("estudiante_login"))
    # ----------------------------------------------------------------------
    # Lógica GET (Muestra el formulario y la disponibilidad)
    # ----------------------------------------------------------------------
    listado_salas = obtener_salas() # Se ejecuta CADA VEZ que se carga la página
    # Si hay un TIUN en sesión, lo pasamos al template
    tiun_sesion = session.get("tiun")
    return render_template("estudiante/login.html", salas=listado_salas, tiun_sesion=tiun_sesion)

# 2. REGISTRO
@app.route("/estudiante/registro", methods=["GET", "POST"])
def estudiante_registro():
    tiun_url = request.args.get("tiun")
    if request.method == "POST":
        tiun_form = request.form["tiun"]
        nombre = request.form["nombre"]
        apellido = request.form["apellido"]
        correo = request.form["correo"]
        programa = request.form["programa"]
        # Usamos la conexión del Estudiante (tiene permiso EXECUTE en sp_anadirEstudiante)
        db = get_connection(user_profile='estudiante')
        if db is None:
            flash("Error: No se pudo conectar a la base de datos.", "danger")
            return render_template("estudiante/registro.html", tiun=tiun_url)
        cursor = db.cursor()
        try:
            cursor.execute("CALL sp_anadirEstudiante(%s, %s, %s, %s, %s)",
                        (tiun_form, nombre, apellido, correo, programa))
            db.commit()
            flash("Registro exitoso. Por favor ingresa nuevamente para iniciar sesión.", "success")
        except Exception as e:
            print(f"Error al registrar estudiante: {e}")
            flash("Error al completar el registro. Verifica los datos.", "danger")
        finally:
            db.close()
        return redirect(url_for("estudiante_login"))
    return render_template("estudiante/registro.html", tiun=tiun_url)

# 3. CREAR SESIÓN (Acción final)
@app.route("/estudiante/crear_sesion/<sala>/<int:compu>")
def estudiante_crear_sesion(sala, compu):
    if "tiun" not in session:
        return redirect(url_for("estudiante_login"))
    tiun = session["tiun"]
    db = get_connection(user_profile='estudiante')
    if db is None:
        flash("Error: No se pudo conectar a la base de datos.", "danger")
        session.pop("tiun", None)
        return redirect(url_for("estudiante_login"))
    cursor = db.cursor(dictionary=True)
    try:
        # Llamamos al SP de nueva sesión
        cursor.callproc("sp_nuevaSesion", [tiun, sala, compu])
        # Leer el mensaje de éxito del SELECT
        mensaje = "Sesión creada."
        for result in cursor.stored_results():
            resultado = result.fetchone()
            mensaje = resultado['resultado'] if resultado and 'resultado' in resultado else "Sesión creada."
        db.commit()
        flash(f"{mensaje}", "success")
    except Exception as e:
        error_msg = str(e)
        if "El estudiante con tiun" in error_msg:
            #Estudiante no existe, Redirigimos al registro.
            session.pop("tiun", None) 
            flash(f"Estudiante con TIUN {tiun} no está registrado. Por favor, completa tu registro.", "warning")
            db.close()
            return redirect(url_for("estudiante_registro", tiun=tiun)) 
        elif "45000" in error_msg:
            # Otros errores SIGNAL (ej: No hay monitor de turno)
            flash(f"Error al iniciar sesión: {error_msg.split(': ')[-1]}", "danger")
        else:
            print(f"Error creando sesión inesperado: {error_msg}")
            flash("Error al crear sesión. Revisa la consola o contacta un monitor.", "danger")
    # LIMPIEZA y Flujo Cíclico
    session.pop("tiun", None)
    db.close()
    return redirect(url_for("estudiante_login"))

# --- Funciones Auxiliares ---
def obtener_salas():
    db = get_connection(user_profile='estudiante')
    if db is None: return []
    cursor = db.cursor(dictionary=True)
    filas = []
    try:
        # Consulta la vista que SOLO tiene disponibles (Comp_Disponibilidad=1 y Sal_Disponibilidad=1)
        cursor.execute("""
            SELECT Sal_Id, Sal_Disponibilidad, Com_Id, Comp_Disponibilidad
            FROM sim_ba.vw_com_disp 
            ORDER BY Sal_Id, Com_Id
        """)
        filas = cursor.fetchall()
    except Exception as e:
        print(f"Error al hacer SELECT en vw_com_disp (Permiso 1142): {e}")
        filas = []
    finally:
        db.close()
    # ... (El resto de la lógica de Python que agrupa los datos se mantiene) ...
    salas_dict = {}
    for row in filas:
        sal_id = row['Sal_Id']
        sal_disp = row['Sal_Disponibilidad'] # Siempre será 1 en esta vista
        com_id = row.get('Com_Id') 
        com_disp = row.get('Comp_Disponibilidad') # Siempre será 1 en esta vista
        if sal_id not in salas_dict:
            salas_dict[sal_id] = {
                "id": sal_id,
                "disponible": sal_disp,
                "computadores": []
            }
        if com_id is not None:
            salas_dict[sal_id]["computadores"].append({
                "id": com_id,
                "disponible": com_disp # Siempre 1
            })
            
    return list(salas_dict.values())

if __name__ == "__main__":
    app.run(debug=True)