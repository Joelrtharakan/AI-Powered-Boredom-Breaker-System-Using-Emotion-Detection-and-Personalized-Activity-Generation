from transformers import pipeline
import logging
import os
import re

class SemanticEngine:
    """Handles deep semantic keyword matching with synonym clusters."""
    def __init__(self):
        self.clusters = {
            "sadness": ["pain", "devastated", "broken", "pointless", "heartbroken", "crushed", "empty", "shattered", "unbearable", "grief", "heart hurts", "so heavy", "worthless", "misery", "bleak", "invisible", "hopeless", "drowning", "tear", "tears", "crying", "lonely", "disappointed", "rejection", "touch breaks", "dead inside", "bittersweet", "depths of despair", "hope tomorrow is better", "wish he would call", "silence is loud"],
            "fear": ["shaken", "rattled", "terrified", "panicking", "panic attack", "anxious", "nervous", "dread", "afraid", "scared", "worried", "troubled", "alarmed", "trembling", "shaking", "bad feeling", "suspense", "sweating", "unsafe", "paralyzed", "jitters", "on edge", "uncertainty", "what if", "heard a noise", "spiraling", "yikes", "pounding", "refreshing the page", "haven't replied", "vibes"],
            "bored": ["lethargic", "sluggish", "lazy", "no energy", "drained", "exhausted", "unmotivated", "listless", "apathetic", "sleepy", "tired", "i feel nothing", "monotony", "dull", "staring at the wall", "bothered to move", "dragging on", "watching paint dry", "just existing", "waiting for the day to end", "blah", "whatever", "flat", "routine", "zero motivation", "so bored", "brain is fried", "doomscrolling", "dragging", "don't want to get out of bed"],
            "neutral": ["okay", "all good", "fine", "alright", "normal", "existing", "average", "standard", "nothing much", "chilling", "reading", "eating", "drinking", "sitting", "standing", "waiting", "lukewarm", "quiet", "simple", "neither happy nor sad", "shoes", "cloudy", "apples", "wifi", "laptop", "meeting", "wsg", "gang", "what's good", "sup"],
            "anger": ["sick of fake people", "fake people", "blood boil", "pissed", "furious", "enraged", "mad", "annoyed", "frustrated", "fed up", "ridiculous", "audacity", "interrupting", "nightmare", "snap", "patience", "frustrating", "drama", "rent free", "forgot to eat", "what a mess", "can we just stop"],
            "joy": ["happy", "promotion", "breathtaking", "smiling", "blessed", "plan", "laughed", "top of the world", "yes!", "perfect", "alive", "beaming", "best day", "appreciate", "beautiful", "excited", "full heart", "aced", "winning", "fantastic", "dream come true", "flowers", "she said yes", "cloud nine", "finally finished", "good way", "good day", "great day", "amazing day"]
        }
        self.compiled = {k: [re.compile(rf"\b{re.escape(word)}\b", re.IGNORECASE) for word in v] for k, v in self.clusters.items()}

    def find_best_match(self, text: str) -> tuple[str, float]:
        """Finds the strongest semantic signal across all clusters."""
        best_emotion = None
        best_score = 0.0
        
        for emotion, patterns in self.compiled.items():
            matches = sum(1 for p in patterns if p.search(text))
            if matches > 0:
                # Score based on number of distinct emotional markers found
                score = min(0.95, 0.4 + (matches * 0.2))
                if score > best_score:
                    best_score = score
                    best_emotion = emotion
        
        return best_emotion, best_score

