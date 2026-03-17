import ast
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.user import User
from app.schemas.content import SuggestionRequest, SuggestionResponse, MicroTaskResponse
from app.services.router_agent import router_agent
from app.services.recommendation_bandit import bandit_service

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=SuggestionResponse)
async def suggest_plan(request: SuggestionRequest, db: Session = Depends(get_db)):
    # Fetch interests from DB if user_id is provided
    interests = []
    if request.user_id:
        user = db.query(User).filter(User.id == request.user_id).first()
        if user and user.interests:
            try:
                # interests is stored as string representation of list in auth.py: str(user_in.interests)
                interests = ast.literal_eval(user.interests)
                if not isinstance(interests, list):
                    interests = []
            except:
                interests = []

    # Route the request through the Agent Router logic
    plan_items = await router_agent.route(
        mood_data={
            "mood": request.mood,
            "emotion": request.emotion,
            "intensity": request.intensity,
            "decision_source": request.decision_source or ""
        },
        user_id=request.user_id,
        interests=interests,
        text=request.text
    )
    
    return {
        "plan": plan_items,
        "source": "AI_Agent_Router"
    }

from app.services.microtask_agent import microtask_agent
from app.services.surprise_agent import surprise_agent

@router.get("/micro-task", response_model=MicroTaskResponse)
async def get_micro_task(mood: str = "neutral"):
    result = await microtask_agent.generate(mood=mood)
    return {
        "id": 123, # mocked ID
        "micro_task": result['micro_task'],
        "estimated_time_sec": 60
    }

@router.get("/surprise")
async def surprise_me():
    result = await surprise_agent.generate()
    return {
        "type": result['type'],
        "payload": result['surprise']
    }

@router.post("/feedback")
async def give_feedback(user_id: int, action: str, reward: float):
    """Updates the personalization bandit with user feedback."""
    bandit_service.update(user_id, action, reward)
    return {"status": "success", "message": f"Updated model for {action}"}
