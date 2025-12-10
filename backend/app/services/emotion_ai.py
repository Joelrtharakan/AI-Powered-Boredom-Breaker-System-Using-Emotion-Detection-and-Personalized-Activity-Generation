from transformers import pipeline
import logging

class EmotionAnalyzer:
    def __init__(self):
        self.classifier = None
        self.logger = logging.getLogger(__name__)

    def load_model(self):
        if not self.classifier:
            self.logger.info("Loading Emotion Model...")
            # This will download the model (~500MB) on first run
            self.classifier = pipeline(
                "text-classification", 
                model="cardiffnlp/twitter-roberta-base-emotion", 
                return_all_scores=True
            )
            self.logger.info("Emotion Model loaded.")

    def analyze(self, text: str):
        # 0. Garbage / Key-smash Check
        if len(text) > 8 and " " not in text:
             # Likely random string like "asdfghjkl"
             return {
                 "mood": "low_energy",
                 "emotion": "neutral",
                 "intensity": 0.0,
                 "all_scores": []
             }

        # 1. Model Classification
        self.load_model()
        results = self.classifier(text)[0]
        top_result = max(results, key=lambda x: x['score'])
        
        emotion = top_result['label']
        score = top_result['score']
        
        # 2. Default Mapping & Low Confidence Handling
        
        confidence_threshold = 0.65 # Base threshold

        # Stricter for short text
        if len(text) < 30: 
             confidence_threshold = 0.85

        # Anti-Bias: The model over-predicts 'joy'/'optimism' for neutral text.
        if emotion in ["joy", "optimism"]:
             positive_keywords = [
                 "happy", "good", "great", "love", "fun", "best", "amazing", "lovely", 
                 "win", "winner", "excited", "lol", "lmao", "funny", "nice", "cool", 
                 "wonderful", "perfect", "better", "hope", "optimist", "glad", "enjoy"
             ]
             if not any(pw in text.lower() for pw in positive_keywords):
                 # No obvious positive words? Require EXTREME confidence (0.92) to avoid false positives like "Screenshot taken..."
                 confidence_threshold = max(confidence_threshold, 0.92)

        if score < confidence_threshold:
            # If the model is unsure (e.g., random numbers, ambiguous text), default to neutral/boredom
            mood = "low_energy"
            emotion = "neutral"
        else:
            mood_map = {
                "joy": "happy",
                "optimism": "happy",
                "anger": "stressed",
                "sadness": "sad",
                "fear": "anxious"
            }
            mood = mood_map.get(emotion, "neutral")

        # 3. Rule-based Overrides & Safety Checks
        text_lower = text.lower()
        
        # Critical Safety
        distress_signals = [
            "done with life", "done with everything", "done with this life", 
            "can't take it", "cant take it", "can't take this", "cant take this",
            "give up", "suicid", "end it all", "ending it all", 
            "want to die", "kill myself", "end my life"
        ]
        if any(ds in text_lower for ds in distress_signals):
             emotion = "sadness"
             mood = "sad"
             score = 0.99
        # Boredom / Low Energy
        elif "bored" in text_lower or "nothing to do" in text_lower or "dull" in text_lower or "mid" in text_lower or "meh" in text_lower:
            emotion = "boredom"
            mood = "low_energy"
            score = max(score, 0.85) 
        # Exhaustion
        elif "tired" in text_lower or "exhausted" in text_lower or "drained" in text_lower or "cooked" in text_lower or "social battery" in text_lower:
            emotion = "exhaustion"
            mood = "low_energy"
            score = max(score, 0.9)
        # Anxiety
        elif "anxious" in text_lower or "worried" in text_lower or "nervous" in text_lower or "stress" in text_lower or "spiraling" in text_lower:
            emotion = "fear"
            mood = "anxious"
        # Frustration/Anger
        elif "frustrat" in text_lower or "annoy" in text_lower or "hate" in text_lower or "crash out" in text_lower:
             emotion = "anger"
             mood = "stressed"
             score = max(score, 0.85)
        # Optimism correction
        elif "hope" in text_lower or "hoping" in text_lower or "no cap" in text_lower or "clutch" in text_lower:
             emotion = "optimism"
             mood = "happy"
             score = max(score, 0.85)

        return {
            "mood": mood,
            "emotion": emotion,
            "intensity": score,
            "all_scores": results
        }

emotion_analyzer = EmotionAnalyzer()
