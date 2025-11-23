import mysql.connector
import os

DB_HOST = os.getenv("DB_HOST","localhost")
DB_USER = os.getenv("DB_USER","root")
DB_PASS = os.getenv("DB_PASS","root")
DB_NAME = os.getenv("DB_NAME","ridepool")
DB_PORT = int(os.getenv("DB_PORT",3306))

def get_connection():
    connection = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        port=DB_PORT,
        auth_plugin="mysql_native_password",
        autocommit=False
    )
    return connection