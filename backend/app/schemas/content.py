from pydantic import BaseModel
from typing import List, Optional

class SuggestionRequest(BaseModel):
    user_id: Optional[int] = None
    mood: str
    emotion: Optional[str] = None
    intensity: Optional[float] = 0.5
    energy_level: Optional[str] = "medium"  # low, medium, high
    risk_level: Optional[str] = "low"  # low, medium, high
    user_intent: Optional[str] = "unknown"  # game_request, relax, focus, unknown
    trajectory_state: Optional[str] = "stable"  # improving, stable, declining
    time_available_minutes: Optional[int] = 30
    preferences: Optional[dict] = {}
    text: Optional[str] = None
    decision_source: Optional[str] = None
    subtype: Optional[str] = None
    nervous_system_state: Optional[str] = None

class PlanItem(BaseModel):
    type: str # 'breathing', 'micro_task', 'activity', 'music', 'no_emotion', 'intervention'
    description: str
    time_minutes: Optional[int] = None
    metadata: Optional[dict] = {}
    purpose: Optional[str] = None
    no_plan: Optional[bool] = None
    # Structured Intervention Fields
    intervention: Optional[str] = None # 'game', 'breathing', 'journaling', 'music', 'chat'
    game_id: Optional[str] = None
    reason: Optional[str] = None
    confidence: Optional[float] = None

class SuggestionResponse(BaseModel):
    plan: List[PlanItem]
    source: str

class MicroTaskResponse(BaseModel):
    id: int
    micro_task: str
    estimated_time_sec: int
