from app.services.chroma_service import chroma_service
import random

class PlannerAgent:
    def generate_plan(self, mood: str, intensity: float, time_minutes: int, preferences: dict):
        # Map detected mood to target content mood
        target_mood_map = {
            "boredom": "excitement",
            "sadness": "comfort",
            "joy": "joy",
            "anger": "relaxation",
            "fear": "calm",
            "optimism": "productivity",
             # labels from twitter-roberta
             "joy": "celebration",
             "sadness": "uplifting",
             "anger": "calm",
             "optimism": "progress"
        }
        
        target_query = target_mood_map.get(mood, "general")
        
        # Query Vector DB
        # We query with the 'target context'
        activities = chroma_service.query_activities(query_text=target_query, n_results=5)
        microtasks = chroma_service.query_microtasks(query_text=target_query, n_results=5)
        
        plan = []
        
        # 1. Calibration (Breathing)
        plan.append({
            "type": "breathing",
            "description": "Take deep breaths. Inhale for 4s, hold for 7s, exhale for 8s.",
            "time_minutes": 2
        })
        
        # 2. Micro Task (Quick win)
        if microtasks['documents'] and microtasks['documents'][0]:
             # Randomly pick one from top 3
             candidates = microtasks['documents'][0]
             meta = microtasks['metadatas'][0]
             idx = random.randint(0, min(len(candidates)-1, 2))
             
             plan.append({
                 "type": "micro_task",
                 "description": candidates[idx],
                 "time_minutes": meta[idx].get('time_seconds', 300) // 60,
                 "metadata": meta[idx]
             })
             
        # 3. Main Activity
        if activities['documents'] and activities['documents'][0]:
             candidates = activities['documents'][0]
             meta = activities['metadatas'][0]
             idx = random.randint(0, min(len(candidates)-1, 2))
             
             plan.append({
                 "type": "activity",
                 "description": candidates[idx],
                 "time_minutes": meta[idx].get('time_minutes', 15),
                 "metadata": meta[idx]
             })
             
        # 4. Music Recommendation (Placeholder logic)
        plan.append({
            "type": "music",
            "description": f"Listen to a {target_query} playlist.",
            "time_minutes": 5
        })
        
        # 5. Affirmation / Closing
        affirmations = ["You got this!", "Small steps lead to big changes.", "Stay awesome."]
        plan.append({
            "type": "affirmation",
            "description": random.choice(affirmations),
            "time_minutes": 1
        })
        
        return {
            "plan": plan,
            "source": "rag+planner_agent"
        }

planner_agent = PlannerAgent()
