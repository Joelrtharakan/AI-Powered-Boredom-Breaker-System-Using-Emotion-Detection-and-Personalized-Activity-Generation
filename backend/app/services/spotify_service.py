import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import os
import random
import requests
from requests.adapters import HTTPAdapter
from urllib3.util import Retry
from dotenv import load_dotenv

load_dotenv()

class SpotifyService:
    def __init__(self):
        self.client_id = os.getenv("SPOTIFY_CLIENT_ID")
        self.client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")
        self.sp = None
        
        if self.client_id and self.client_secret:
            try:
                # Configure a robust session with retries for Spotify
                session = self._get_session()
                
                self.sp = spotipy.Spotify(
                    auth_manager=SpotifyClientCredentials(
                        client_id=self.client_id,
                        client_secret=self.client_secret,
                        requests_session=session
                    ),
                    requests_session=session
                )
                print("DEBUG: Spotify Client Initialized Successfully (with Retry Session)")
            except Exception as e:
                print(f"Spotify Init Failed: {e}")
        else:
            print(f"DEBUG: Spotify Keys Missing! ID: {self.client_id}")

    def _get_session(self):
        """Create a requests session with retry logic to handle intermittent connection drops."""
        session = requests.Session()
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS", "POST"]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("https://", adapter)
        session.mount("http://", adapter)
        return session

    def search_items(self, query: str, type: str = 'track', limit: int = 1):
        """Generalized search for tracks or playlists based on a text query."""
        if not self.sp or not query: return []
        try:
            results = self.sp.search(q=query, type=type, limit=limit)
            items = []
            
            key = 'tracks' if type == 'track' else 'playlists'
            if key not in results or 'items' not in results[key]:
                return []

            for item in results[key]['items']:
                if not item: continue
                
                img = ""
                if type == 'track':
                    img = item['album']['images'][0]['url'] if item['album']['images'] else ""
                else:
                    img = item['images'][0]['url'] if item['images'] else ""

                items.append({
                    "name": item['name'],
                    "uri": item['uri'],
                    "image": img,
                    "external_url": item['external_urls']['spotify'],
                    "artist": item['artists'][0]['name'] if type == 'track' and 'artists' in item and item['artists'] else None
                })
            return items
        except Exception as e:
            print(f"Spotify Search Error: {e}")
            return []

    def get_mood_playlists(self, mood: str, limit: int = 12):
        if not self.sp:
            print("DEBUG: Spotify Client is None")
            return []

        # Map moods to modern, high-quality, and therapeutic search terms
        mood_queries = {
            "chill": ["Modern Ambient", "Stress Relief 2025", "Calm Piano 2024", "Deep Sleep Modern", "Aesthetic Chill"],
            "energize": ["Modern Energy Boost", "Trending Upbeat", "Success Motivation 2025", "Fresh Performance Beats", "New Confidence Boost"],
            "happy": ["Serotonin Boost 2025", "Trending Sunny Vibes", "Modern Feel Good", "Pure Happiness 2024", "New Positive Energy"],
            "focus": ["Modern Binaural Beats", "Deep Flow State 2025", "ADHD Focus 2024", "Modern Concentration", "Fresh Study Vibes"],
            "sad": ["Modern Uplifting", "New Hopeful Melodies", "Modern Healing Piano", "Mood Booster 2025", "Fresh Start Vibes"],
            "angry": ["Modern Cathartic Beats", "New Power Training", "Modern Workout 2025", "Fresh Stress Release", "Modern Resilience"],
            "distress": ["Modern Regulation Audio", "New Panic Relief", "Modern Ambient Healing", "Safe Space 2025"]
        }
        
        # Select search term based on mood
        query_list = mood_queries.get(mood.lower(), ["Modern Instrumental"])
        search_query = random.choice(query_list)
        
        # Add 'Playlist' and ensure modern bias
        search_query = f"{search_query} Playlist"
        try:
            results = self.sp.search(q=search_query, type='playlist', limit=limit)
            playlists = []
            
            if 'playlists' not in results or 'items' not in results['playlists']:
                return []

            for item in results['playlists']['items']:
                if not item: continue
                
                # Get high res image
                img = item['images'][0]['url'] if item['images'] else "https://via.placeholder.com/300"
                
                playlists.append({
                    "name": item['name'],
                    "uri": item['uri'],
                    "image": img,
                    "external_url": item['external_urls']['spotify'],
                    "tracks_count": item['tracks']['total'] if 'tracks' in item else 0,
                    "description": item.get('description', '')
                })
            return playlists
        except Exception as e:
            print(f"Spotify Error: {e}")
            return []

spotify_service = SpotifyService()

