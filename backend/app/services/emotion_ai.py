from transformers import pipeline
import logging
import os

class EmotionAnalyzer:
    def __init__(self):
        self.classifier = None
        self.logger = logging.getLogger(__name__)

    def load_model(self):
        if not self.classifier:
            self.logger.info("Loading Emotion Model...")
            
            # Try loading fine-tuned model first
            fine_tuned_path = "models/fine_tuned_roberta"
            base_model = "cardiffnlp/twitter-roberta-base-emotion"
            
            model_to_use = base_model
            if os.path.exists(fine_tuned_path) and os.path.exists(os.path.join(fine_tuned_path, "config.json")):
                 self.logger.info(f"✨ Found Fine-Tuned Model at {fine_tuned_path}. Loading...")
                 model_to_use = fine_tuned_path
            else:
                 self.logger.info(f"Using Base Model: {base_model}")

            try:
                self.classifier = pipeline(
                    "text-classification", 
                    model=model_to_use, 
                    top_k=None
                )
                self.logger.info(f"Emotion Model ({model_to_use}) loaded successfully.")
            except Exception as e:
                self.logger.error(f"Failed to load model {model_to_use}: {e}")
                # Fallback to base
                if model_to_use != base_model:
                     self.logger.info("Falling back to base model...")
                     self.classifier = pipeline(
                        "text-classification", 
                        model=base_model, 
                        top_k=None
                    )

    def analyze(self, text: str):
        # 0. Garbage / Key-smash Check
        if len(text) > 8 and " " not in text:
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
        
        # 2. Logic & Mapping
        # Unified Map for both Base and Fine-Tuned Labels
        mood_map = {
            # Base Model Labels (remapped for fine-tuned context)
            "joy": "happy",
            "optimism": "happy",
            "anger": "stressed",
            "sadness": "sad",
            "fear": "anxious",
            "love": "happy",
            "surprise": "neutral", # Triggers Surprise Agent
            
            # Fine-Tuned Labels (Synthetic)
            "low_energy_bored": "low_energy",
            "restless_bored": "restless",
            "stressed": "stressed",
            "anxious": "anxious",
            "overthinking": "anxious",
            "emotionally_flat": "low_energy",
            "calm": "calm",
            "focused": "focused",
            "positive_engaged": "happy",
            "neutral": "neutral"
        }
        
        mood = mood_map.get(emotion, "neutral")

        # 3. Rule-based Overrides & Safety Checks (Still valuable even with fine-tuning)
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
        
        if "bouncing off the walls" in text_lower or "cant sit still" in text_lower or "can't sit still" in text_lower:
             emotion = "restless_bored"
             mood = "restless"
             score = 0.95
        
        # Retain fallback rules if confidence is low AND using base model mapping
        # But if using fine-tuned labels, trust them more unless very low confidence
        if score < 0.6 or emotion in ["neutral", "happy", "joy", "love"]:
             if "bored" in text_lower:
                  mood = "low_energy"
                  emotion = "boredom"
             
             # Fatigue / Drained Check
             elif any(w in text_lower for w in ["tired", "drained", "exhausted", "fatigued", "burnout", "burnt out", "sleepy"]):
                  mood = "low_energy"
                  emotion = "exhaustion"
                  score = 0.85 # Artificial confidence boost for rule-based match

        return {
            "mood": mood,
            "emotion": emotion,
            "intensity": score,
            "all_scores": results
        }

emotion_analyzer = EmotionAnalyzer()
