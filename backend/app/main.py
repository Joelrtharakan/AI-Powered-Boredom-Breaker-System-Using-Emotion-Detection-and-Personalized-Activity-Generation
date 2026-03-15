import os
from app.core.config import settings

# FORCE DISABLE CREWAI TELEMETRY AND SET AUTH
os.environ["OTEL_SDK_DISABLED"] = "true"
os.environ["CREWAI_TELEMETRY_OPT_OUT"] = "true"
if settings.CREWAI_AUTH_TOKEN:
    os.environ["CREWAI_AUTH_TOKEN"] = settings.CREWAI_AUTH_TOKEN
    
    # Patch CrewAI to use our token from environment instead of disk-based tokens.enc
    try:
        import crewai.utilities.agent_utils
        from crewai.cli.plus_api import PlusAPI
        def custom_plus_client():
            return PlusAPI(api_key=settings.CREWAI_AUTH_TOKEN)
        crewai.utilities.agent_utils._create_plus_client_hook = custom_plus_client
    except ImportError:
        pass

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
    # Preload the emotion model to avoid latency on first request (Main Branch Method)
    print("Loading Emotion Model...")
    emotion_analyzer.load_model()
    print("✨ Emotion Model Preloaded")

app.include_router(api_router, prefix="/api")
