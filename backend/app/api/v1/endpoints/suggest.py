from fastapi import APIRouter, Depends
from app.schemas.content import SuggestionRequest, SuggestionResponse, MicroTaskResponse
from app.services.recommendation import planner_agent
from app.services.chroma_service import chroma_service

router = APIRouter()

@router.post("/", response_model=SuggestionResponse)
def suggest_plan(request: SuggestionRequest):
    # Call the planner agent
    plan_data = planner_agent.generate_plan(
        mood=request.mood,
        intensity=0.8,
        time_minutes=request.time_available_minutes,
        preferences=request.preferences
    )
    return plan_data

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

