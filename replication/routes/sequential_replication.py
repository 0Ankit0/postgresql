from fastapi import APIRouter
from pydantic import BaseModel
from .shared_routes import shared_router,get_runtime_engine
import os
import subprocess
from fastapi import HTTPException

sequential_router = APIRouter(prefix="/sequential", tags=["Sequential Replication"])
sequential_router.include_router(shared_router)


class BaseBackupRequest(BaseModel):
    primary_host: str
    replication_user: str
    replication_password: str
    replication_database: str
    replica_data_dir: str  # e.g., "/var/lib/postgresql/16/main"
    port: int = 5432

@sequential_router.post("/run_basebackup")
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
