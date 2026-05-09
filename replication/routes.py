from typing import Optional

from fastapi import APIRouter, Depends, Request, Query
from sqlalchemy import text
import os
from sqlalchemy import create_engine
from urllib.parse import urlparse, urlunparse
from db_conn import engine
from enum import Enum
from pydantic import BaseModel
import subprocess
from fastapi import HTTPException

def get_runtime_engine(request: Request,db: Optional[str] = None):
    """
    Generate a SQLAlchemy engine using the base DB URL from environment variables,
    replacing only the database name with the selected one.
    """
    selected_db = db or request.session.get("db_name")
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        raise RuntimeError("DATABASE_URL environment variable not set")
    parsed = urlparse(db_url)
    # Replace the path (database name) with the selected_db
    new_path = f"/{selected_db}"
    new_url = urlunparse((
        parsed.scheme,
        parsed.netloc,
        new_path,
        parsed.params,
        parsed.query,
        parsed.fragment
    ))
    return create_engine(new_url)

router = APIRouter(
    prefix="/replication",
    tags=["Sequential Replication"]
)

@router.post("/create_db")
async def create_db(db_name: str):
    """
    [Main Server]
    Creates a new database with the given name on the main server. If the database already exists, returns a message indicating so.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        cursor = raw_conn.cursor()
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
        db_exists = cursor.fetchone()
        if db_exists:
            return {"message": f"Database {db_name} already exists"}
        cursor.execute(f"CREATE DATABASE {db_name}")
        cursor.close()
        return {"message": f"Database {db_name} created successfully"}
    finally:
        raw_conn.close()

@router.post("/get_db_list")
async def get_db_list(engine = Depends(get_runtime_engine)):
    """
    [Main or Replica Server]
    Returns a list of all databases present on the connected server (main or replica).
    """
    with engine.connect() as connection:
        result = connection.execute(text("SELECT datname FROM pg_database"))
        db_list = [row[0] for row in result]
    return {"databases": db_list}

@router.post("/get_current_db")
async def get_current_db(engine = Depends(get_runtime_engine)):
    """
    [Main or Replica Server]
    Returns the name of the current database for the connected server.
    """
    with engine.connect() as connection:
        result = connection.execute(text("SELECT current_database()"))
        db_name = result.fetchone()[0]
    return {"current_database": db_name}
    
@router.post("/set_current_db")
async def set_current_db(request: Request, db_name: str):
    """
    [Session Only]
    Sets the current database for the session (does not change the database on the server, only for the API session context).
    """
    request.session["db_name"] = db_name
    return {"message": f"Current database set to {db_name}"}

class WALLevel(str, Enum):
    minimal = "minimal"
    replica = "replica"
    logical = "logical"

@router.post("/set_wal_level")
async def set_wal_level(
    wal_level: WALLevel = Query(...),
    engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Sets the WAL (Write-Ahead Logging) level for the main server. Required for configuring replication. Reloads the server configuration after change.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        cursor = raw_conn.cursor()
        cursor.execute(f"ALTER SYSTEM SET wal_level = '{wal_level.value}'")
        cursor.execute("SELECT pg_reload_conf()")
        cursor.close()
    finally:
        raw_conn.close()
    return {"message": f"WAL level set to {wal_level.value} and configuration reloaded"}

@router.post("/set_max_wal_senders")
async def set_max_wal_senders(
    max_wal_senders: int = Query(..., ge=0),
    engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Sets the maximum number of WAL sender processes for the main server. This is required for supporting multiple replication connections. Reloads the server configuration after change.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        cursor = raw_conn.cursor()
        cursor.execute(f"ALTER SYSTEM SET max_wal_senders = {max_wal_senders}")
        cursor.execute("SELECT pg_reload_conf()")
        cursor.close()
    finally:
        raw_conn.close()
    return {"message": f"max_wal_senders set to {max_wal_senders} and configuration reloaded"}

@router.get("/get_hba_file")
async def get_hba_file(engine = Depends(get_runtime_engine)):
    """
    [Main Server Only]
    Returns the path and content of the pg_hba.conf file for the main (primary) server. This file controls client authentication and must be updated on the main server to allow replication connections from replicas.
    """
    with engine.connect() as connection:
        hba_file_path = connection.execute(text("SHOW hba_file")).fetchone()[0]
    with open(hba_file_path, 'r') as file:
        hba_content = file.read()
    return {"file": hba_file_path, "content": hba_content}

class HBAFileContent(BaseModel):
    content: str

@router.post("/replace_hba_file")
async def replace_hba_file(
    data: HBAFileContent,
    engine = Depends(get_runtime_engine)
):
    """
    [Main Server Only]
    Replaces the content of the pg_hba.conf file for the main (primary) server with the provided content, then reloads the configuration. This is required to allow replication connections from replicas.
    """
    with engine.connect() as connection:
        hba_file_path = connection.execute(text("SHOW hba_file")).fetchone()[0]
    with open(hba_file_path, 'w') as file:
        file.write(data.content)
    with engine.connect() as connection:
        connection.execute(text("SELECT pg_reload_conf()"))
    return {"message": "HBA file replaced and configuration reloaded"}

# The replica user must be created in primary server
@router.post("/add_replication_user")
async def add_replication_user(
    username: str,
    password: str,
    engine = Depends(get_runtime_engine)
):
    """
    [Main Server]
    Creates a new replication user on the main server with the provided username and password. The user will have REPLICATION privileges.
    """
    try:
        with engine.connect() as connection:
            result = connection.execute(text(f"CREATE USER {username} WITH PASSWORD '{password}' REPLICATION")).fetchone()
        return {"message": f"Replication user {username} created successfully with result {result}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create replication user: {str(e)}")
class PrimaryConnInfo(BaseModel):
    primary_host: str
    replication_user: str
    replication_password: str
    replication_database: str
    replication_server_port: int = 5432

@router.post("/set_replica_server")
async def set_replica_server(
    request: Request,
    conn_info: PrimaryConnInfo,
):
    """
    [Replica Server]
    Sets the primary server connection info on the replica server for streaming replication. Updates the replica's configuration to connect to the main server.
    """
    engine  = get_runtime_engine(db=conn_info.replication_database,request=request)
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        cursor = raw_conn.cursor()
        cursor.execute(f"ALTER SYSTEM SET primary_conninfo = 'host={conn_info.primary_host} user={conn_info.replication_user} password={conn_info.replication_password} port={conn_info.replication_server_port} '")
        cursor.execute("SELECT pg_reload_conf()")
        cursor.close()
    finally:
        raw_conn.close()
    return {"message": f"Replica server set to {conn_info.primary_host} and configuration reloaded"}

@router.get("/get_data_directory")
async def get_data_directory(engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Returns the data directory path for the connected server (where the database files are stored).
    """
    with engine.connect() as connection:
        data_directory = connection.execute(text("SHOW data_directory")).fetchone()[0]
    return {"data_directory": data_directory}

