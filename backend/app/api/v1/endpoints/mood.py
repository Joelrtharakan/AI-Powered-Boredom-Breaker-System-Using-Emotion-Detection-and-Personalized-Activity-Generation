from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from app.db.session import SessionLocal
from app.models.mood import MoodHistory
from app.schemas.mood import MoodDetectRequest, MoodResponse, MoodLogRequest, MoodHistoryItem
from app.services.emotion_ai import emotion_analyzer
from app.api.v1.endpoints.auth import get_db # Reuse dependency

router = APIRouter()

@router.post("/detect", response_model=MoodResponse)
def detect_mood(request: MoodDetectRequest):
    # This might take time on first run
    result = emotion_analyzer.analyze(request.text)
    
    # Simple heuristic for energy level based on emotion
    energy_map = {
        "joy": "high",
        "optimism": "high",
        "anger": "high",
        "sadness": "low"
    }
    energy = energy_map.get(result['mood'], "medium")

    return {
        "mood": result['mood'],
        "emotion": result['emotion'],
        "intensity": result['intensity'],
        "energy_level": energy
    }

@router.post("/log")
def log_mood(request: MoodLogRequest, user_id: int, db: Session = Depends(get_db)):
    # Assuming user_id passed (should extract from JWT in real middleware)
    log = MoodHistory(
        user_id=user_id,
        mood=request.mood,
        intensity=request.intensity,
        activities_used=str(request.activities_used)
    )
    db.add(log)
    db.commit()
    return {"ok": True, "id": log.id}

@router.get("/history", response_model=List[MoodHistoryItem])
def get_history(user_id: int, db: Session = Depends(get_db)):
    logs = db.query(MoodHistory).filter(MoodHistory.user_id == user_id).order_by(MoodHistory.created_at.desc()).limit(20).all()
    return logs
