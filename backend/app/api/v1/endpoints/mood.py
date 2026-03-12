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

from app.services.guardrail_service import guardrail_service

from fastapi import BackgroundTasks
from app.schemas.mood import MoodDetectAndPlanRequest, DetectAndPlanResponse
from app.services.planner_agent import planner_agent
from app.models.user import User
import ast

def _log_mood_background(db: Session, user_id: int, result: dict, text: str):
    try:
        log = MoodHistory(
            user_id=user_id,
            mood=result['mood'],
            emotion=result['emotion'],
            intensity=result['intensity'],
            energy_level=result['energy_level'],
            activities_used="[]",
            source="text"
        )
        db.add(log)
        db.commit()
    except Exception as e:
        print(f"Background Logging Failed: {e}")

@router.post("/detect-and-plan", response_model=DetectAndPlanResponse)
async def detect_and_plan(request: MoodDetectAndPlanRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    # 1. Guardrails
    is_safe, check_result = await guardrail_service.analyze(request.text)
    
    if not is_safe:
        mood_res = {
            "mood": "neutral",
            "emotion": "neutral",
            "intensity": 0.1,
            "energy_level": "medium",
            "decision_source": "no_emotion_detected",
            "reason": f"Input filtered: {check_result}"
        }
        return {"mood": mood_res, "plan": []}

    # 2. Emotion Analysis
    result = emotion_analyzer.analyze(request.text)
    
    mood_res = {
        "mood": result['mood'],
        "emotion": result['emotion'],
        "intensity": result['intensity'],
        "energy_level": result['energy_level'],
        "subtype": result.get('subtype'),
        "nervous_system_state": result.get('nervous_system_state'),
        "secondary_emotion": result.get('secondary_emotion'),
        "confidence_level": result.get('confidence_level'),
        "decision_source": result.get('decision_source'),
        "reason": result.get('reason')
    }

    # 3. Background Log
    if request.user_id:
        background_tasks.add_task(_log_mood_background, db, request.user_id, result, request.text)

    # 4. Generate Plan (Reuse results for speed)
    interests = []
    if request.user_id:
        user = db.query(User).filter(User.id == request.user_id).first()
        if user and user.interests:
            try:
                interests = ast.literal_eval(user.interests)
            except:
                pass

    # Note: Using planner directly here to skip router_agent's extra overhead
    plan = await planner_agent.generate_plan(
        mood=f"{result['mood']} (Detected Emotion: {result['emotion']})",
        intensity=result['intensity'],
        user_id=request.user_id,
        interests=interests,
        text=request.text,
        subtype=result.get('subtype'),
        ns_state=result.get('nervous_system_state'),
        risk_level=result.get('risk_level')
    )

    return {
        "mood": mood_res,
        "plan": plan
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
    logs = db.query(MoodHistory).filter(MoodHistory.user_id == user_id).order_by(MoodHistory.created_at.desc()).limit(100).all()
    
    # Ensure timezone is UTC for correct frontend parsing
    for log in logs:
        if log.created_at and log.created_at.tzinfo is None:
            log.created_at = log.created_at.replace(tzinfo=timezone.utc)
            
    return logs
