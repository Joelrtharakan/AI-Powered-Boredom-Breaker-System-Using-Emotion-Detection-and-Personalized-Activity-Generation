from fastapi import APIRouter
from app.api.v1.endpoints import auth, mood, suggest, journal, lockbox, games

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(mood.router, prefix="/mood", tags=["mood"])
api_router.include_router(suggest.router, prefix="/suggest", tags=["suggest"])
# Suggest router also handles /micro-task and /surprise in shared file for simplicity 
# or I can split. I put them in suggest.py.
api_router.include_router(journal.router, prefix="/journal", tags=["journal"])
api_router.include_router(lockbox.router, prefix="/lockbox", tags=["lockbox"])
api_router.include_router(games.router, prefix="/games", tags=["games"])
