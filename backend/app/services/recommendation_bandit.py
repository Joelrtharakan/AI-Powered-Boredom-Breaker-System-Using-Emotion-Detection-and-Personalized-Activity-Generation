import random
import logging
import numpy as np

class RecommendationBandit:
    """Simple Epsilon-Greedy / Thompson Sampling hybrid for personalized interventions."""
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        # user_id -> {context -> {action -> [alphas, betas]}}
        # Context is a tuple of (emotion_group, time_slot, energy_level)
        self.user_stats = {}
        self.actions = ["breathing", "game", "music", "journal", "affirmation", "micro_task"]

    def _get_context_key(self, emotion, energy_level=None):
        """Discretizes features into a context key."""
        from datetime import datetime
        hour = datetime.now().hour
        
        # Time Slots: Morning (6-12), Afternoon (12-18), Evening (18-24), Night (0-6)
        time_slot = "morning" if 6 <= hour < 12 else ("afternoon" if 12 <= hour < 18 else ("evening" if 18 <= hour < 24 else "night"))
        
        # Emotion Groups
        emotion_map = {
            "sadness": "negative_low", "fatigue": "negative_low", "bored": "negative_low",
            "fear": "negative_high", "anger": "negative_high",
            "joy": "positive", "neutral": "neutral"
        }
        emo_group = emotion_map.get(emotion, "neutral")
        energy = energy_level or "medium"
        
        return (emo_group, time_slot, energy)

    def _get_user_params(self, user_id, context_key):
        if user_id not in self.user_stats:
            self.user_stats[user_id] = {}
        if context_key not in self.user_stats[user_id]:
            self.user_stats[user_id][context_key] = {action: [1, 1] for action in self.actions}
        return self.user_stats[user_id][context_key]

    def select_action(self, user_id, emotion, energy_level="medium"):
        """Selects the best intervention based on contextual past performance."""
        context_key = self._get_context_key(emotion, energy_level)
        params = self._get_user_params(user_id, context_key)
        
        # Thompson Sampling
        samples = {action: np.random.beta(a, b) for action, (a, b) in params.items()}
        
        # Exploit the best sampled action
        best_action = max(samples, key=samples.get)
        
        # Heuristic Overrides (Safety/Logic)
        if emotion in ["fear", "anxious"] and random.random() < 0.2:
            return "breathing"
        if energy_level == "low" and best_action == "game" and random.random() < 0.5:
            return "micro_task" # Switch to low energy task
            
        return best_action

    def update(self, user_id, emotion, energy_level, action, reward):
        """Updates the bandit for a specific user-context pair."""
        context_key = self._get_context_key(emotion, energy_level)
        params = self._get_user_params(user_id, context_key)
        
        if action in params:
            if reward > 0.5:
                params[action][0] += 1
            else:
                params[action][1] += 1
            self.logger.info(f"Updated Bandit (User {user_id}, Context {context_key}): {action} -> reward {reward}")

bandit_service = RecommendationBandit()
