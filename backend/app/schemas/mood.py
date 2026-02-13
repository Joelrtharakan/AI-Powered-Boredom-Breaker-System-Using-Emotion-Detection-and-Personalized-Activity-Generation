from pydantic import BaseModel
from typing import Optional, List, Any

class MoodDetectRequest(BaseModel):
    text: str

class MoodResponse(BaseModel):
    mood: str
    emotion: str
    intensity: float
    energy_level: str
    secondary_emotion: Optional[str] = None
    confidence_level: Optional[float] = None
    decision_source: Optional[str] = None
    reason: Optional[str] = None

class MoodLogRequest(BaseModel):
    mood: str
    intensity: float
    activities_used: Optional[List[str]] = []

class MoodHistoryItem(BaseModel):
    id: int
    mood: str
    emotion: Optional[str]
    intensity: Optional[float]
    created_at: Any 
    
    class Config:
        from_attributes = True
