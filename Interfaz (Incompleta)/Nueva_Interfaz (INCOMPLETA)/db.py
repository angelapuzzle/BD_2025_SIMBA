import mysql.connector

def get_connection(user_profile=None):
    host = "localhost"
    database = "sim_ba"

    # 1. Mapeo de Credenciales por Perfil
    if user_profile == 'admin':
        user = "Administrador"
        password = "admin_secure_pass_2025"
    elif user_profile == 'monitor':
        user = "Monitor1"
        password = "securepass1"
    else: # Default: 'estudiante' o None (para el flujo inicial)
        user = "Estudiante"
        password = "estudiante"
    # 2. Conexión
    try:
        return mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
    except mysql.connector.Error as err:
        print(f"Error de conexión a la base de datos como '{user}': {err}")
        return None