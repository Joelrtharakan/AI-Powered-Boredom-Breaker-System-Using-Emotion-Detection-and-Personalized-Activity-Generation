import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.content import Activity, MicroTask
from app.db.base import Base
from app.db.session import engine

def seed():
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    # 1. Activities
    activities = [
        {"category": "Fitness", "description": "Do a 15-minute HIIT workout.", "mood": "energy", "time_minutes": 15},
        {"category": "Creativity", "description": "Write a short poem about the rain.", "mood": "calm", "time_minutes": 10},
        {"category": "Relaxation", "description": "Listen to a guided meditation.", "mood": "stress", "time_minutes": 10},
        {"category": "Fun", "description": "Watch a standup comedy clip.", "mood": "joy", "time_minutes": 15},
        {"category": "Productivity", "description": "Clean your desk for 5 minutes.", "mood": "boredom", "time_minutes": 5},
        {"category": "Learning", "description": "Read an article about a new topic.", "mood": "curiosity", "time_minutes": 10},
    ]
    
    for act in activities:
        if not db.query(Activity).filter_by(description=act['description']).first():
            db_obj = Activity(**act)
            db.add(db_obj)
            
    # 2. MicroTasks
    tasks = [
        {"micro_task": "Drink a glass of water.", "type": "health", "mood": "neutral", "time_seconds": 30},
        {"micro_task": "Stretch your neck.", "type": "health", "mood": "stress", "time_seconds": 30},
        {"micro_task": "Text a friend you haven't spoken to.", "type": "social", "mood": "lonely", "time_seconds": 60},
        {"micro_task": "Do 10 jumping jacks.", "type": "fitness", "mood": "tired", "time_seconds": 20},
        {"micro_task": "Name 5 things you are grateful for.", "type": "mindfulness", "mood": "sad", "time_seconds": 60},
    ]
    
    for task in tasks:
         if not db.query(MicroTask).filter_by(micro_task=task['micro_task']).first():
            db_obj = MicroTask(**task)
            db.add(db_obj)
            
    db.commit()
    print("Seeding complete.")

if __name__ == "__main__":
    seed()
