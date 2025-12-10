from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid

from app.db.session import SessionLocal
from app.models.chat import ChatHistory
from app.services.chat_agent import chat_agent

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class MessageIn(BaseModel):
    user_id: int
    session_id: Optional[str] = None
    message: str

class MessageOut(BaseModel):
    id: int
    role: str
    message: str
    created_at: datetime
    class Config:
        from_attributes = True

class ChatResponse(BaseModel):
    reply: str
    session_id: str

@router.post("/send", response_model=ChatResponse)
def send_message(msg: MessageIn, db: Session = Depends(get_db)):
    sid = msg.session_id or str(uuid.uuid4())
    
    # 1. Save user message
    user_entry = ChatHistory(
        user_id=msg.user_id,
        session_id=sid,
        role="user",
        message=msg.message,
        created_at=datetime.utcnow()
    )
    db.add(user_entry)
    db.commit()
    
    # 2. Agent Logic
    response_text = chat_agent.generate_response(msg.message)
    
    # 3. Save AI message
    ai_entry = ChatHistory(
        user_id=msg.user_id,
        session_id=sid,
        role="assistant",
        message=response_text,
        created_at=datetime.utcnow()
    )
    db.add(ai_entry)
    db.commit()
    
    return {"reply": response_text, "session_id": sid}

@router.get("/history", response_model=List[MessageOut])
def get_history(user_id: int, session_id: Optional[str] = None, limit: int = 50, db: Session = Depends(get_db)):
    query = db.query(ChatHistory).filter(ChatHistory.user_id == user_id)
    if session_id:
        query = query.filter(ChatHistory.session_id == session_id)
    
    return query.order_by(ChatHistory.created_at.asc()).limit(limit).all()
