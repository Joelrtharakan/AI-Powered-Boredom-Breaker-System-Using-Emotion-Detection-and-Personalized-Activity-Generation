import chromadb
from chromadb.utils import embedding_functions
import logging

class ChromaService:
    def __init__(self):
        self.client = chromadb.PersistentClient(path="./chroma_db")
        # Use default Sentence Transformer embedding
        self.embedding_fn = embedding_functions.DefaultEmbeddingFunction()
        
        self.activities_collection = self.client.get_or_create_collection(
            name="activities", embedding_function=self.embedding_fn
        )
        self.microtasks_collection = self.client.get_or_create_collection(
            name="microtasks", embedding_function=self.embedding_fn
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

chroma_service = ChromaService()
