from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import mysql.connector
from mysql.connector import Error

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Conexion BD
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "simba_squema"
}

def get_db_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        print("❌ Error en la base de datos:", e)
        return None


# -----------------------------
#        ENDPOINTS SP
# -----------------------------

@app.get("/api/sesiones")
def obtener_sesiones():
    """Llama al SP que devuelve sesiones o turnos activos"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.callproc("sp_verTurnosMonitores", [
            None, None, None, None, None, None, None, None, None
        ])

        for result in cursor.stored_results():
            data = result.fetchall()

        cursor.close()
        connection.close()
        return data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/supervisiones")
def obtener_supervisiones():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.callproc("sp_verSupervisiones", [
            None, None, None, None, None, None, None
        ])

        for result in cursor.stored_results():
            data = result.fetchall()

        cursor.close()
        connection.close()
        return data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/supervisados")
def obtener_supervisados():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.callproc("sp_verSupervisados", [
            None, None, None, None, None
        ])

        for result in cursor.stored_results():
            data = result.fetchall()

        cursor.close()
        connection.close()
        return data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/turnos-admins")
def obtener_admin_turnos():
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.callproc("sp_verTurnosAdmins", [
            None, None, None, None, None
        ])

        for result in cursor.stored_results():
            data = result.fetchall()

        cursor.close()
        connection.close()
        return data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------------
#   LOGIN / LOGOUT ADMIN
# -----------------------------

@app.post("/api/admin/login")
def admin_login(tiun: int):
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.callproc("sp_adminLogin", [tiun])

        for result in cursor.stored_results():
            data = result.fetchall()

        cursor.close()
        connection.close()
        return {"status": "ok", "data": data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/admin/logout")
def admin_logout(tiun: int):
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.callproc("sp_adminLogout", [tiun])

        for result in cursor.stored_results():
            data = result.fetchall()

        cursor.close()
        connection.close()
        return {"status": "ok", "data": data}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
