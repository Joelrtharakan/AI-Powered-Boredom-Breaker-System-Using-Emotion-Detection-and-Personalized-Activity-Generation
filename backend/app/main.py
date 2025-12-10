from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.db.base import Base
from app.db.session import engine

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.PROJECT_NAME)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # For dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to Boredom Breaker API"}

from app.api.v1.api import api_router
from app.services.emotion_ai import emotion_analyzer

@app.on_event("startup")
async def startup_event():
    # Preload the emotion model to avoid latency on first request
    emotion_analyzer.load_model()

app.include_router(api_router, prefix="/api")
