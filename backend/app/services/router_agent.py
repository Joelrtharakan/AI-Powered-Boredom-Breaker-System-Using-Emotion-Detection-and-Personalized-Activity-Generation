import logging
import random
from app.services.planner_agent import planner_agent
from app.services.microtask_agent import microtask_agent
from app.services.surprise_agent import surprise_agent

class RouterAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    async def route(self, mood_data: dict, user_id: int, interests: list = None, text: str = ""):
        try:
            items = await self._route_logic(mood_data, user_id, interests, text)
            if not items:
                # Fallback if agent returned empty
                mood = mood_data.get("mood", "")
                emotion = mood_data.get("emotion", "unknown")
                return await planner_agent.generate_plan(f"{mood} (Detected Emotion: {emotion})", 0.5, user_id, interests, text=text)
            return items
        except Exception as e:
            self.logger.error(f"Router Error: {e}")
            return await planner_agent.generate_plan("neutral", 0.5, user_id, interests, text=text)

    async def _route_logic(self, mood_data: dict, user_id: int, interests: list = None, text: str = ""):
        """
        Internal routing logic
        """
        mood = mood_data.get("mood", "neutral")
        emotion = mood_data.get("emotion", "neutral")
        intensity = mood_data.get("intensity", 0.5)

        self.logger.info(f"Routing for Mood: {mood}, Emotion: {emotion}")

        # 1. Critical/Heavy Emotions -> Planner Agent (Needs structured help)
        fatigue_keywords = ["sleepy", "tired", "exhausted", "fatigue", "drained", "burnout", "no energy", "cant do anything", "can't do anything"]
        
        # Check raw text for fatigue too
        is_fatigued = any(k in mood.lower() for k in fatigue_keywords) or (text and any(k in text.lower() for k in fatigue_keywords))

        if emotion in ["sadness", "anger", "fear", "exhaustion", "stressed", "anxious", "sad"] or is_fatigued:
             self.logger.info("Selected Agent: PlannerAgent")
             return await planner_agent.generate_plan(f"{mood} (Detected Emotion: {emotion})", intensity, user_id, interests, text=text)

        # 2. Boredom -> Planner Agent (Full Plan: Micro-task + Activity + Music)
        elif emotion == "boredom":
             self.logger.info("Selected Agent: PlannerAgent (Boredom)")
             return await planner_agent.generate_plan(f"{mood} (Detected Emotion: {emotion})", intensity, user_id, interests, text=text)

        # 3. Neutral -> Surprise Agent (Spark joy)
        elif emotion == "neutral":
             self.logger.info("Selected Agent: SurpriseAgent")
             surprise = surprise_agent.generate()
             return [{
                 "type": "surprise",
                 "description": surprise['surprise'],
                 "time_minutes": 1
             }]

        # 4. Happy/Optimism -> Planner Agent (Sustainability Plan)
        else:
             self.logger.info("Selected Agent: PlannerAgent (Default)")
             return await planner_agent.generate_plan(f"{mood} (Detected Emotion: {emotion})", intensity, user_id, interests, text=text)

router_agent = RouterAgent()
