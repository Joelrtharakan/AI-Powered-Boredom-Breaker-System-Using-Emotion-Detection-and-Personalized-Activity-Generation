from pydantic import BaseModel
from typing import List, Optional

class SuggestionRequest(BaseModel):
    user_id: Optional[int] = None
    mood: str
    emotion: Optional[str] = None
    intensity: Optional[float] = 0.5
    time_available_minutes: Optional[int] = 30
    preferences: Optional[dict] = {}
    text: Optional[str] = None
    decision_source: Optional[str] = None

class PlanItem(BaseModel):
    type: str # 'breathing', 'micro_task', 'activity', 'music', 'no_emotion'
    description: str
    time_minutes: Optional[int] = None
    metadata: Optional[dict] = {}
    purpose: Optional[str] = None
    no_plan: Optional[bool] = None

class SuggestionResponse(BaseModel):
    plan: List[PlanItem]
    source: str

class MicroTaskResponse(BaseModel):
    id: int
    micro_task: str
    estimated_time_sec: int
