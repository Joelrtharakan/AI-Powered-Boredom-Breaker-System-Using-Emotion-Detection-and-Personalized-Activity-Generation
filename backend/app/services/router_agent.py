import logging
import asyncio
from app.services.planner_agent import planner_agent
from app.services.microtask_agent import microtask_agent
from app.services.surprise_agent import surprise_agent

class RouterAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    async def route(self, mood_data: dict, user_id: int, interests: list = None, text: str = ""):
        """Entry point for routing user requests based on processed mood data."""
        try:
            items = await self._route_logic(mood_data, user_id, interests, text)
            return items if items else await self._get_fallback_plan(mood_data, user_id, interests, text)
        except Exception as e:
            self.logger.error(f"Router Exception: {e}")
            return await planner_agent.generate_plan("neutral", 0.5, user_id, interests, text=text)

    async def _route_logic(self, mood_data: dict, user_id: int, interests: list = None, text: str = ""):
        mood = mood_data.get("mood", "neutral")
        emotion = mood_data.get("emotion", "neutral")
        intensity = mood_data.get("intensity", 0.5)
        source = mood_data.get("decision_source", "")
        
        # 1. NO EMOTION -> Planner (Prompt user)
        if source == "no_emotion_detected":
             return await planner_agent.generate_plan(mood, intensity, user_id, interests, text=text, risk_level="NO_EMOTION")

        # 2. Semantic & Temporal Intelligence
        from app.services.semantic_intent_service import semantic_intent_service
        from app.services.history_service import history_service
        
        intent = semantic_intent_service.detect_intent(text)
        history_analysis = history_service.analyze_trajectory(user_id)
        
        is_fatigued = intent == "fatigue" or history_analysis.get("burnout_risk", False)
        is_bored = intent == "game" or emotion == "boredom"
        
        # Log event to history for future temporal analysis
        history_service.add_event(user_id, emotion, mood_data.get("risk_level", "LOW_NORMAL"), intensity)

        # 3. Path Routing based on Risk & Emotion
        detected_risk = mood_data.get("risk_level", "LOW_NORMAL")
        
        # CRISIS always goes to Planner
        if detected_risk == "CRISIS":
             return await planner_agent.generate_plan(f"{mood}", intensity, user_id, interests, text=text, risk_level="CRISIS")

        # Negative Emotions -> Planner Agent
        if emotion in ["sadness", "anger", "fear", "exhaustion", "stressed", "anxious", "sad"] or is_fatigued:
             risk = "FATIGUE" if is_fatigued else detected_risk
             if risk == "LOW_NORMAL": risk = "MODERATE_DISTRESS" # Default escalation for negative emotions
             return await planner_agent.generate_plan(f"{mood}", intensity, user_id, interests, text=text, risk_level=risk)

        # 4. Boredom -> Planner Agent (Game Injection)
        elif emotion == "boredom" or is_bored:
             return await planner_agent.generate_plan(mood, intensity, user_id, interests, text=text, risk_level="BOREDOM")

        # 5. Neutral -> Surprise Agent (Spark Joy + Grounding)
        elif emotion == "neutral":
             surprise = await surprise_agent.generate()
             return [
                 {"type": "breathing", "description": "Take one slow, deep breath to center yourself.", "time_minutes": 1, "purpose": "grounding"},
                 {"type": "surprise", "description": surprise['surprise'], "time_minutes": 1, "purpose": "spark_joy"}
             ]

        # 6. Default (Happy/Optimism) -> Planner
        return await planner_agent.generate_plan(mood, intensity, user_id, interests, text=text, risk_level="LOW_NORMAL")

    async def _get_fallback_plan(self, mood_data, user_id, interests, text):
        return await planner_agent.generate_plan("neutral", 0.5, user_id, interests, text=text)

router_agent = RouterAgent()
