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
        try:
            mood = mood_data.get("mood", "neutral")
            emotion = mood_data.get("emotion", "neutral")
            intensity = mood_data.get("intensity", 0.5)
            
            # 1. NO EMOTION -> Planner (Prompt user)
            if mood_data.get("decision_source") == "no_emotion_detected":
                 return await planner_agent.generate_plan(mood, intensity, user_id, interests, text=text, risk_level="NO_EMOTION")

            # 2. Intelligence Integration
            from app.services.game_intelligence import game_intelligence_service
            from app.services.history_service import history_service
            from app.services.semantic_intent_service import semantic_intent_service
            
            # Context synthesis
            intent = semantic_intent_service.detect_intent(text or "")
            history_analysis = history_service.analyze_trajectory(user_id)
            
            state = {
                "mood": mood,
                "emotion": emotion,
                "intensity": intensity,
                "emotion_intensity": intensity,
                "energy_level": mood_data.get("energy_level", "medium"),
                "risk_level": mood_data.get("risk_level", "low"),
                "user_intent": mood_data.get("user_intent", intent),
                "trajectory_state": mood_data.get("trajectory_state", 
                                                 "declining" if history_analysis.get("burnout_risk") else "stable")
            }
            
            # Log event to history
            history_service.add_event(user_id, emotion, state["risk_level"], intensity)

            # 3. Path Routing
            # CRISIS priority bypass
            if state["risk_level"] == "CRISIS":
                 return await planner_agent.generate_plan(f"{mood}", intensity, user_id, interests, text=text, risk_level="CRISIS")

            # Get structured intervention from Intelligence Service
            intervention_data = await game_intelligence_service.decide_intervention(state, user_id)
            
            # 4. Multi-step Plan Generation (Psychological Arc)
            plan = await planner_agent.generate_plan(
                mood=mood, 
                intensity=intensity, 
                user_id=user_id, 
                interests=interests, 
                text=text,
                risk_level=state["risk_level"]
            )
            
            # Inject the structured intervention into the plan for the mobile UI
            if plan and isinstance(plan, list):
                # Ensure plan[0] is a dict before updating
                if len(plan) > 0 and isinstance(plan[0], dict):
                    plan[0].update(intervention_data)
                else:
                    plan.insert(0, intervention_data)
            else:
                plan = [intervention_data]
                
            return plan
        except Exception as e:
            self.logger.error(f"Error in _route_logic: {e}", exc_info=True)
            # Re-raise to let route() handle it with fallback
            raise

    async def _get_fallback_plan(self, mood_data, user_id, interests, text):
        return await planner_agent.generate_plan("neutral", 0.5, user_id, interests, text=text)

router_agent = RouterAgent()
