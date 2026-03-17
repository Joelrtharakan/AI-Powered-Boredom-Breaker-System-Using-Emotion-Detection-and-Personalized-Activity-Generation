import logging
from collections import deque
from datetime import datetime

class HistoryService:
    """Tracks emotional trajectories over time to detect trends like burnout or recovery."""
    def __init__(self, window_size: int = 10):
        self.logger = logging.getLogger(__name__)
        # In memory storage (should be persisted in DB for production)
        self.user_trajectories = {} 
        self.window_size = window_size

    def add_event(self, user_id: int, emotion: str, risk_level: str, intensity: float):
        if user_id not in self.user_trajectories:
            self.user_trajectories[user_id] = deque(maxlen=self.window_size)
        
        event = {
            "timestamp": datetime.now(),
            "emotion": emotion,
            "risk_level": risk_level,
            "intensity": intensity
        }
        self.user_trajectories[user_id].append(event)
        self.logger.info(f"Added temporal event for User {user_id}: {emotion} ({risk_level})")

    def predict_future_state(self, user_id: int) -> dict:
        """Predicts future emotional state using simple sequence parsing."""
        history = list(self.user_trajectories.get(user_id, []))
        if len(history) < 3:
            return {"predicted_trend": "variable", "burnout_probability": 0.1}
            
        # Linear regression on intensities (simplistic projection)
        intensities = [e['intensity'] for e in history]
        x = list(range(len(intensities)))
        slope, intercept = np.polyfit(x, intensities, 1) if len(x) > 1 else (0, 0)
        
        predicted_intensity = intensities[-1] + slope
        
        # Burnout Prediction Logic
        recent_stress = [1 for e in history[-3:] if e['emotion'] in ["sadness", "fear", "anger"] and e['intensity'] > 0.6]
        burnout_prob = sum(recent_stress) / 3.0
        
        prediction = "stable"
        if predicted_intensity > 0.8:
            prediction = "escalating_distress"
        elif predicted_intensity < 0.4:
            prediction = "recovery_path"
            
        return {
            "predicted_trend": prediction,
            "burnout_probability": burnout_prob,
            "projected_intensity": float(predicted_intensity)
        }

    def analyze_trajectory(self, user_id: int) -> dict:
        """Analyzes recent history to identify emotional trends."""
        history = self.user_trajectories.get(user_id, [])
        if not history or len(history) < 3:
            return {"trend": "stable", "burnout_risk": False, "recovery_sign": False}

        # 1. Burnout Detection (Persistent high-intensity negative emotions)
        neg_emotions = ["sadness", "fear", "anger", "fatigued"]
        recent_neg = [e for e in list(history)[-5:] if e['emotion'] in neg_emotions and e['intensity'] > 0.7]
        
        burnout_risk = len(recent_neg) >= 3

        # 2. Recovery Detection (Moving from high distress to neutral/joy)
        was_distressed = any(e['risk_level'] in ["HIGH_DISTRESS", "CRISIS"] for e in list(history)[:-2])
        is_improving = history[-1]['risk_level'] in ["LOW_NORMAL"] and history[-1]['emotion'] in ["joy", "neutral"]
        
        recovery_sign = was_distressed and is_improving

        # 3. Intensity Trend
        intensities = [e['intensity'] for e in history]
        if intensities[-1] > intensities[0] + 0.2:
            trend = "escalating"
        elif intensities[-1] < intensities[0] - 0.2:
            trend = "de-escalating"
        else:
            trend = "stable"
        
        future = self.predict_future_state(user_id)

        return {
            "trend": trend,
            "burnout_risk": burnout_risk,
            "recovery_sign": recovery_sign,
            "future_prediction": future,
            "event_count": len(history)
        }

history_service = HistoryService()
