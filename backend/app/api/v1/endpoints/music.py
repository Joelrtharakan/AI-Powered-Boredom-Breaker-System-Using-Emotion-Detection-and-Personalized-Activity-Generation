from fastapi import APIRouter
from typing import List, Optional
from pydantic import BaseModel

router = APIRouter()

class Track(BaseModel):
    name: str
    artist: str
    preview_url: Optional[str]
    album_art: Optional[str]

class Playlist(BaseModel):
    name: str
    spotify_uri: str
    tracks: List[Track]

class MusicResponse(BaseModel):
    playlists: List[Playlist]

@router.get("/", response_model=MusicResponse)
def get_music(mood: str, limit: int = 10):
    # Mock data based on mood
    # In real implementation, call Spotify API here
    
    # 1. Calming
    if mood in ['anxious', 'stress']:
        return {
            "playlists": [
                {
                    "name": "Calm Vibes",
                    "spotify_uri": "spotify:playlist:37i9dQZF1DWZqd5JICZI0u",
                    "tracks": [
                        {"name": "Weightless", "artist": "Marconi Union", "preview_url": None, "album_art": "https://i.scdn.co/image/ab67616d0000b2733c5e4c01570778c182283f5e"}
                    ]
                }
            ]
        }
        
    # Default
    return {
        "playlists": [
             {
                    "name": "Top Hits",
                    "spotify_uri": "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M",
                    "tracks": [
                        {"name": "Blinding Lights", "artist": "The Weeknd", "preview_url": None, "album_art": "https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36"}
                    ]
             }
        ]
    }
