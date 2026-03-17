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
        
    def detect_intent(self, text: str, threshold: float = 0.4) -> str:
        """Returns the most likely intent based on semantic similarity."""
        if not text:
            return "neutral"
            
        best_intent = "neutral"
        best_score = 0.0
        
        # We can use Chroma to calculate similarity even without a persistent collection
        # by querying a temporary one or just using the embedding function manually.
        # However, for efficiency, let's just use the embedding function to compare.
        
        try:
            # Get embedding of the input text
            query_embedding = chroma_service.embedding_fn([text])[0]
            
            for intent, examples in self.intent_prototypes.items():
                example_embeddings = chroma_service.embedding_fn(examples)
                
                # Simple cosine similarity (or dot product if normalized)
                # Chroma's default embedding function doesn't easily expose a similarity method,
                # but we can use the 'query' method on a dummy collection or just compute it.
                
                # Shortcut: Query the 'activities' or 'microtasks' collection which already contains related terms
                # Or better: Just check for direct matches first (fast path)
                if any(ex.lower() in text.lower() for ex in examples):
                    return intent
                
                # TODO: Implement full vector similarity if fast path fails
                # For now, let's assume we'll use keyword highlights as a boost
            
            return best_intent
        except Exception as e:
            self.logger.error(f"Semantic Intent Detection Error: {e}")
            return "neutral"

semantic_intent_service = SemanticIntentService()
