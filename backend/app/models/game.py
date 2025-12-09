from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from app.models.user import User

class GameScore(Base):
    __tablename__ = "game_scores"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), index=True)
    game_name = Column(String, nullable=False, index=True)
    score = Column(Integer, nullable=False)
    metadata_json = Column("metadata", Text) # JSON, using 'metadata_json' alias for python attr but 'metadata' for DB col
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    user = relationship("User")
