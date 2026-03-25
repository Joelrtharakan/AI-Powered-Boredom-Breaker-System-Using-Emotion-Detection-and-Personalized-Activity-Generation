import chromadb
from chromadb.utils import embedding_functions
import logging

class ChromaService:
    def __init__(self):
        self.client = chromadb.PersistentClient(path="./data/chroma_db")
        # Use default Sentence Transformer embedding
        self.embedding_fn = embedding_functions.DefaultEmbeddingFunction()
        self._embedding_cache = {} # Simple in-memory cache for speed
        self._init_collections()

    def get_embedding(self, text):
        """Cached embedding retrieval to save CPU/GPU cycles."""
        if text in self._embedding_cache:
            return self._embedding_cache[text]
        emb = self.embedding_fn([text])
        self._embedding_cache[text] = emb
        return emb

    def _init_collections(self):
        self.activities_collection = self.client.get_or_create_collection(
            name="activities", embedding_function=self.embedding_fn
        )
        self.microtasks_collection = self.client.get_or_create_collection(
            name="microtasks", embedding_function=self.embedding_fn
        )
        self.user_memory_collection = self.client.get_or_create_collection(
            name="user_memory", embedding_function=self.embedding_fn
        )

    def add_activity(self, activity_id, text, metadata):
        # text could be description + mood
        self.activities_collection.add(
            documents=[text],
            metadatas=[metadata],
            ids=[str(activity_id)]
        )

    def query_activities(self, query_text, n_results=5, where=None):
        return self.activities_collection.query(
            query_texts=[query_text],
            n_results=n_results,
            where=where
        )

    def add_microtask(self, task_id, text, metadata):
        self.microtasks_collection.add(
            documents=[text],
            metadatas=[metadata],
            ids=[str(task_id)]
        )

    def query_microtasks(self, query_text, n_results=5, where=None):
        return self.microtasks_collection.query(
            query_texts=[query_text],
            n_results=n_results,
            where=where
        )

    def add_user_memory(self, user_id, text, metadata):
        """Stores a interaction or emotional event in long-term memory."""
        import uuid
        import time
        self.user_memory_collection.add(
            documents=[text],
            metadatas=[{
                **metadata, 
                "user_id": str(user_id),
                "timestamp": time.time(),
                "intensity": metadata.get("intensity", 0.5)
            }],
            ids=[str(uuid.uuid4())]
        )

    def query_user_memory(self, user_id, query_text, n_results=5):
        """Retrieves and ranks semantically similar past events."""
        results = self.user_memory_collection.query(
            query_texts=[query_text],
            n_results=n_results,
            where={"user_id": str(user_id)}
        )
        # Custom re-ranking can be done here if needed (e.g. by timestamp)
        return results

chroma_service = ChromaService()
