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
            return await self._route_logic(mood_data, user_id, interests, text)
        except Exception as e:
            self.logger.error(f"Router Core Error: {e}")
            # Even in catastrophic failure, try to give them at least the fallback plan
            return await self._get_fallback_plan(mood_data, user_id, interests, text)

    async def _route_logic(self, mood_data: dict, user_id: int, interests: list = None, text: str = ""):
        mood = mood_data.get("mood", "neutral")
        emotion = mood_data.get("emotion", "neutral")
        intensity = mood_data.get("intensity", 0.5)
        
        # 1. Imports
        from app.services.game_intelligence import game_intelligence_service
        from app.services.history_service import history_service
        from app.services.semantic_intent_service import semantic_intent_service
        
        # 2. State Synthesis
        intent = semantic_intent_service.detect_intent(text or "")
        history_analysis = history_service.analyze_trajectory(user_id)
        
        state = {
            "mood": mood,
            "emotion": emotion,
            "intensity": intensity,
            "energy_level": mood_data.get("energy_level", "medium"),
            "risk_level": mood_data.get("risk_level", "low"),
            "user_intent": mood_data.get("user_intent", intent),
            "trajectory_state": mood_data.get("trajectory_state", 
                                             "declining" if history_analysis.get("burnout_risk") else "stable")
        }
        
        # 3. Decision Integration
        intervention_data = await game_intelligence_service.decide_intervention(state, user_id)
        print(f"DEBUG: Smart Intervention Decided: {intervention_data.get('type')} - {intervention_data.get('reason')}")
        
        # 4. Multi-step Plan Generation (Psychological Arc)
        try:
            plan = await planner_agent.generate_plan(
                mood=mood, intensity=intensity, user_id=user_id, 
                interests=interests, text=text, risk_level=state["risk_level"]
            )
            
            # Always ensure our smart intervention is the absolute priority (Step 1)
            if plan and isinstance(plan, list):
                # If the AI suggested a game as well, remove its generic version
                plan = [p for p in plan if p.get('type') != 'game']
                plan.insert(0, intervention_data)
                return plan
        except Exception as e:
            self.logger.error(f"Agentic Planner failed: {e}. Using intelligent fallback.")

        # FINAL FALLBACK (Preserves the intelligent game detection)
        return [
            intervention_data,
            {"type": "music", "description": "Intelligent Fallback Active: Relax with some focus music.", "time_minutes": 10, "purpose": "regulation"}
        ]

    async def _get_fallback_plan(self, mood_data, user_id, interests, text):
        return await planner_agent.generate_plan("neutral", 0.5, user_id, interests, text=text)

router_agent = RouterAgent()