class BaseBackupRequest(BaseModel):
    primary_host: str
    replication_user: str
    replication_password: str
    replication_database: str
    replica_data_dir: str  # e.g., "/var/lib/postgresql/16/main"
    port: int = 5432

@router.post("/run_basebackup")
async def run_basebackup(request: BaseBackupRequest):
    """
    [Replica Server]
    Runs pg_basebackup on the replica server to copy the database cluster from the main server. This is used to initialize the replica's data directory.
    """
    env = os.environ.copy()
    env["PGPASSWORD"] = request.replication_password
    POSTGRES_OS_USER = os.getenv("POSTGRES_OS_USER", "postgres")
    SUDO_PASSWORD = os.getenv("SUDO_PASSWORD")

    try:
        cmd = [
            "sudo", "-u", POSTGRES_OS_USER,
            "pg_basebackup",
            "-h", request.primary_host,
            "-U", request.replication_user,
            "-D", request.replica_data_dir,
            "-Fp", "-Xs", "-P", "-R",
            "-p", str(request.port)
        ]
        if SUDO_PASSWORD:
            result = subprocess.run(cmd, env=env, input=SUDO_PASSWORD + "\n", check=True, capture_output=True, text=True)
        else:
            result = subprocess.run(cmd, env=env, check=True, capture_output=True, text=True)
        return {"message": "Base backup completed successfully", "stdout": result.stdout}
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Base backup failed: {e.stderr}")

