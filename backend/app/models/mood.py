from sqlalchemy import Column, Integer, String, Float, Text, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from app.models.user import User

class MoodHistory(Base):
    __tablename__ = "mood_history"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    mood = Column(String)
    emotion = Column(String)
    intensity = Column(Float)
    energy_level = Column(String)
    activities_used = Column(Text) # JSON string
    source = Column(String) # 'text' | 'voice' | 'surprise'
    created_at = Column(TIMESTAMP, server_default=func.now(), index=True)
    
    user = relationship("User")
