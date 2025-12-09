from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db.session import SessionLocal
from app.models.game import GameScore

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class ScoreSubmit(BaseModel):
    user_id: int
    result: dict

@router.post("/{game_name}/submit")
def submit_score(game_name: str, item: ScoreSubmit, db: Session = Depends(get_db)):
    score_val = item.result.get("score", 0)
    meta = str(item.result)
    
    gs = GameScore(
        user_id=item.user_id,
        game_name=game_name,
        score=score_val,
        metadata_json=meta
    )
    db.add(gs)
    db.commit()
    return {"success": True, "score": score_val}
