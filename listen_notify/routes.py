import asyncio
from typing import Optional
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from schemas import MessageCreate, MessageResponse
from models import Message
from sqlalchemy.orm import Session
from db_conn import engine

router = APIRouter(prefix="/message", tags=["message"])
clients = set()

@router.post("/")
def post_message(message: MessageCreate) -> Optional[MessageResponse]:
    try:
        with Session(engine) as session:
            new_message = Message(content=message.content,sender=message.sender)
            session.add(new_message)
            session.commit()
            session.refresh(new_message)
            return MessageResponse.model_validate(new_message)
    except Exception as e:
        print(f"Error posting message: {e}")
        return None
    
@router.get("/list/")
def list_messages() -> Optional[list[MessageResponse]]:
    try:
        with Session(engine) as session:
            messages = session.query(Message).order_by(Message.timestamp.desc()).all()
            return [MessageResponse.model_validate(msg) for msg in messages]
    except Exception as e:
        print(f"Error listing messages: {e}")
        return None
    
@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    clients.add(websocket)
    try:
        while True:
            await asyncio.sleep(1)  # Keep the connection alive
    except WebSocketDisconnect:
        clients.remove(websocket)