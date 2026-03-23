from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import timezone

from app.db.session import SessionLocal
from app.models.mood import MoodHistory
from app.schemas.mood import MoodDetectRequest, MoodResponse, MoodLogRequest, MoodHistoryItem, HistoryResponse
from app.services.emotion_ai import emotion_analyzer
from app.api.v1.endpoints.auth import get_db # Reuse dependency

router = APIRouter()

from app.services.guardrail_service import guardrail_service

from fastapi import BackgroundTasks
from app.schemas.mood import MoodDetectAndPlanRequest, DetectAndPlanResponse
from app.services.planner_agent import planner_agent
from app.models.user import User
import ast
import asyncio
import time

def _log_mood_background(user_id: int, result: dict, text: str):
    db = SessionLocal()
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
    finally:
        db.close()

@router.post("/detect-and-plan", response_model=DetectAndPlanResponse)
async def detect_and_plan(request: MoodDetectAndPlanRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    start_time = time.time()
    # ⚡ CONCURRENCY BOOST: Run safety checks and emotion analysis in parallel ⚡
    # Guardrails is network-bound (LLM), Emotion is CPU-bound (Transformer)
    loop = asyncio.get_event_loop()
    
    safety_task = asyncio.create_task(guardrail_service.analyze(request.text))
    emotion_task = loop.run_in_executor(None, emotion_analyzer.analyze, request.text)
    
    # Also fetch user interests in a thread if needed
    interests = []
    if request.user_id:
        def fetch_interests():
            user = db.query(User).filter(User.id == request.user_id).first()
            if user and user.interests:
                try:
                    return ast.literal_eval(user.interests)
                except:
                    pass
            return []
        
        # We can run this in parallel too!
        interests_task = loop.run_in_executor(None, fetch_interests)
        is_safe, check_result = await safety_task
        result = await emotion_task
        interests = await interests_task
    else:
        is_safe, check_result = await safety_task
        result = await emotion_task
    
    # 1. Guardrail Check Result
    if not is_safe:
        # Check if this was a crisis rejection - expanded keywords
        crisis_keywords = ["suicide", "sucide", "kill myself", "want to die", "end it all", "end my life", 
                          "done with life", "i'm done", "im done", "i done", "really done", 
                          "better off dead", "hurt myself", "no reason to live", "wish i was dead",
                          "done wif", "am done with"]
        is_crisis = any(word in request.text.lower() for word in crisis_keywords)
        
        if is_crisis:
            # Emergency Crisis Path: Even if guardrail blocked for security, we MUST provide help
            crisis_plan = await planner_agent.generate_plan(
                mood="sadness (CRISIS)",
                intensity=0.99,
                user_id=request.user_id,
                interests=interests,
                text=request.text,
                risk_level="CRISIS"
            )
            return {
                "mood": {
                    "mood": "sad",
                    "emotion": "sadness",
                    "intensity": 0.99,
                    "energy_level": "low",
                    "decision_source": "safety_override",
                    "reason": check_result
                },
                "plan": crisis_plan
            }
            
        mood_res = {
            "mood": "neutral",
            "emotion": "neutral",
            "intensity": 0.1,
            "energy_level": "medium",
            "decision_source": "no_emotion_detected",
            "reason": f"Input filtered: {check_result}"
        }
        return {"mood": mood_res, "plan": []}

    # 2. Construct Mood Response
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

    # 3. Synchronous Logging (Real-time sync)
    # Background tasks can cause race conditions where the UI refreshes before the DB commit finishes.
    if request.user_id:
        try:
            log = MoodHistory(
                user_id=request.user_id,
                mood=result['mood'],
                emotion=result['emotion'],
                intensity=result['intensity'],
                energy_level=result['energy_level'],
                activities_used="[]",
                source="text"
            )
            db.add(log)
            db.commit()
            print(f"✅ Mood Logged: {result['mood']} for User {request.user_id}")
        except Exception as e:
            db.rollback()
            print(f"❌ Logging Failed: {e}")

    # 4. Generate Plan (Intelligent Routing)
    from app.services.router_agent import router_agent
    
    plan_mood_data = {
        "mood": result['mood'],
        "emotion": result['emotion'],
        "intensity": result['intensity'],
        "energy_level": result['energy_level'],
        "risk_level": result.get('risk_level', 'low'),
        "decision_source": result.get('decision_source')
    }
    
    plan = await router_agent.route(
        mood_data=plan_mood_data,
        user_id=request.user_id,
        interests=interests,
        text=request.text
    )

    duration = time.time() - start_time
    print(f"⏱️ Turbo Response generated in {duration:.4f}s")

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

@router.get("/history", response_model=HistoryResponse)
def get_history(user_id: int, db: Session = Depends(get_db)):
    # Get total count first
    total = db.query(MoodHistory).filter(MoodHistory.user_id == user_id).count()
    
    # Get last 100 logs
    logs = db.query(MoodHistory).filter(MoodHistory.user_id == user_id).order_by(MoodHistory.created_at.desc()).limit(100).all()
    
    # Ensure timezone is UTC for correct frontend parsing
    for log in logs:
        if log.created_at and log.created_at.tzinfo is None:
            log.created_at = log.created_at.replace(tzinfo=timezone.utc)
            
    return {"items": logs, "total": total}
