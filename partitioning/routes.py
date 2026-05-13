from fastapi import APIRouter, Query
from sqlalchemy import text
from db_conn import engine, AsyncSessionLocal
from schemas import PartitionRequest, PartitionType, CreateTableRequest

router = APIRouter(
    prefix="/partitioning",
    tags=["partitioning"],
)

@router.get("/table_list")
async def get_table_list():
    async with AsyncSessionLocal() as connection:
        result = await connection.execute(text("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"))
        tables = [row[0] for row in result]
    return {"tables": tables}

@router.get("/table_schema/{table_name}")
async def get_table_schema(table_name: str = Query(..., description = "Name of the table to retrieve the schema for")):
    async with AsyncSessionLocal() as connection:
        result = await connection.execute(text(f"SELECT column_name, data_type from information_schema.columns WHERE table_name = '{table_name}';"))
        schema = [{"column_name": row[0], "data_type": row[1]} for row in result]
    return {"schema": schema}

# adding partition will only work for empty tables.
@router.post("/create_table")
async def create_partitioned_table(request: CreateTableRequest):
    match request.partition_type:
        case PartitionType.range:
            partition_sql = f"CREATE TABLE {request.table_name} (id SERIAL PRIMARY KEY, {request.columns}) PARTITION BY RANGE ({request.partition_column});"
        case PartitionType.list:
            partition_sql = f"CREATE TABLE {request.table_name} (id SERIAL PRIMARY KEY, {request.columns}) PARTITION BY LIST ({request.partition_column});"
        case PartitionType.hash:
            partition_sql = f"CREATE TABLE {request.table_name} (id SERIAL PRIMARY KEY, {request.columns}) PARTITION BY HASH ({request.partition_column});"
        case _:
            return {"error": "Invalid partition type"} 

    async with AsyncSessionLocal() as connection:
        await connection.execute(text(partition_sql))
    
    return {"message": f"Partitioned table '{request.table_name}' created successfully with {request.partition_type} partitioning on column '{request.partition_column}'."}

@router.post("/add_partition")
async def add_partition(request: PartitionRequest):        
    partition_sql = f"CREATE TABLE {request.partition_name} PARTITION OF {request.table_name} {request.condition}"
    async with AsyncSessionLocal() as connection:
        await connection.execute(text(partition_sql))
    return {"message": f"Partition '{request.partition_name}' added successfully to table '{request.table_name}' with condition '{request.condition}'."}

@router.get("/partitions/{table_name}")
async def get_partitions(table_name: str = Query(..., description = "Name of the partitioned table to retrieve its partitions")):
    async with AsyncSessionLocal() as connection:
        result = await connection.execute(text(f"SELECT inhrelid::regclass AS partition_name FROM pg_inherits WHERE inhparent = '{table_name}'::regclass;"))
        partitions = [row[0] for row in result]
    return {"partitions": partitions}

@router.get("/detatch_partition")
async def detatch_partition(table_name: str = Query(..., description = "Name of the partitioned table to detatch its partitions"), partition_name: str = Query(..., description = "Name of the partition to detatch")):
    async with AsyncSessionLocal() as connection:
        await connection.execute(text(f"ALTER TABLE {table_name} DETACH PARTITION {partition_name};"))
    return {"message": f"Partition '{partition_name}' detatched successfully from table '{table_name}'."}