import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.content import Activity, MicroTask
from app.services.chroma_service import chroma_service

def init_vectors():
    db = SessionLocal()
    activities = db.query(Activity).all()
    microtasks = db.query(MicroTask).all()
    
    print(f"Indexing {len(activities)} activities...")
    for act in activities:
        # text to embed
        text = f"{act.mood} {act.category}: {act.description}"
        chroma_service.add_activity(
            activity_id=act.id,
            text=text,
            metadata={"mood": act.mood, "time_minutes": act.time_minutes}
        )
        
    print(f"Indexing {len(microtasks)} microtasks...")
    for mt in microtasks:
        text = f"{mt.mood} {mt.type}: {mt.micro_task}"
        chroma_service.add_microtask(
            task_id=mt.id,
            text=text,
            metadata={"mood": mt.mood, "time_seconds": mt.time_seconds}
        )
        
    print("Vector DB initialized.")

if __name__ == "__main__":
    init_vectors()
