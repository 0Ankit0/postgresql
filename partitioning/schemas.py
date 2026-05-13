from pydantic import BaseModel
from enum import Enum

class PartitionType(str, Enum):
    range = "range"
    list = "list"
    hash = "hash"


class PartitionRequest(BaseModel):
    table_name: str
    partition_name: str
    partition_type: PartitionType
    condition: str

class CreateTableRequest(BaseModel):
    table_name: str
    columns: str  # e.g. "id SERIAL PRIMARY KEY, name VARCHAR(100), created_at TIMESTAMP"
    partition_type: PartitionType
    partition_column: str