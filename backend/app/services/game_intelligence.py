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
            return self._format_game_selection(state, "intent_override")

        # 3. BOREDOM PRIORITY RULE (REDESIGN APPROACH: 100% Guaranteed)
        if emotion == "boredom":
            return self._format_game_selection(state, "redesign_boredom_priority")

        # 4. EXPLORATION AND SCORING
        # High base score for neutral+boredom triggers more often
        game_score = self.calculate_game_score(state)
        
        # Reduced trigger threshold from 0.8 to 0.6 to align with redesign aggressiveness
        if game_score > 0.6:
            return self._format_game_selection(state, "high_score_trigger")

        # 5. Fallback to Bandit
        action = bandit_service.select_action(user_id, emotion, energy_level, trajectory)
        if action == "game":
            return self._format_game_selection(state, "bandit_selection")
            
        return self._format_intervention(action, "standard_selection")

    def _format_game_selection(self, state: Dict[str, Any], reason: str) -> Dict[str, Any]:
        """Deeply maps emotion + energy + text to specific game categories."""
        emotion = state.get("emotion", "neutral")
        energy_level = state.get("energy_level", "medium")
        text = (state.get("text") or "").lower()
        
        # 1. TEXT DIRECT OVERRIDE (If they asked for a specific game)
        if "snake" in text:
            game_name, game_id, description = ("Snake Evolution", "snake", "Time for some high-speed action with Snake!")
        elif "memory" in text:
            game_name, game_id, description = ("Memory Flip", "memory", "Exercise your brain with Memory Flip.")
        elif "tic tac toe" in text:
            game_name, game_id, description = ("Tic Tac Toe", "tic_tac_toe", "Keep it classic with a game of Tic Tac Toe.")
        
        # 2. EMOTION-BASED CATEGORIZATION
        else:
            # CATEGORY A: High Engagement/Dopamine (Best for Boredom/Neutral)
            high_engagement = [
                ("Snake Evolution", "snake", "Get into the flow and beat your high score in Snake!"),
                ("Reaction Time", "reaction", "Wake up your brain with a quick reflex check!"),
                ("Aim Trainer", "aim", "Sharp focus required—can you hit every target?")
            ]
            
            # CATEGORY B: Low Friction/Grounding (Best for Stress/Anxiety/Anger)
            grounding_logic = [
                ("Memory Flip", "memory", "Focus on the patterns to clear your mind."),
                ("Tic Tac Toe", "tic_tac_toe", "A simple challenge to reset your thoughts."),
                ("Chimp Test", "chimp", "Test your short-term memory and find your center.")
            ]

            # REFINED MAPPING (Nervous System Alignment)
            if emotion in ["boredom", "joy", "neutral"] and energy_level in ["medium", "high"]:
                game_name, game_id, description = random.choice(high_engagement)
            elif emotion in ["stress", "anxiety", "fatigue", "anger", "fear", "sadness"]:
                game_name, game_id, description = random.choice(grounding_logic)
            else:
                # Default safety mix
                game_name, game_id, description = random.choice(grounding_logic)
            
        return {
            "type": "game",
            "description": description,
            "game_id": game_id,
            "reason": reason,
            "confidence": 0.95,
            "metadata": {
                "game_name": game_name,
                "energy_category": energy_level,
                "emotion_match": emotion
            }
        }

    def _format_intervention(self, action: str, reason: str) -> Dict[str, Any]:
        display_names = {
            "breathing": "Breathing", "music": "Music", "journaling": "Journaling",
            "chat": "Chat", "affirmation": "Affirmation"
        }
        name = display_names.get(action, action.capitalize())
        return {
            "type": "intervention",
            "description": f"How about some {name} to help you reset?",
            "intervention": action,
            "reason": reason,
            "confidence": 0.85,
            "metadata": {}
        }

game_intelligence_service = GameIntelligenceService()
