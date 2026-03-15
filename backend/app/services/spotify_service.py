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

        # Map moods to targeted, high-quality, and therapeutic search terms
        mood_queries = {
            "chill": ["Ambient Relief", "Stress Relief Instrumental", "Calm Piano Solos", "Liquid Mind", "Deep Sleep Ambient"],
            "energize": ["Positive Energy Boost", "Upbeat Morning", "Success Motivation", "High Performance Beats", "Confidence Boost"],
            "happy": ["Serotonin Boost", "Sunny Day Vibes", "Feel Good Classics", "Pure Happiness", "Good Vibe Nation"],
            "focus": ["Binaural Beats Focus", "Deep Flow State", "ADHD Focus Lofi", "Beta Waves Concentration", "Cinematic Study"],
            "sad": ["Uplifting Instrumentals", "Hopeful Melodies", "Emotional Healing Piano", "Mood Booster Positive", "Light at the end of the tunnel"],
            "angry": ["Cathartic Heavy Instrumental", "Boxing Power Training", "Aggressive Workout Beats", "Stress Release Industrial", "Rhythm of Resilience"],
            "distress": ["Nervous System Regulation", "Panic Attack Relief Audio", "Vagus Nerve Healing", "Safe Space Ambient"]
        }
        
        # Select search term based on mood
        query_list = mood_queries.get(mood.lower(), ["Peaceful Instrumental"])
        search_query = random.choice(query_list)
        
        # Add 'Playlist' to ensure we get curated collections
        search_query = f"{search_query} Playlist"
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
