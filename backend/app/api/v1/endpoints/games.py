from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, Dict, Any
from app.db.session import SessionLocal
from app.models.game import GameScore
from datetime import datetime

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class GameStart(BaseModel):
    user_id: int
    difficulty: str

class ScoreSubmit(BaseModel):
    user_id: int
    result: Dict[str, Any]

@router.post("/{game_name}/start")
def start_game(game_name: str, item: GameStart):
    # Just return initial config
    return {
        "game_state": {
            "level": 1,
            "lives": 3,
            "difficulty": item.difficulty,
            "seed": 12345
        }
    }

@router.post("/{game_name}/submit")
def submit_score(game_name: str, item: ScoreSubmit, db: Session = Depends(get_db)):
    score_val = item.result.get("score", 0)
    meta = str(item.result)
    
    gs = GameScore(
        user_id=item.user_id,
        game_name=game_name,
        score=score_val,
        metadata_json=meta,
        created_at=datetime.utcnow()
    )
    db.add(gs)
    db.commit()
    db.refresh(gs)
    return {"success": True, "score": score_val}

@router.get("/scores/{user_id}")
def get_user_scores(user_id: int, db: Session = Depends(get_db)):
    all_scores = db.query(GameScore).filter(GameScore.user_id == user_id).all()
    best_scores = {}
    
    for s in all_scores:
        name = s.game_name
        score = s.score
        
        if name == 'reaction':
            # Lower is better for reaction time
            if name not in best_scores or score < best_scores[name]:
                best_scores[name] = score
        else:
            # Higher is better for everything else
            if name not in best_scores or score > best_scores[name]:
                best_scores[name] = score
                
    return best_scores