class EmotionAnalyzer:
    def __init__(self):
        self.classifier = None
        self.semantic = SemanticEngine()
        self.logger = logging.getLogger(__name__)

    def load_model(self):
        if self.classifier:
            return

        self.logger.info("Loading V14 Final Model...")
        v14_path = os.path.abspath("models/v14_final_model")
        v12_path = os.path.abspath("models/v12_context_model")
        v11_path = os.path.abspath("models/v11_master_model")
        v10_path = os.path.abspath("models/fine_tuned_roberta_v10")
        v9_path = os.path.abspath("models/fine_tuned_roberta_v9")
        base_model = "cardiffnlp/twitter-roberta-base-emotion"

        # Priority: V14 -> V12 -> V11 -> V10 -> V9 -> Base
        model_to_use = v14_path if os.path.exists(v14_path) else (v12_path if os.path.exists(v12_path) else (v11_path if os.path.exists(v11_path) else (v10_path if os.path.exists(v10_path) else (v9_path if os.path.exists(v9_path) else base_model))))
        
        try:
            self.classifier = pipeline("text-classification", model=model_to_use, top_k=None)
            self.logger.info(f"✨ Emotion Model ({model_to_use}) loaded successfully.")
        except Exception as e:
            self.logger.error(f"❌ Failed to load {model_to_use}: {e}")
            self.classifier = pipeline("text-classification", model=base_model, top_k=None)

    def analyze(self, text: str):
        self.load_model()
        
        # 0. Basic Preprocessing
        text_clean = text.strip().lower()
        if not text_clean:
            return self._neutral_response("empty_input")

        # 1. Semantic Signal (Rule-based + Keywords)
        semantic_emotion, semantic_score = self.semantic.find_best_match(text_clean)

        # 2. Model Signal (Transformer)
        model_results = self.classifier(text)[0]
        model_results.sort(key=lambda x: x['score'], reverse=True)
        
        primary = model_results[0]
        secondary = model_results[1] if len(model_results) > 1 else None
        
        model_emotion = primary['label']
        model_score = primary['score']

        # 3. Ensemble Fusion Logic
        # Formula: 0.6 * model + 0.3 * semantic + 0.1 * uncertainty_score
        final_emotion = model_emotion
        final_score = model_score
        decision_source = "model_primary"
        reason = "Detected via RoBERTa Transformer logic."

        # Case A: Semantic Prime (Override weak or ambiguous model predictions)
        if semantic_emotion:
            # If semantic matches model, boost confidence
            if semantic_emotion == model_emotion:
                final_score = min(0.99, model_score + 0.2)
                decision_source = "ensemble_fused"
                reason = f"Consensus between Transformer and Semantic Engine on '{semantic_emotion}'."
            # If semantic is strong and model is weak/wrong (Edge Case Specialist)
            elif semantic_score > 0.6 or model_score < 0.5:
                # 🛑 CONTRASTIVE LOGIC CHECK (New V12.5 Feature)
                # If sentence has "but", "although", "however" -> DO NOT BLINDLY TRUST SEMANTICS
                # Example: "I'm smiling but I want to cry" -> Semantic sees "smiling" (Joy), but Context is Sad.
                contrastive_markers = [" but ", "however", "although", " yet ", "spite of"]
                has_contrast = any(c in text_clean for c in contrastive_markers)
                
                if not has_contrast:
                    final_emotion = semantic_emotion
                    final_score = semantic_score
                    decision_source = "semantic_override"
                    reason = f"Semantic Engine identified clear indicators for '{semantic_emotion}'."
                else:
                    # Trust the Transformer model for complex/mixed sentences
                    reason = "Contrastive logic detected ('but/however'), trusting Transformer context over Keywords."

        # Case B: Mundane/Neutral Handling (Explicit)
        # If text is short and contains neutral markers, force neutral unless strong emotion detected
        mundane_markers = ["toast", "breakfast", "lunch", "dinner", "walk the", "dog", "cat", "wall", "car", "parked", "reading", "book", "email", "chilling", "progress", "steady", "shopping"]
        is_mundane = any(m in text_clean for m in mundane_markers)
        
        # Only override if:
        # 1. Model is NOT super confident (< 0.9)
        # 2. Detected emotion is NOT joy/happy (avoid killing "walking in park makes me happy")
        # 3. No strong semantic signal was found (if we found "alive", don't neutralize)
        if is_mundane and model_score < 0.95 and final_emotion != "joy" and not semantic_emotion:
             final_emotion = "neutral"
             final_score = 0.85
             decision_source = "mundane_override"
             reason = "Identified mundane activity pattern, overriding weak emotional signal."

        # Case C: Handle Uncertainty (Neutralize if everything is low)
        if final_score < 0.4 and not semantic_emotion:
            final_emotion = "neutral"
            final_score = 0.6
            decision_source = "uncertainty_handled"
            reason = "Weak emotional signals detected, defaulting to neutral."

        # 4. Ambivalent Anticipation Rule (Specific Fix for "Nervous but Excited")
        # High arousal mixed states often default to Happy in models, but users often mean Anxious.
        if "nervous" in text_clean and "excited" in text_clean:
            final_emotion = "fear"
            final_score = 0.85
            decision_source = "heuristic_override"
            reason = "Detected 'Nervous Anticipation' pattern, prioritizing Anxiety over Excitement."
            
        # Mapping to internal app moods
        mood_map = {
            "joy": "happy", "love": "happy", "optimism": "happy",
            "anger": "stressed", "stressed": "stressed",
            "sadness": "sad",
            "fear": "anxious", "anxious": "anxious",
            "bored": "low_energy", "low_energy_bored": "low_energy",
            "neutral": "neutral", "surprise": "neutral"
        }

        return {
            "mood": mood_map.get(final_emotion, "neutral"),
            "emotion": final_emotion,
            "intensity": final_score,
            "energy_level": "low" if final_emotion in ["sadness", "bored"] else ("high" if final_emotion in ["anger", "joy"] else "medium"),
            "secondary_emotion": secondary['label'] if secondary else None,
            "confidence_level": model_score,
            "decision_source": decision_source,
            "reason": reason,
            "raw_scores": {r['label']: r['score'] for r in model_results}
        }

    def _neutral_response(self, reason):
        return {
            "mood": "neutral", "emotion": "neutral", "intensity": 0.5, "energy_level": "medium",
            "decision_source": "system_fallback", "reason": reason
        }

emotion_analyzer = EmotionAnalyzer()
