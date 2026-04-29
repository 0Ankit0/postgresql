from pydantic import BaseModel

class DocumentCreate(BaseModel):
    title: str
    content: str

class DocumentResponse(BaseModel):
    id: int
    title: str
    content: str

    class Config:
        from_attributes = True # This allows Pydantic to work with SQLAlchemy models directly