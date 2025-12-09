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

@router.get("/micro-task", response_model=MicroTaskResponse)
def get_micro_task(mood: str):
    # Query vector db directly
    results = chroma_service.query_microtasks(query_text=mood, n_results=1)
    if results['documents'] and results['documents'][0]:
        doc = results['documents'][0][0]
        meta = results['metadatas'][0][0]
        # fake id
        return {
            "id": 123, 
            "micro_task": doc,
            "estimated_time_sec": meta.get('time_seconds', 120)
        }
    return {
        "id": 0,
        "micro_task": "Take a deep breath and smile.",
        "estimated_time_sec": 10
    }

@router.get("/surprise")
def surprise_me():
    # Random content
    facts = ["Honey never spoils.", "Octopuses have 3 hearts.", "Bananas are berries."]
    import random
    return {
        "type": "fact",
        "payload": {"text": random.choice(facts)}
    }
