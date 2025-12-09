from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
import base64
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

@router.post("/save")
def save_lockbox(item: LockboxSave, db: Session = Depends(get_db)):
    data = base64.b64decode(item.encrypted_data_base64)
    lb = Lockbox(user_id=item.user_id, label=item.label, encrypted_data=data)
    db.add(lb)
    db.commit()
    return {"id": lb.id}

@router.get("/list")
def list_lockbox(user_id: int, db: Session = Depends(get_db)):
    # Don't return data, just metadata
    return db.query(Lockbox).filter(Lockbox.user_id == user_id).all()
