import json
import logging
import random
from app.services.llm_service import llm_service
from app.services.rag_service import rag_service
from app.services.spotify_service import spotify_service

class PlannerAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def generate_plan(self, mood: str, intensity: float, user_id: int = None):
        """
        Generates a 3-step improvement plan using RAG + LLM.
        """
        # 1. Retrieve Context from ChromaDB
        relevant_activities = rag_service.query_activities(mood, n_results=3)
        relevant_micro_tasks = rag_service.query_micro_tasks(mood, n_results=3)
        
        context_str = f"Suggested Activities: {relevant_activities}\nSuggested Micro-tasks: {relevant_micro_tasks}"
        
        # 2. Construct Prompt
        system_prompt = """You are an expert Planner Agent. Your goal is to create a personalized, actionable 3-step improvement plan to improve the user's mood.
        
Rules:
1. You MUST return a JSON ARRAY of objects.
2. Each object must have: "type", "description", "time_minutes".
3. Valid types: "breathing", "micro_task", "activity", "music", "affirmation", "game".
4. The plan MUST include exactly 3 items:
   - Item 1: A small Micro-task or Breathing exercise (1-2 mins)
   - Item 2: A main Activity (5-10 mins)
   - Item 3: An Affirmation or Music track
   * CRITICAL: If mood is 'sad', 'anxious', 'stress', 'depressed', Item 3 MUST be 'music'.
5. Use the provided Context if relevant, but adapt it to be engaging.
"""

        user_prompt = f"""
User Mood: {mood} (Intensity: {intensity})
Context from Database:
{context_str}

Generate the 3-step JSON plan now.
"""
        plan = []

        # 3. Call LLM
        try:
            response_text = llm_service.generate(system_prompt, user_prompt)
            print(f"DEBUG LLM RAW: {response_text}")
            # Clean response to ensure valid JSON
            cleaned_text = response_text
            if "```json" in response_text:
                cleaned_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                cleaned_text = response_text.split("```")[1].split("```")[0].strip()
                
            parsed = json.loads(cleaned_text)
            
            if isinstance(parsed, dict) and "plan" in parsed:
                parsed = parsed["plan"]
                
            if not isinstance(parsed, list):
                raise ValueError("LLM response is not a list")
            
            if len(parsed) == 0:
                raise ValueError("LLM returned empty plan")
            
            plan = parsed

        except Exception as e:
            self.logger.error(f"Planner Agent failed: {e}")
            # Smart Fallback
            step3_type = "music" if mood in ["sad", "sadness", "depressed", "anxious", "stress", "stressed"] else "affirmation"
            desc = "Listen to some healing frequencies." if step3_type == "music" else "You are doing your best."
            
            plan = [
                {"type": "breathing", "description": "Take 5 deep breaths.", "time_minutes": 1},
                {"type": "micro_task", "description": "Look away from the screen for 20 seconds.", "time_minutes": 1},
                {"type": step3_type, "description": desc, "time_minutes": 5 if step3_type == "music" else 0}
            ]

        # 4. Inject Game Recommendation (Bonus for Boredom/Stress)
        if mood in ["bored", "boredom", "stressed", "anxious", "low_energy", "neutral", "sad", "sadness"]:
                games = ["Reaction Time", "Aim Trainer", "Number Guess", "Chimp Test", "Memory Flip", "Visual Memory"]
                plan.append({
                    "type": "game",
                    "description": f"Play {random.choice(games)} to reset your focus.",
                    "time_minutes": 5
                })

        # 5. Inject Music Recommendation (Universal)
        for step in plan:
            if step.get("type") == "music":
                playlists = spotify_service.get_mood_playlists(mood, limit=1)
                if playlists:
                    step["spotify_uri"] = playlists[0]["uri"]
                    step["description"] += f" (Try: {playlists[0]['name']})"
                    step["image"] = playlists[0].get("image")

        return plan

planner_agent = PlannerAgent()
