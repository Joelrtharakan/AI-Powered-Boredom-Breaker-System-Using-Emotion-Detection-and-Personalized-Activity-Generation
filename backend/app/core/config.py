from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Boredom Breaker"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "YOUR_SUPER_SECRET_KEY_CHANGE_ME"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    SQLALCHEMY_DATABASE_URI: str = "sqlite:///./data/boredom_breaker.db"
    
    # Optional Spotify
    SPOTIFY_CLIENT_ID: Optional[str] = None
    SPOTIFY_CLIENT_SECRET: Optional[str] = None
    
    # HuggingFace (if using API instead of local)
    HF_API_KEY: Optional[str] = None
    
    # OpenRouter
    OPENROUTER_API_KEY: Optional[str] = None

    # CrewAI
    CREWAI_AUTH_TOKEN: Optional[str] = None

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()

# 👑 GLOBAL ENVIRONMENT SETUP (Universal across API, Scripts, and Tests)
import os
os.environ["OTEL_SDK_DISABLED"] = "true"
os.environ["CREWAI_TELEMETRY_OPT_OUT"] = "true"
os.environ["CREWAI_COLLECT_TELEMETRY"] = "false"

if settings.CREWAI_AUTH_TOKEN:
    os.environ["CREWAI_AUTH_TOKEN"] = settings.CREWAI_AUTH_TOKEN
    
    # Patch CrewAI to use our token from environment instead of disk-based tokens.enc
    try:
        import crewai.utilities.agent_utils
        from crewai.cli.plus_api import PlusAPI
        def custom_plus_client():
            return PlusAPI(api_key=settings.CREWAI_AUTH_TOKEN)
        # Check if the hook exists in this version of CrewAI
        if hasattr(crewai.utilities.agent_utils, "_create_plus_client_hook"):
             crewai.utilities.agent_utils._create_plus_client_hook = custom_plus_client
        elif hasattr(crewai.utilities.agent_utils, "get_plus_api_client"):
             # Alternative hook for deeper patching
             pass
    except ImportError:
        pass
