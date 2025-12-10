from fastapi import APIRouter
from typing import List, Optional
from pydantic import BaseModel
from app.services.spotify_service import spotify_service

router = APIRouter()

class Playlist(BaseModel):
    name: str
    uri: str
    image: str
    tracks_count: int
    external_url: Optional[str] = None
    description: Optional[str] = None

class MusicResponse(BaseModel):
    playlists: List[Playlist]

@router.get("/", response_model=MusicResponse)
def get_music(mood: str = "chill", limit: int = 12):
    playlists = spotify_service.get_mood_playlists(mood, limit)
    return {"playlists": playlists}
