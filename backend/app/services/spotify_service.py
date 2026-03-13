import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import os
import random
from dotenv import load_dotenv

load_dotenv()

class SpotifyService:
    def __init__(self):
        self.client_id = os.getenv("SPOTIFY_CLIENT_ID")
        self.client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")
        self.sp = None
        
        if self.client_id and self.client_secret:
            try:
                self.sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(
                    client_id=self.client_id,
                    client_secret=self.client_secret
                ))
                print("DEBUG: Spotify Client Initialized Successfully")
            except Exception as e:
                print(f"Spotify Init Failed: {e}")
        else:
            print(f"DEBUG: Spotify Keys Missing! ID: {self.client_id}")

    def get_mood_playlists(self, mood: str, limit: int = 12):
        if not self.sp:
            print("DEBUG: Spotify Client is None")
            return []

        search_query = f"{mood} energy" if mood in ["energize", "focus"] else f"{mood} chill"
        try:
            results = self.sp.search(q=search_query, type='playlist', limit=limit)
            playlists = []
            
            for item in results['playlists']['items']:
                if not item: continue
                
                # Get high res image
                img = item['images'][0]['url'] if item['images'] else "https://via.placeholder.com/300"
                
                playlists.append({
                    "name": item['name'],
                    "uri": item['uri'],
                    "image": img,
                    "external_url": item['external_urls']['spotify'],
                    "tracks_count": item['tracks']['total'],
                    "description": item.get('description', '')
                })
            return playlists
        except Exception as e:
            print(f"Spotify Error: {e}")
            return []

spotify_service = SpotifyService()
