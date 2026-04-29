from typing import Optional
import tempfile
from fastapi import APIRouter, File, Query, UploadFile
from sqlalchemy import func, select
from sqlalchemy.orm import Session
from model import Document
from schemas import DocumentCreate, DocumentResponse
from db_conn import engine

router = APIRouter(tags=["Document"],prefix="/document")

@router.get("/list/")
def get_documents(
    limit: int = Query(default=10, description="Maximum number of results to return"),
    offset: int = Query(default=0, description="Number of results to skip")) -> Optional[list[DocumentResponse]]:
    try:
        with Session(engine) as session:
            stmt = select(Document).offset(offset).limit(limit)
            results = session.execute(stmt).scalars().all()
            return [DocumentResponse.model_validate(doc) for doc in results]
    except Exception as e:
        print(f"Error fetching documents: {e}")
        return None

@router.post("/")
def create_document(document: DocumentCreate):
    try:
        with Session(engine) as session:
            new_doc = Document(title=document.title, content=document.content)
            session.add(new_doc)
            session.commit()
            session.refresh(new_doc)
            return DocumentResponse.model_validate(new_doc)
    except Exception as e:
        print(f"Error creating document: {e}")
        return None

@router.get("/")
def search_documents(
    q: str = Query(...,description="The search query to find relevant documents"),
    limit: int = Query(default=10,description="Maximum number of results to return")) -> Optional[list[DocumentResponse]]:
    try:
        with Session(engine) as session:
            # Use PostgreSQL full-text search capabilities (correct usage)
            stmt = select(Document).where(
                Document.content_tsv.op("@@")(func.plainto_tsquery('english', q))
            ).limit(limit)
            results = session.execute(stmt).scalars().all()
            return [DocumentResponse.model_validate(doc) for doc in results]
    except Exception as e:
        print(f"Error searching documents: {e}")
        return None
    
@router.post("/upload/")
def upload_file(file:UploadFile = File(...)):
    try:
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(file.file.read())
            tmp_path = tmp.name
        with engine.raw_connection() as conn:
            cur = conn.cursor()
            try:
                with open(tmp_path,"r") as f:
                    cur.copy_expert(
                        "COPY documents (title, content) FROM STDIN WITH (FORMAT csv, HEADER true, DELIMITER ',')",
                        f
                    )
                conn.commit()
            finally:
                cur.close()
        return {"message": "File uploaded and data inserted successfully"}
    except Exception as e:
        print(f"Error uploading file: {e}")
        return {"message": "Error uploading file"}