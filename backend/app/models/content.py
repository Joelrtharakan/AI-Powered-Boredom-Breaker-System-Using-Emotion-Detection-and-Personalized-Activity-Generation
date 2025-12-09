from sqlalchemy import Column, Integer, String, Text, TIMESTAMP
from sqlalchemy.sql import func
from app.db.base_class import Base

class Activity(Base):
    __tablename__ = "activities"
    id = Column(Integer, primary_key=True, index=True)
    category = Column(String)
    description = Column(String)
    mood = Column(String, index=True)
    energy_level = Column(String)
    time_minutes = Column(Integer)
    tags = Column(Text) # JSON/CSV
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

class MicroTask(Base):
    __tablename__ = "microtasks"
    id = Column(Integer, primary_key=True, index=True)
    micro_task = Column(String)
    type = Column(String)
    mood = Column(String, index=True)
    difficulty = Column(Integer)
    time_seconds = Column(Integer)
    tags = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
