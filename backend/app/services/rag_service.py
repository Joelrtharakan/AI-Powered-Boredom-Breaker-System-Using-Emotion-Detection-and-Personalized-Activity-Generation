import chromadb
from chromadb.config import Settings
import logging
import uuid

class RAGService:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        # Persistent storage for ChromaDB
        self.client = chromadb.PersistentClient(path="./chroma_db")
        
        # Get or Create Collections
        self.activities_col = self.client.get_or_create_collection("activities")
        self.micro_tasks_col = self.client.get_or_create_collection("micro_tasks")
        
        # Seed data if empty
        if self.activities_col.count() == 0:
            self.seed_data()
            
    def seed_data(self):
        self.logger.info("Seeding ChromaDB with initial data...")
        
        # 1. Activities
        activities = [
            {"text": "Quick desk stretches", "mood": "low_energy", "type": "activity"},
            {"text": "2-minute breathing reset", "mood": "stressed", "type": "breathing"},
            {"text": "Listen to a short upbeat track", "mood": "sad", "type": "music"},
            {"text": "Drink a glass of water", "mood": "neutral", "type": "activity"},
            {"text": "Do 10 jumping jacks", "mood": "boredom", "type": "activity"},
            {"text": "Write down 3 things you are grateful for", "mood": "sad", "type": "journal"},
            {"text": "Visualize your happy place for 60 seconds", "mood": "anxious", "type": "breathing"}
        ]
        
        self.activities_col.add(
            documents=[a["text"] for a in activities],
            metadatas=[{"mood": a["mood"], "type": a["type"]} for a in activities],
            ids=[str(uuid.uuid4()) for _ in activities]
        )

        # 2. Micro Tasks
        micro_tasks = [
            {"text": "Find something blue near you.", "mood": "boredom"},
            {"text": "Name 5 countries starting with A.", "mood": "boredom"},
            {"text": "Close your eyes and count to 10.", "mood": "stressed"},
            {"text": "Stretch your fingers.", "mood": "low_energy"},
            {"text": "Look out the window and spot a bird.", "mood": "boredom"}
        ]
        
        self.micro_tasks_col.add(
            documents=[m["text"] for m in micro_tasks],
            metadatas=[{"mood": m["mood"]} for m in micro_tasks],
            ids=[str(uuid.uuid4()) for _ in micro_tasks]
        )
        self.logger.info("ChromaDB seeding complete.")

    def query_activities(self, mood: str, n_results: int = 3):
        # Query based on mood text (semantic search)
        results = self.activities_col.query(
            query_texts=[mood],
            n_results=n_results
            # We could also filter by metadata, e.g., where={"mood": mood}
            # But semantic search is often better as it finds related concepts.
        )
        # Flatten results
        items = []
        if results['documents']:
             for i, doc in enumerate(results['documents'][0]):
                 meta = results['metadatas'][0][i]
                 items.append({"description": doc, "type": meta.get("type", "activity")})
        return items

    def query_micro_tasks(self, mood: str, n_results: int = 2):
        results = self.micro_tasks_col.query(
            query_texts=[mood],
            n_results=n_results
        )
        items = []
        if results['documents']:
             for i, doc in enumerate(results['documents'][0]):
                 items.append(doc)
        return items

rag_service = RAGService()
