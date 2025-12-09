from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from app.db.session import SessionLocal
from app.models.journal import Journal

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class JournalCreate(BaseModel):
    user_id: int
    title: str
    content: str
    is_encrypted: bool = False

class JournalOut(BaseModel):
    id: int
    title: str
    content: str
    class Config:
        from_attributes = True

@router.post("/create")
def create_journal(log: JournalCreate, db: Session = Depends(get_db)):
    db_log = Journal(
        user_id=log.user_id,
        title=log.title,
        content=log.content,
        is_encrypted=1 if log.is_encrypted else 0
    )
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return {"id": db_log.id}

@router.get("/list", response_model=List[JournalOut])
def list_journal(user_id: int, db: Session = Depends(get_db)):
    return db.query(Journal).filter(Journal.user_id == user_id).all()
