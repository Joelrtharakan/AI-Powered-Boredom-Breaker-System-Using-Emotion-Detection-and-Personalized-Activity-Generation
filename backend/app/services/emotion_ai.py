from transformers import pipeline
import logging
import os
import re

class SemanticEngine:
    """Handles deep semantic keyword matching with synonym clusters."""
    def __init__(self):
        self.clusters = {
            "sadness": ["pain", "devastated", "broken", "pointless", "heartbroken", "crushed", "empty", "shattered", "unbearable", "grief", "heart hurts", "so heavy", "worthless", "misery", "bleak", "invisible", "hopeless", "drowning", "tear", "tears", "crying", "lonely", "disappointed", "rejection", "touch breaks", "dead inside", "bittersweet", "depths of despair", "hope tomorrow is better", "wish he would call", "silence is loud", "miss", "missing", "homesick", "longing", "nostalgic", "yearn", "left behind", "far from home", "lost without", "ache", "hurt", "regret", "sorrow", "gloomy", "melancholy", "abandoned", "neglected", "forgotten"],
            "fear": ["shaken", "rattled", "terrified", "panicking", "panic attack", "anxious", "nervous", "dread", "afraid", "scared", "worried", "troubled", "alarmed", "trembling", "shaking", "bad feeling", "suspense", "sweating", "unsafe", "paralyzed", "jitters", "on edge", "uncertainty", "what if", "heard a noise", "spiraling", "yikes", "pounding", "refreshing the page", "haven't replied", "vibes", "overwhelmed", "insecure", "helpless", "vulnerable", "uneasy", "tense", "restless", "freaking out"],
            "bored": ["lethargic", "sluggish", "lazy", "unmotivated", "listless", "apathetic", "i feel nothing", "monotony", "dull", "staring at the wall", "bothered to move", "dragging on", "watching paint dry", "just existing", "waiting for the day to end", "blah", "whatever", "flat", "routine", "zero motivation", "so bored", "doomscrolling", "dragging", "don't want to get out of bed"],
            "fatigue": ["sleepy", "tired", "exhausted", "fatigue", "drained", "burnout", "no energy", "cant do anything", "can't do anything", "can't keep eyes open", "falling asleep", "too tired", "brain is fried", "brain shutting down", "wiped out"],
            "neutral": ["okay", "all good", "fine", "alright", "normal", "existing", "average", "standard", "nothing much", "chilling", "reading", "eating", "drinking", "sitting", "standing", "waiting", "lukewarm", "quiet", "simple", "neither happy nor sad", "shoes", "cloudy", "apples", "wifi", "laptop", "meeting", "wsg", "gang", "what's good", "sup"],
            "anger": ["sick of fake people", "fake people", "blood boil", "pissed", "furious", "enraged", "mad", "annoyed", "frustrated", "fed up", "ridiculous", "audacity", "interrupting", "nightmare", "snap", "patience", "frustrating", "drama", "rent free", "forgot to eat", "what a mess", "can we just stop", "hate", "disgusted", "bitter", "resentful", "hostile"],
            "joy": ["happy", "promotion", "breathtaking", "smiling", "blessed", "plan", "laughed", "top of the world", "yes!", "perfect", "alive", "beaming", "best day", "appreciate", "beautiful", "excited", "full heart", "aced", "winning", "fantastic", "dream come true", "flowers", "she said yes", "cloud nine", "finally finished", "good way", "good day", "great day", "amazing day", "grateful", "thankful", "proud", "love", "loved", "cheerful", "thrilled", "delighted", "wonderful"]
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

    def has_any_emotional_content(self, text: str) -> bool:
        """Check if text contains ANY emotional/meaningful language from any cluster."""
        for emotion, patterns in self.compiled.items():
            for p in patterns:
                if p.search(text):
                    return True
        return False

class RiskAssessment:
    """Classifies user input into risk levels based on keywords and intensity."""
    def __init__(self):
        self.patterns = {
            "CRISIS": [
                "kill myself", "suicide", "sucide", "want to die", "end it all", "better off dead", 
                "no reason to live", "cutting myself", "overdose", "hanging myself", 
                "wish i was dead", "hurt myself", "pain ends", "goodbye forever",
                "end my life", "quit life", "i am done", "done with life",
                "not worth living", "why am i alive", "don't want to exist",
                "what's the point of living", "why do i exist", "no point in living"
            ],
            "HIGH_DISTRESS": [
                "panic attack", "can't breathe", "falling apart", "shaking", "terrified",
                "hopeless", "drowning in sorrow", "unbearable", "heart is ripping", 
                "screaming", "can't take this", "breaking point",
                "mudiyala", "avalotha", "enaku mudiyala", "porum", "venam",
                "naan sethuruvom", "azhugiren"
            ],
            "MODERATE_DISTRESS": [
                "stressed", "anxious", "worried", "sad", "lonely", "frustrated", 
                "annoyed", "fed up", "crying"
            ],
            "FATIGUE": [
                "brain is fried", "brain fog", "exhausted", "sleepy", "drained", "no energy",
                "can't keep eyes open", "so tired", "burnout", "wiped out", "need a nap",
                "need sleep", "fatigued", "too tired", "tired"
            ],
            "TASK_BLOCKED": [
                "stuck on this", "can't focus", "procrastinating", "overwhelmed by work",
                "too much to do", "writer's block", "can't start", "distracted", 
                "losing focus", "brain dead", "can't complete", "can't finish", 
                "frustrated with work", "stuck on work", "hard to focus", "not making progress",
                "overwhelming", "can't do this assignment"
            ],
            "BOREDOM": [
                "bored", "nothing to do", "so dull", "entertain me", "killing time",
                "have nothing to do", "so boring", "i'm bored", "really bored"
            ]
        }
    
    def assess(self, text: str, emotion: str, intensity: float) -> str:
        text_lower = text.lower()
        
        # 1. CRISIS Check (Highest Priority)
        for pattern in self.patterns["CRISIS"]:
            if pattern in text_lower:
                return "CRISIS"
        
        # 2. FATIGUE Check (Physical State Overrides Emotional)
        for pattern in self.patterns["FATIGUE"]:
             if pattern in text_lower:
                return "FATIGUE"

        # 3. TASK BLOCKED Check (Functional State Overrides Emotional Distress)
        for pattern in self.patterns["TASK_BLOCKED"]:
            if pattern in text_lower:
                return "TASK_BLOCKED"

        # 4. HIGH DISTRESS Check (Keyword-based)
        for pattern in self.patterns["HIGH_DISTRESS"]:
            if pattern in text_lower:
                return "HIGH_DISTRESS"

        # 5. BOREDOM Check (BEFORE intensity rule — prevents false escalation)
        for pattern in self.patterns["BOREDOM"]:
            if pattern in text_lower:
                return "BOREDOM"
        if emotion == "bored":
            return "BOREDOM"

        # 6. MODERATE DISTRESS Check (Keyword-based)
        for pattern in self.patterns["MODERATE_DISTRESS"]:
            if pattern in text_lower:
                return "MODERATE_DISTRESS"

        # 7. Contextual High Distress (Model intensity — raised threshold to reduce false positives)
        if emotion in ["fear", "sadness", "anger"] and intensity > 0.95:
            return "HIGH_DISTRESS"
        
        if emotion in ["sadness", "fear", "anger"] and intensity > 0.5:
             return "MODERATE_DISTRESS"

        return "LOW_NORMAL"

    def has_any_pattern_match(self, text: str) -> bool:
        """Check if text matches ANY risk pattern."""
        text_lower = text.lower()
        for category, patterns in self.patterns.items():
            for pattern in patterns:
                if pattern in text_lower:
                    return True
        return False

class EmotionAnalyzer:
    def __init__(self):
        self.classifier = None
        self.semantic = SemanticEngine()
        self.risk_assessor = RiskAssessment()
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
        try:
            model_results = self.classifier(text)[0]
            model_results.sort(key=lambda x: x['score'], reverse=True)
            
            primary = model_results[0]
            secondary = model_results[1] if len(model_results) > 1 else None
            
            model_emotion = primary['label']
            model_score = primary['score']
        except Exception as e:
            self.logger.error(f"Model prediction failed: {e}")
            model_emotion = "neutral"
            model_score = 0.5
            secondary = None
            model_results = []

        # 3. Ensemble Fusion Logic
        final_emotion = model_emotion
        final_score = model_score
        decision_source = "model_primary"
        reason = "Detected via RoBERTa Transformer logic."

        # Case A: Semantic Prime
        if semantic_emotion:
            if semantic_emotion == model_emotion:
                final_score = min(0.99, model_score + 0.2)
                decision_source = "ensemble_fused"
                reason = f"Consensus between Transformer and Semantic Engine on '{semantic_emotion}'."
            elif semantic_score > 0.6 or model_score < 0.5:
                # Contrastive Logic Check
                contrastive_markers = [" but ", "however", "although", " yet ", "spite of"]
                has_contrast = any(c in text_clean for c in contrastive_markers)
                
                if not has_contrast:
                    final_emotion = semantic_emotion
                    final_score = semantic_score
                    decision_source = "semantic_override"
                    reason = f"Semantic Engine identified clear indicators for '{semantic_emotion}'."
                else:
                    reason = "Contrastive logic detected ('but/however'), trusting Transformer context over Keywords."

        # Case B: Mundane/Neutral/Request Handling
        mundane_markers = ["toast", "breakfast", "lunch", "dinner", "walk the", "dog", "cat", "wall", "car", "parked", "reading", "book", "email", "chilling", "progress", "steady", "shopping", "weather", "temperature", "rain", "sunny", "cloudy day"]
        request_markers = ["give me", "show me", "tell me", "how to", "make me", "send me", "do a", "execute", "run", "what is", "calculate", "write a", "create a"]
        is_mundane = any(m in text_clean for m in mundane_markers)
        is_request = any(r in text_clean for r in request_markers)
        
        if (is_mundane or is_request) and model_score < 0.95 and final_emotion != "joy" and not semantic_emotion:
             final_emotion = "neutral"
             final_score = 0.85 if is_mundane else 0.0
             decision_source = "neutral_override" if is_mundane else "no_emotion_detected"
             reason = "Identified mundane activity or task-based request, overriding weak emotional signal."

        # Case C: Handle Uncertainty (Confidence < 0.65 -> sadness)
        # Only if there IS actual emotional content from semantic or risk patterns
        if final_score < 0.65 and not semantic_emotion:
            if self.risk_assessor.has_any_pattern_match(text_clean):
                final_emotion = "sadness"
                final_score = 0.65
                decision_source = "uncertainty_handled"
                reason = "Confidence < 0.65, defaulting to sadness per Regulation Engine rules."
            # else: let it fall through to Case D's no-emotion check

        # Case D: NO EMOTIONAL CONTENT — Random/Nonsensical words
        word_count = len(text_clean.split())
        has_semantic = self.semantic.has_any_emotional_content(text_clean)
        has_risk = self.risk_assessor.has_any_pattern_match(text_clean)
        
        if not has_semantic and not has_risk:
            # If the model predicts an actual emotion (joy, sadness, fear, anger) 
            # with very high confidence, we trust it even without keywords.
            is_strong_emotion = final_emotion != "neutral" and model_score > 0.85
            
            if not is_strong_emotion:
                # If it's weak, or if it's just predicting 'neutral' without explicit neutral keywords:
                if (word_count <= 4 
                    or final_emotion == "neutral"
                    or (word_count <= 8 and model_score < 0.7)
                    or (word_count > 8 and model_score < 0.5)):
                    final_emotion = "neutral"
                    final_score = 0.0
                    decision_source = "no_emotion_detected"
                    reason = "No emotional content found in input. Random or non-emotional text."

        # 4. Ambivalent Anticipation Rule
        if "nervous" in text_clean and "excited" in text_clean:
            final_emotion = "fear"
            final_score = 0.85
            decision_source = "heuristic_override"
            reason = "Detected 'Nervous Anticipation' pattern, prioritizing Anxiety over Excitement."
            
        # 5. SAFETY OVERRIDE: Existential, Hopelessness, Multilingual Distress
        existential_phrases = ["why am i alive", "what's the point", "why do i exist", "not worth living",
                               "want to die", "kill myself", "end it all", "better off dead", "done with life", "i dont want to exist", "i don't want to exist"]
        hopelessness_phrases = ["pointless", "nothing matters", "hopeless", "give up", "no way out"]
        multilingual_distress = ["enaku mudiyala", "porum", "venam", "thangamudiyathu", "sathu poidalam", "mar jaunga", "nahi jina"]
        
        all_distress_phrases = existential_phrases + hopelessness_phrases + multilingual_distress

        if any(p in text_clean for p in all_distress_phrases):
            if final_emotion == "joy":
                final_emotion = "sadness"
                decision_source = "safety_override"
                reason = "Joy overridden: Distress/hopeless phrase detected. Safety first."
            if final_emotion != "sadness":
                final_emotion = "sadness"
                decision_source = "safety_override"
                reason = "Forced sadness due to existential/multilingual distress."
            final_score = max(final_score, 0.95)

        # 6. Neutral intensity cap (cannot exceed 0.85)
        if final_emotion == "neutral" and final_score > 0.85:
            final_score = 0.85

        # 7. Intensity > 0.9 flag for plan strengthening
        needs_strengthening = final_score > 0.9 and final_emotion in ["sadness", "fear", "anger"]

        # 8. RISK ASSESSMENT
        risk_level = self.risk_assessor.assess(text_clean, final_emotion, final_score)

        # 9. Override risk to NO_EMOTION if no emotional content was found
        if decision_source == "no_emotion_detected":
            risk_level = "NO_EMOTION"

        if decision_source == "safety_override" and risk_level not in ["CRISIS", "HIGH_DISTRESS"]:
            risk_level = "HIGH_DISTRESS"

        # 10. EMOTIONAL SUBTYPE DETECTION
        subtype = None
        if final_emotion == "sadness":
            if any(k in text_clean for k in ["miss", "homesick", "wish i was home", "lonely for", "want to see", "lonely"]):
                subtype = "ATTACHMENT"
            elif any(k in text_clean for k in ["pointless", "nothing matters", "done with life", "hopeless"]):
                subtype = "HOPELESSNESS"
            elif any(k in text_clean for k in ["lost", "passed away", "died", "death", "grief"]):
                subtype = "GRIEF"
            elif any(k in text_clean for k in ["exam", "failed", "work stress", "assignment"]):
                subtype = "PERFORMANCE"
            elif any(k in text_clean for k in ["drained", "exhausted", "tired", "burnout"]):
                subtype = "FATIGUE"

        # 11. NERVOUS SYSTEM STATE
        nervous_system_state = "regulated"
        if final_emotion in ["fear", "anger"] or risk_level in ["CRISIS", "HIGH_DISTRESS"] or any(k in text_clean for k in ["panic", "shaking", "overwhelmed"]):
            nervous_system_state = "hyperaroused"
        elif final_emotion in ["bored", "fatigue"] or subtype == "FATIGUE" or any(k in text_clean for k in ["numb", "drained"]):
            nervous_system_state = "hypoaroused"
        
        # Mapping to internal app moods
        mood_map = {
            "joy": "happy", "love": "happy", "optimism": "happy",
            "anger": "stressed", "stressed": "stressed",
            "sadness": "sad",
            "fear": "anxious", "anxious": "anxious",
            "bored": "low_energy", "low_energy_bored": "low_energy",
            "fatigue": "fatigued",
            "neutral": "neutral", "surprise": "neutral"
        }

        # Strategy Guidance for Agent
        strategy = "Provide clear, accurate, efficient help."
        
        if risk_level == "CRISIS":
            strategy = "CRISIS PROTOCOL: Respond with empathy, validate feelings, slow the moment (grounding), encourage reaching trusted person. DO NOT give productivity tips."
        elif risk_level == "FATIGUE":
             strategy = "FATIGUE PROTOCOL: Goal -> Restore Energy. Acknowledge tiredness. Recommend rest/nap/hydration. NO GAMES. NO WORK."
        elif risk_level == "HIGH_DISTRESS":
            strategy = "HIGH DISTRESS: Validate emotion strongly. Provide grounding + one simple coping step."
        elif risk_level == "TASK_BLOCKED":
            strategy = "TASK BLOCKED: Acknowledge frustration. Identify blocker. Suggest 3 small, time-bound recovery steps. NO RELAXATION."
        elif risk_level == "MODERATE_DISTRESS":
            strategy = "MODERATE DISTRESS: Provide supportive guidance with emotional awareness."
        elif risk_level == "BOREDOM":
            strategy = "BOREDOM: Suggest engaging, interest-aligned activities (games/creative). Purposeful engagement."

        return {
            "mood": mood_map.get(final_emotion, "neutral"),
            "emotion": final_emotion,
            "subtype": subtype,
            "intensity": final_score,
            "nervous_system_state": nervous_system_state,
            "energy_level": "low" if final_emotion in ["sadness", "bored", "fatigue"] else ("high" if final_emotion in ["anger", "joy"] else "medium"),
            "secondary_emotion": secondary['label'] if secondary else None,
            "risk_level": risk_level,
            "strategy": strategy,
            "confidence_level": model_score if 'model_score' in locals() else final_score,
            "decision_source": decision_source,
            "reason": reason,
            "needs_strengthening": needs_strengthening,
            "text": text
        }

    def _neutral_response(self, reason):
        return {
            "mood": "neutral", "emotion": "neutral", "intensity": 0.5, "energy_level": "medium",
            "risk_level": "LOW_NORMAL", "strategy": "Provide clear, accurate, efficient help.",
            "decision_source": "system_fallback", "reason": reason
        }

emotion_analyzer = EmotionAnalyzer()
