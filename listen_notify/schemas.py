from datetime import datetime
from pydantic import BaseModel

class MessageCreate(BaseModel):
    content: str
    sender: str

class MessageResponse(BaseModel):
    id: int
    content: str
    sender: str
    timestamp: datetime

    class Config:
        from_attributes = True # This allows Pydantic to work with SQLAlchemy models directly