import ast
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.user import User
from app.schemas.content import SuggestionRequest, SuggestionResponse, MicroTaskResponse
from app.services.router_agent import router_agent

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
            "intensity": request.intensity
        },
        user_id=request.user_id,
        interests=interests
    )
    
    return {
        "plan": plan_items,
        "source": "AI_Agent_Router"
    }

from app.services.microtask_agent import microtask_agent
from app.services.surprise_agent import surprise_agent

@router.get("/micro-task", response_model=MicroTaskResponse)
def get_micro_task(mood: str = "neutral"):
    result = microtask_agent.generate(mood=mood)
    return {
        "id": 123, # mocked ID
        "micro_task": result['micro_task'],
        "estimated_time_sec": 60
    }

@router.get("/surprise")
def surprise_me():
    result = surprise_agent.generate()
    return {
        "type": result['type'],
        "payload": result['surprise'] # Payload usually expects dict? Let's check frontend usage or keep simple.
        # Frontend alert: alert(`Surprise! ${res.data.type}: ${JSON.stringify(res.data.payload)}`);
        # So payload can be string or dict. Let's wrap in dict similar to previous to be safe:
        # "payload": {"text": ...}
    }

