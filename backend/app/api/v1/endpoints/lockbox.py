from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
import base64
from typing import List
from datetime import datetime

from app.db.session import SessionLocal
from app.models.lockbox import Lockbox

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class LockboxSave(BaseModel):
    user_id: int
    label: str
    encrypted_data_base64: str

class LockboxUnlock(BaseModel):
    id: int
    
class LockboxOut(BaseModel):
    id: int
    label: str
    created_at: datetime
    class Config:
        from_attributes = True

@router.post("/save")
def save_lockbox(item: LockboxSave, db: Session = Depends(get_db)):
    data = base64.b64decode(item.encrypted_data_base64)
    lb = Lockbox(
        user_id=item.user_id, 
        label=item.label, 
        encrypted_data=data,
        created_at=datetime.utcnow()
    )
    db.add(lb)
    db.commit()
    db.refresh(lb)
    return {"id": lb.id}

@router.get("/list", response_model=List[LockboxOut])
def list_lockbox(user_id: int, db: Session = Depends(get_db)):
    # Don't return data, just metadata
    return db.query(Lockbox).filter(Lockbox.user_id == user_id).all()

@router.post("/unlock")
def unlock_lockbox(req: LockboxUnlock, db: Session = Depends(get_db)):
    # In a real E2EE system, the server NEVER decrypts.
    # But as per spec, we'll return the encrypted blob for client to decrypt.
    # Or if server-side encryption was meant:
    lb = db.query(Lockbox).filter(Lockbox.id == req.id).first()
    if not lb:
        raise HTTPException(status_code=404, detail="Lockbox item not found")
    
    # Return base64 encoded data so client can decrypt
    return {
        "encrypted_data_base64": base64.b64encode(lb.encrypted_data).decode('utf-8')
    }
