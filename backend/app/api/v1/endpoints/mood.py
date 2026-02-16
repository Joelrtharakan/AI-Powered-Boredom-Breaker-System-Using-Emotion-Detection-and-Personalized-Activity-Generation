from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import timezone

from app.db.session import SessionLocal
from app.models.mood import MoodHistory
from app.schemas.mood import MoodDetectRequest, MoodResponse, MoodLogRequest, MoodHistoryItem
from app.services.emotion_ai import emotion_analyzer
from app.api.v1.endpoints.auth import get_db # Reuse dependency

router = APIRouter()

@router.post("/detect", response_model=MoodResponse)
def detect_mood(request: MoodDetectRequest):
    result = emotion_analyzer.analyze(request.text)
    
    return {
        "mood": result['mood'],
        "emotion": result['emotion'],
        "intensity": result['intensity'],
        "energy_level": result['energy_level'],
        "secondary_emotion": result.get('secondary_emotion'),
        "confidence_level": result.get('confidence_level'),
        "decision_source": result.get('decision_source'),
        "reason": result.get('reason')
    }

@router.post("/log")
def log_mood(request: MoodLogRequest, user_id: int, db: Session = Depends(get_db)):
    # Assuming user_id passed (should extract from JWT in real middleware)
    log = MoodHistory(
        user_id=user_id,
        mood=request.mood,
        emotion=request.emotion,
        intensity=request.intensity,
        energy_level=request.energy_level,
        activities_used=str(request.activities_used),
        source=request.source
    )
    db.add(log)
    db.commit()
    return {"ok": True, "id": log.id}

@router.get("/history", response_model=List[MoodHistoryItem])
def get_history(user_id: int, db: Session = Depends(get_db)):
    logs = db.query(MoodHistory).filter(MoodHistory.user_id == user_id).order_by(MoodHistory.created_at.desc()).limit(20).all()
    
    # Ensure timezone is UTC for correct frontend parsing
    for log in logs:
        if log.created_at and log.created_at.tzinfo is None:
            log.created_at = log.created_at.replace(tzinfo=timezone.utc)
            
    return logs
