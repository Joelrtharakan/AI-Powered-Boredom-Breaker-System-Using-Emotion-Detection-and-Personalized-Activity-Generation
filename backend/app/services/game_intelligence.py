import logging
import random
from typing import Dict, Any
from app.services.recommendation_bandit import bandit_service

class GameIntelligenceService:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def is_game_allowed(self, state: Dict[str, Any]) -> bool:
        """Determines if a game is safe to suggest (Hard Blocks only)."""
        emotion = state.get("emotion", "neutral")
        risk_level = state.get("risk_level", "low")
        
        # Hard Blocks
        if risk_level == "high":
            return False
        if emotion in ["severe_stress", "distress", "burnout"]:
            return False
        return True

    def calculate_game_score(self, state: Dict[str, Any]) -> float:
        """Boost game score based on boredom and intent."""
        emotion = state.get("emotion", "neutral")
        energy_level = state.get("energy_level", "medium")
        user_intent = state.get("user_intent", "unknown")
        
        score = 0.0
        if emotion == "boredom":
            score += 1.0
        if energy_level == "medium":
            score += 0.5
        if energy_level == "high":
            score += 0.7
        if user_intent == "game_request":
            score += 2.0
        if emotion == "fatigue":
            score -= 0.5
        if emotion in ["stress", "anxiety"]:
            score -= 0.3
            
        return score

    async def decide_intervention(self, state: Dict[str, Any], user_id: int) -> Dict[str, Any]:
        """Main decision flow with increased engagement probability."""
        emotion = state.get("emotion", "neutral")
        energy_level = state.get("energy_level", "medium")
        risk_level = state.get("risk_level", "low")
        user_intent = state.get("user_intent", "unknown")
        trajectory = state.get("trajectory_state", "stable")

        # 1. HARD BLOCK CHECK
        if not self.is_game_allowed(state):
            action = bandit_service.select_action(user_id, emotion, energy_level, trajectory, 
                                                 allowed_actions=["breathing", "music", "journaling", "chat"])
            return self._format_intervention(action, "safety_block")

        # 2. INTENT OVERRIDE
        if user_intent == "game_request" and risk_level == "low":
            return self._format_game_selection(energy_level, "intent_override")

        # 3. BOREDOM PRIORITY RULE (50% Chance)
        if emotion == "boredom" and energy_level in ["medium", "high"]:
            if random.random() < 0.5:
                return self._format_game_selection(energy_level, "boredom_priority")

        # 4. EXPLORATION AND SCORING
        # Exploration (30%) is handled inside bandit_service.select_action now
        
        game_score = self.calculate_game_score(state)
        
        # If score is very high, force game
        if game_score > 0.8:
            return self._format_game_selection(energy_level, "high_score_trigger")

        # 5. Fallback to Bandit
        action = bandit_service.select_action(user_id, emotion, energy_level, trajectory)
        if action == "game":
            return self._format_game_selection(energy_level, "bandit_selection")
            
        return self._format_intervention(action, "standard_selection")

    def _format_game_selection(self, energy_level: str, reason: str) -> Dict[str, Any]:
        """Maps Energy to Game Types for safe execution."""
        if energy_level == "high":
            game_id = random.choice(["snake", "reaction", "aim"])
        else: # medium or low
            game_id = random.choice(["memory", "tic_tac_toe", "chimp"])
            
        return {
            "type": "game", # Changed from 'intervention' to 'game' per user request
            "game_id": game_id,
            "reason": reason,
            "confidence": 0.85
        }

    def _format_intervention(self, action: str, reason: str) -> Dict[str, Any]:
        display_names = {
            "breathing": "Breathing", "music": "Music", "journaling": "Journaling",
            "chat": "Chat", "affirmation": "Affirmation"
        }
        name = display_names.get(action, action.capitalize())
        return {
            "type": "intervention",
            "intervention": action,
            "reason": reason,
            "description": f"Suggested intervention: {name}",
            "confidence": 0.85
        }

game_intelligence_service = GameIntelligenceService()
