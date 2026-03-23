import random
import logging
import numpy as np

class RecommendationBandit:
    """Thompson Sampling based Contextual Bandit for personalized interventions."""
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        # user_id -> {context -> {action -> [alphas, betas]}}
        # Context is a tuple of (emotion_group, time_slot, energy_level, trajectory_state)
        self.user_stats = {}
        self.actions = [
            "game", "breathing", "music", "journaling", "chat", "affirmation"
        ]
        self.epsilon = 0.2 # Stable exploration from redesign

    def _get_context_key(self, emotion, energy_level="medium", trajectory_state="stable"):
        """Discretizes features into a context key."""
        from datetime import datetime
        hour = datetime.now().hour
        
        # Time Slots: Morning (6-12), Afternoon (12-18), Evening (18-24), Night (0-6)
        time_slot = "morning" if 6 <= hour < 12 else ("afternoon" if 12 <= hour < 18 else ("evening" if 18 <= hour < 24 else "night"))
        
        # Emotion Groups
        emotion_map = {
            "sadness": "negative_low", "fatigue": "negative_low", "bored": "negative_low", "boredom": "negative_low",
            "fear": "negative_high", "anger": "negative_high", "stressed": "negative_high", "anxious": "negative_high",
            "joy": "positive", "neutral": "neutral"
        }
        emo_group = emotion_map.get(emotion, "neutral")
        energy = energy_level or "medium"
        trajectory = trajectory_state or "stable"
        
        return (emo_group, time_slot, energy, trajectory)

    def _get_user_params(self, user_id, context_key):
        if user_id not in self.user_stats:
            self.user_stats[user_id] = {}
        if context_key not in self.user_stats[user_id]:
            self.user_stats[user_id][context_key] = {action: [1, 1] for action in self.actions}
        return self.user_stats[user_id][context_key]

    def select_action(self, user_id, emotion, energy_level="medium", trajectory_state="stable", allowed_actions=None):
        """Selects the best intervention based on contextual past performance with exploration."""
        # 1. Epsilon-Greedy Exploration (20%)
        if random.random() < self.epsilon:
            action = random.choice(allowed_actions or self.actions)
            self.logger.info(f"Bandit EXPLORING: {action}")
            return action

        context_key = self._get_context_key(emotion, energy_level, trajectory_state)
        params = self._get_user_params(user_id, context_key)
        
        # Filter params by allowed_actions if provided
        action_candidates = params
        if allowed_actions:
            action_candidates = {a: params[a] for a in allowed_actions if a in params}
        
        if not action_candidates:
            action_candidates = params # Fallback to all if filtering empty
            
        # Thompson Sampling
        samples = {action: np.random.beta(a, b) for action, (a, b) in action_candidates.items()}
        
        # Exploit the best sampled action
        best_action = max(samples, key=samples.get)
        self.logger.info(f"Bandit EXPLOITING: {best_action} for context {context_key}")
            
        return best_action

    def update(self, user_id, emotion, energy_level, trajectory_state, action, engagement_score, mood_improvement):
        """Updates the bandit using a combined reward of engagement and mood improvement."""
        # reward = (engagement_score * 0.6 + mood_improvement * 0.4)
        reward = (engagement_score * 0.6) + (mood_improvement * 0.4)
        
        context_key = self._get_context_key(emotion, energy_level, trajectory_state)
        params = self._get_user_params(user_id, context_key)
        
        if action in params:
            # Shift reward to alpha/beta updates (reward 0-1)
            # We use a threshold of 0.7 for a 'success' in this specific implementation
            if reward > 0.7:
                params[action][0] += 1
            elif reward < 0.3:
                params[action][1] += 1
            # Intermediate rewards can be handled by fractional updates if using a different distribution,
            # but for Beta we stay with successes/failures.
            
            self.logger.info(f"Updated Bandit (User {user_id}, Context {context_key}): {action} -> reward {reward}")

bandit_service = RecommendationBandit()
