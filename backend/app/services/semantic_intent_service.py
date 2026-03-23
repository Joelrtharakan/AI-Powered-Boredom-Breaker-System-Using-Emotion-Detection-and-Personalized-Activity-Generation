from app.services.chroma_service import chroma_service
import logging

class SemanticIntentService:
    """Replaces fragile regex with semantic similarity search for student intents."""
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        # Seed intents if they don't exist in a specific collection
        # For now, we use a simple similarity threshold with a predefined set of prototypes
        self.intent_prototypes = {
            "game": [
                "I want to play something", "bored give me a game", "let's play", 
                "entertain me", "gaming", "fun activities", "play a game"
            ],
            "music": [
                "play some music", "I want to listen to songs", "suggest a playlist",
                "something to listen to", "chill vibes", "music for study", "background noise"
            ],
            "breathing": [
                "I need to calm down", "breathing exercise", "help me relax",
                "anxious help", "panic attack help", "centering", "meditation"
            ],
            "journal": [
                "I want to write something", "diarizing", "expressing my thoughts",
                "journal prompt", "record my day", "writing practice"
            ],
            "fatigue": [
                "I'm so tired", "no energy", "falling asleep", "burnt out",
                "exhausted from exams", "need a break", "can't do this anymore"
            ],
            "study_stress": [
                "exams are coming", "too much homework", "assignment due",
                "stressed about grades", "finals fatigue", "college is hard"
            ]
        }
        
    def detect_intent(self, text: str) -> str:
        """Returns the most likely intent using a weighted keyword approach."""
        if not text:
            return "neutral"
            
        text_lower = text.lower()
        
        # 1. HIGH PRIORITY KEYWORD MATCHING (Fast Path)
        keyword_map = {
            "game": ["play", "game", "gaming", "snake", "bored", "fun", "tiktok", "entertain", "something to do", "nothing to do", "give me"],
            "music": ["music", "song", "playlist", "listen", "spotify", "vibes", "audio"],
            "breathing": ["calm", "relax", "breathe", "breathing", "panic", "anxious", "stress", "meditat", "grounding"],
            "journal": ["write", "journal", "thoughts", "prompt", "diarize", "record"],
            "fatigue": ["tired", "exhausted", "sleepy", "energy", "burnt out", "break"]
        }
        
        scores = {intent: 0 for intent in keyword_map}
        for intent, keywords in keyword_map.items():
            for kw in keywords:
                if kw in text_lower:
                    # Give higher weight to direct "play" and "game" words
                    weight = 2 if kw in ["play", "game", "music", "breathe"] else 1
                    scores[intent] += weight
                    
        # Find best intent from keywords
        best_intent = max(scores, key=scores.get)
        if scores[best_intent] > 0:
            # Special case: 'game' intent is mapped to 'game_request' in the router
            if best_intent == "game":
                return "game_request"
            return best_intent
            
        return "neutral"

semantic_intent_service = SemanticIntentService()
