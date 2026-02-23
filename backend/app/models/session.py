from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from app.db.base_class import Base

class ChatSessionContext(Base):
    __tablename__ = "chat_session_contexts"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    session_id = Column(String, index=True, unique=True)
    context_summary = Column(Text, default="")
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
