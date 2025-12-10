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
        self.load_model()
        results = self.classifier(text)[0]
        # results is a list of {'label': 'joy', 'score': 0.9}
        # find max score
        top_result = max(results, key=lambda x: x['score'])
        
        emotion = top_result['label']
        score = top_result['score']
        
        # Default mapping
        mood_map = {
            "joy": "happy",
            "optimism": "happy",
            "anger": "stressed",
            "sadness": "sad"
        }
        
        mood = mood_map.get(emotion, "neutral")
        
        # Rule-based overrides for interactions not covered by this specific model
        text_lower = text.lower()
        if "bored" in text_lower or "nothing to do" in text_lower or "dull" in text_lower:
            emotion = "boredom"
            mood = "low_energy"
            # Boost score if model was uncertain or classified as sadness
            score = max(score, 0.85) 
        elif "tired" in text_lower or "exhausted" in text_lower or "drained" in text_lower:
            emotion = "exhaustion"
            mood = "low_energy"
        elif "anxious" in text_lower or "worried" in text_lower or "nervous" in text_lower:
            emotion = "fear"
            mood = "anxious"
        elif "frustrat" in text_lower or "annoy" in text_lower or "hate" in text_lower:
             emotion = "anger"
             mood = "stressed"
             score = max(score, 0.85)
        elif "hope" in text_lower or "hoping" in text_lower:
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
