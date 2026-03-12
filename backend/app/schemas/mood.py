from pydantic import BaseModel
from typing import Optional, List, Any
from datetime import datetime

class MoodDetectRequest(BaseModel):
    text: str

class MoodResponse(BaseModel):
    mood: str
    emotion: str
    intensity: float
    energy_level: str
    subtype: Optional[str] = None
    nervous_system_state: Optional[str] = None
    secondary_emotion: Optional[str] = None
    confidence_level: Optional[float] = None
    decision_source: Optional[str] = None
    reason: Optional[str] = None

class MoodLogRequest(BaseModel):
    mood: str
    emotion: str
    intensity: float
    energy_level: str
    activities_used: Optional[List[str]] = []
    source: Optional[str] = "text"

class MoodDetectAndPlanRequest(BaseModel):
    text: str
    user_id: Optional[int] = None

from app.schemas.content import PlanItem

class DetectAndPlanResponse(BaseModel):
    mood: MoodResponse
    plan: List[PlanItem]

class MoodHistoryItem(BaseModel):
    id: int
    mood: str
    emotion: Optional[str] = None
    intensity: Optional[float] = None
    energy_level: Optional[str] = None
    source: Optional[str] = None
    created_at: datetime 
    
    class Config:
        from_attributes = True
