import logging
import random
from app.services.planner_agent import planner_agent
from app.services.microtask_agent import microtask_agent
from app.services.surprise_agent import surprise_agent

class RouterAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def route(self, mood_data: dict, user_id: int):
        try:
            items = self._route_logic(mood_data, user_id)
            if not items:
                # Fallback if agent returned empty
                return planner_agent.generate_plan(mood_data.get("mood"), 0.5, user_id)
            return items
        except Exception as e:
            self.logger.error(f"Router Error: {e}")
            return planner_agent.generate_plan("neutral", 0.5, user_id)

    def _route_logic(self, mood_data: dict, user_id: int):
        """
        Internal routing logic
        """
        mood = mood_data.get("mood", "neutral")
        emotion = mood_data.get("emotion", "neutral")
        intensity = mood_data.get("intensity", 0.5)

        self.logger.info(f"Routing for Mood: {mood}, Emotion: {emotion}")

        # 1. Critical/Heavy Emotions -> Planner Agent (Needs structured help)
        if emotion in ["sadness", "anger", "fear", "exhaustion", "stressed", "anxious", "sad"]:
             self.logger.info("Selected Agent: PlannerAgent")
             return planner_agent.generate_plan(mood, intensity, user_id)

        # 2. Boredom -> Planner Agent (Full Plan: Micro-task + Activity + Music)
        elif emotion == "boredom":
             self.logger.info("Selected Agent: PlannerAgent (Boredom)")
             return planner_agent.generate_plan(mood, intensity, user_id)

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
             return planner_agent.generate_plan(mood, intensity, user_id)

router_agent = RouterAgent()
