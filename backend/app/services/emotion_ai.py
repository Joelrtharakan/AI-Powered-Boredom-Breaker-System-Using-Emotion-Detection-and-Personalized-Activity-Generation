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
        
        # map generic result to app specific valid moods if needed, 
        # but for now return as is.
        return {
            "mood": top_result['label'], # 'joy', 'optimism', 'anger', 'sadness'
            "emotion": top_result['label'],
            "intensity": top_result['score'],
            "all_scores": results
        }

emotion_analyzer = EmotionAnalyzer()
