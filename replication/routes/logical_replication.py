from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import text
from .shared_routes import shared_router,get_runtime_engine
import os
import subprocess
from fastapi import HTTPException

logical_router = APIRouter(prefix="/logical", tags=["Logical Replication"])
logical_router.include_router(shared_router)


# Create publication on the main server
class PublicationRequest(BaseModel):
    publication_name: str
    tables: list[str]  # List of tables to include in the publication

@logical_router.post("/create_publication")
async def create_publication(request: PublicationRequest, engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Creates a publication on the main server that includes the specified tables. This publication will be used by the replica to subscribe and receive changes.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        with raw_conn.cursor() as cursor:
            tables_str = ", ".join(request.tables)
            cursor.execute(text(f"CREATE PUBLICATION {request.publication_name} FOR TABLE {tables_str}"))
    finally:
            raw_conn.close()
    return {"message": f"Publication '{request.publication_name}' created successfully with tables: {tables_str}"}

@logical_router.get("/list_publications")
async def list_publications(engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Lists all publications on the main server.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        with raw_conn.cursor() as cursor:
            cursor.execute(text("SELECT pubname FROM pg_publication"))
            publications = cursor.fetchall()
    finally:
        raw_conn.close()
    return {"publications": [pub[0] for pub in publications]}

class SubscriptionRequest(BaseModel):
    subscription_name: str
    publication_name: str
    connection_info: str  # e.g., "host=main_host port=5432 user=replication_user password=replication_password dbname=replication_database"

@logical_router.post("/create_subscription")
async def create_subscription(sub_request: SubscriptionRequest, engine = Depends(get_runtime_engine)):
    """
    [Replica Server]
    Creates a subscription on the replica server that connects to the main server and subscribes to the specified publication.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        with raw_conn.cursor() as cursor:
            cursor.execute(text(f"CREATE SUBSCRIPTION {sub_request.subscription_name} CONNECTION '{sub_request.connection_info}' PUBLICATION {sub_request.publication_name}"))
    finally:
        raw_conn.close()
    return {"message": f"Subscription '{sub_request.subscription_name}' created successfully, subscribing to publication '{sub_request.publication_name}'"}

@logical_router.get("/list_subscriptions")
async def list_subscriptions(engine = Depends(get_runtime_engine)):
    """
    [Replica Server]
    Lists all subscriptions on the replica server.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        with raw_conn.cursor() as cursor:
            cursor.execute(text("SELECT subname FROM pg_subscription"))
            subscriptions = cursor.fetchall()
    finally:
        raw_conn.close()
    return {"subscriptions": [sub[0] for sub in subscriptions]}

@logical_router.post("/drop_subscription/{subscription_name}")
async def drop_subscription(subscription_name: str, engine = Depends(get_runtime_engine)):
    """
    [Replica Server]
    Drops a subscription from the replica server.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        with raw_conn.cursor() as cursor:
            cursor.execute(text(f"DROP SUBSCRIPTION IF EXISTS {subscription_name}"))
    finally:
        raw_conn.close()
    return {"message": f"Subscription '{subscription_name}' dropped successfully"}

@logical_router.get("/drop_publication/{publication_name}")
async def drop_publication(publication_name: str, engine = Depends(get_runtime_engine)):
    """
    [Main Server]
    Drops a publication from the main server.
    """
    raw_conn = engine.raw_connection()
    try:
        raw_conn.set_isolation_level(0)  # AUTOCOMMIT
        with raw_conn.cursor() as cursor:
            cursor.execute(text(f"DROP PUBLICATION IF EXISTS {publication_name}"))
    finally:
        raw_conn.close()
    return {"message": f"Publication '{publication_name}' dropped successfully"}