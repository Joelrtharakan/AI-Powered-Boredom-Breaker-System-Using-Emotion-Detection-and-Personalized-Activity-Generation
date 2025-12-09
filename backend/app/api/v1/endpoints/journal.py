from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

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

class JournalEdit(BaseModel):
    title: str
    content: str
    is_encrypted: bool

class JournalOut(BaseModel):
    id: int
    title: str
    content: str
    created_at: datetime
    is_encrypted: bool
    class Config:
        from_attributes = True

@router.post("/create")
def create_journal(log: JournalCreate, db: Session = Depends(get_db)):
    db_log = Journal(
        user_id=log.user_id,
        title=log.title,
        content=log.content,
        is_encrypted=1 if log.is_encrypted else 0,
        created_at=datetime.utcnow()
    )
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return {"id": db_log.id}

@router.get("/list", response_model=List[JournalOut])
def list_journal(user_id: int, limit: int = 20, offset: int = 0, db: Session = Depends(get_db)):
    return db.query(Journal).filter(Journal.user_id == user_id).order_by(Journal.created_at.desc()).offset(offset).limit(limit).all()

@router.get("/{id}", response_model=JournalOut)
def get_journal(id: int, db: Session = Depends(get_db)):
    entry = db.query(Journal).filter(Journal.id == id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    return entry

@router.put("/{id}/edit")
def edit_journal(id: int, item: JournalEdit, db: Session = Depends(get_db)):
    entry = db.query(Journal).filter(Journal.id == id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    
    entry.title = item.title
    entry.content = item.content
    entry.is_encrypted = 1 if item.is_encrypted else 0
    db.commit()
    return {"ok": True}

@router.delete("/{id}")
def delete_journal(id: int, db: Session = Depends(get_db)):
    entry = db.query(Journal).filter(Journal.id == id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    
    db.delete(entry)
    db.commit()
    return {"ok": True}
