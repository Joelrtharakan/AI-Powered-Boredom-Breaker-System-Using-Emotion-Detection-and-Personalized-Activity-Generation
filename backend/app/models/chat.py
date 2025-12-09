from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class ChatHistory(Base):
    __tablename__ = "chat_history"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    session_id = Column(String, index=True)
    role = Column(String) # user | assistant | system
    message = Column(Text)
    metadata_json = Column("metadata", Text)
    created_at = Column(TIMESTAMP, server_default=func.now())
    
    user = relationship("User")
