from pydantic import BaseModel
from typing import List, Optional

class SuggestionRequest(BaseModel):
    user_id: Optional[int] = None
    mood: str
    time_available_minutes: Optional[int] = 30
    preferences: Optional[dict] = {}

class PlanItem(BaseModel):
    type: str # 'breathing', 'micro_task', 'activity', 'music'
    description: str
    time_minutes: Optional[int] = None
    metadata: Optional[dict] = {}

class SuggestionResponse(BaseModel):
    plan: List[PlanItem]
    source: str

class MicroTaskResponse(BaseModel):
    id: int
    micro_task: str
    estimated_time_sec: int
