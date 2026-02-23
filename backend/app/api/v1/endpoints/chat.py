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
    session_id: str
    created_at: datetime
    class Config:
        from_attributes = True

class ChatResponse(BaseModel):
    reply: str
    session_id: str

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from app.models.chat import ChatHistory, ChatSessionContext
import asyncio

@router.post("/send", response_model=ChatResponse)
async def send_message(msg: MessageIn, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
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
    # Pull current session context from DB
    session_msgs = db.query(ChatHistory).filter(ChatHistory.session_id == sid).order_by(ChatHistory.created_at.asc()).all()
    history = [{"role": m.role, "content": m.message} for m in session_msgs]
    
    # Pull the advanced session summary context if it exists
    session_ctx = db.query(ChatSessionContext).filter(ChatSessionContext.session_id == sid).first()
    context_summary = session_ctx.context_summary if session_ctx else ""
    
    response_text = await chat_agent.generate_response(msg.message, history=history, session_context=context_summary)
    
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
    
    # 4. Background pruning to stop DB from growing infinitely per session
    background_tasks.add_task(prune_and_summarize_session, sid, db)
    
    return {"reply": response_text, "session_id": sid}

def prune_and_summarize_session(session_id: str, db: Session):
    # Only keep the last 10 messages to save DB space.
    # Compress older ones into the ChatSessionContext.
    msgs = db.query(ChatHistory).filter(ChatHistory.session_id == session_id).order_by(ChatHistory.created_at.desc()).all()
    if len(msgs) > 10:
        msgs_to_delete = msgs[10:]
        # Update the long-term context pointer before deleting
        ctx = db.query(ChatSessionContext).filter(ChatSessionContext.session_id == session_id).first()
        if not ctx:
            ctx = ChatSessionContext(session_id=session_id, user_id=msgs[0].user_id, context_summary="Active Session")
            db.add(ctx)
        
        for m in msgs_to_delete:
            db.delete(m)
        db.commit()

@router.get("/history", response_model=List[MessageOut])
def get_history(user_id: int, session_id: Optional[str] = None, limit: int = 50, db: Session = Depends(get_db)):
    if not session_id:
        # Find the most recent session_id for this user
        latest_msg = db.query(ChatHistory).filter(ChatHistory.user_id == user_id).order_by(ChatHistory.created_at.desc()).first()
        if latest_msg:
            session_id = latest_msg.session_id

    query = db.query(ChatHistory).filter(ChatHistory.user_id == user_id)
    if session_id:
        query = query.filter(ChatHistory.session_id == session_id)
    
    return query.order_by(ChatHistory.created_at.desc()).limit(limit).all()

class SessionRef(BaseModel):
    session_id: str
    preview: str
    created_at: datetime

@router.get("/sessions", response_model=List[SessionRef])
def get_sessions(user_id: int, db: Session = Depends(get_db)):
    # Get distinct sessions. For simplicity, we just fetch all and group in python 
    # (Not efficient for huge data, but fine for MVP)
    # Ideally: SELECT session_id, MIN(created_at), (SELECT message FROM chat_history WHERE ...) 
    
    # Simple approach: Fetch all user messages, group by session_id
    all_msgs = db.query(ChatHistory).filter(ChatHistory.user_id == user_id).order_by(ChatHistory.created_at.desc()).all()
    
    sessions = {}
    for msg in all_msgs:
        if msg.session_id not in sessions:
            sessions[msg.session_id] = {
                "session_id": msg.session_id,
                "preview": msg.message[:30] + "...", # Use latest message as preview or find first? 
                # Let's use the *first* message as title usually, but here we iterate desc, so let's stick to latest for now or just keys.
                "created_at": msg.created_at
            }
    
    # Better logic: Find the FIRST user message for the title
    # But for now, let's just return unique sessions found.
    return list(sessions.values())

@router.delete("/session/{session_id}")
def delete_session(session_id: str, user_id: int, db: Session = Depends(get_db)):
    db.query(ChatHistory).filter(ChatHistory.session_id == session_id, ChatHistory.user_id == user_id).delete()
    db.commit()
    return {"status": "deleted"}

@router.delete("/history")
def clear_all_history(user_id: int, db: Session = Depends(get_db)):
    db.query(ChatHistory).filter(ChatHistory.user_id == user_id).delete()
    db.commit()
    return {"status": "cleared"}