class ReplicaConfig(BaseModel):
    replica_data_dir: str
    replica_log_file: str
    replica_port: int = 5433

# should start in a different port than primary server
@router.post("/start_replica_server")
async def start_replica_server(config: ReplicaConfig, engine = Depends(get_runtime_engine)):
    """
    [Replica Server]
    Starts the PostgreSQL server on the replica, typically on a different port than the main server. Uses the provided data directory and log file.
    """
    POSTGRES_OS_USER = os.getenv("POSTGRES_OS_USER", "postgres")
    SUDO_PASSWORD = os.getenv("SUDO_PASSWORD")
    try:
        if config.replica_data_dir is None:
            with engine.connect() as connection:
                config.replica_data_dir = connection.execute(text("SHOW data_directory")).fetchone()[0]
        cmd = [
            "sudo", "-u", POSTGRES_OS_USER,
            "pg_ctl", "start",
            "-D", config.replica_data_dir,
            "-l", config.replica_log_file,
            "-w",
            "-o", f"-p {config.replica_port}"
        ]
        if SUDO_PASSWORD:
            result = subprocess.run(cmd, input=SUDO_PASSWORD + "\n", check=True, capture_output=True, text=True)
        else:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return {"message": "Replica server started successfully", "stdout": result.stdout}
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to start replica server: {e.stderr}")

@router.post("/is_replica")
async def is_replica(engine = Depends(get_runtime_engine)):
    """
    [Main or Replica Server]
    Checks if the connected server is running as a replica (in recovery mode). Returns True if it is a replica, False if it is the main server.
    """
    with engine.connect() as connection:
        result = connection.execute(text("SELECT pg_is_in_recovery()")).fetchone()[0]
    return {"is_replica": result}

@router.post("/stop_replica_server")
async def stop_replica_server(config: ReplicaConfig, engine = Depends(get_runtime_engine)):
    """
    [Replica Server]
    Stops the PostgreSQL server running as a replica, using the provided data directory and log file.
    """
    POSTGRES_OS_USER = os.getenv("POSTGRES_OS_USER", "postgres")
    SUDO_PASSWORD = os.getenv("SUDO_PASSWORD")
    try:
        if config.replica_data_dir is None:
            with engine.connect() as connection:
                config.replica_data_dir = connection.execute(text("SHOW data_directory")).fetchone()[0]
        cmd = [
            "sudo", "-u", POSTGRES_OS_USER,
            "pg_ctl", "stop",
            "-D", config.replica_data_dir,
            "-l", config.replica_log_file
        ]
        if SUDO_PASSWORD:
            result = subprocess.run(cmd, input=SUDO_PASSWORD + "\n", check=True, capture_output=True, text=True)
        else:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return {"message": "Replica server stopped successfully", "stdout": result.stdout}
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to stop replica server: {e.stderr}")

@router.post("/drop_db")
async def drop_db(request: Request, engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Drops the current database for the connected server. Terminates all connections to the database before dropping it. After dropping, resets the session database to 'postgres'.The database to run the drop from should be different than the one being dropped, so it can be used to execute the drop command.
    """
    with engine.connect() as connection:
        db_name = connection.execute(text("SELECT current_database()")).fetchone()[0]
    admin_engine = create_engine(os.getenv("DATABASE_URL", ""))
    raw_conn = admin_engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        cursor = raw_conn.cursor()
        cursor.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = %s", (db_name,))
        cursor.execute(f"DROP DATABASE {db_name}")
        cursor.close()
    finally:
        raw_conn.close()
        request.session["db_name"] = "postgres"
    return {"message": "Current database dropped successfully"}