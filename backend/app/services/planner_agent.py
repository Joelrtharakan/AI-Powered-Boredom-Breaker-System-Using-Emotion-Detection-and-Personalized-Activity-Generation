import json
import logging
import random
from app.services.llm_service import llm_service
from app.services.spotify_service import spotify_service

class PlannerAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    async def generate_plan(self, mood: str, intensity: float, user_id: int = None, interests: list = None, text: str = ""):
        """
        Generates a 3-step improvement plan personalized by user interests.
        """
        interests_str = ", ".join(interests) if interests else "General wellness"
        
        # Available Resources
        AVAILABLE_GAMES = [
            "Snake Evolution", "Memory Flip", "Chimp Test", 
            "Visual Memory", "Number Guess", "Aim Trainer", "Reaction Time", 
            "Tic Tac Toe", "Rock Paper Scissors"
        ]

        AVAILABLE_PLAYLISTS = {
            "chill": "Chill Vibes (https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6)",
            "focus": "Deep Focus (https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ)",
            "energize": "High Energy Pop (https://open.spotify.com/playlist/37i9dQZF1DX0vHZ8elq0UK)",
            "sad": "Sad Songs (https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1)",
            "happy": "Happy Hits (https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC)",
            "christian": "Worship Now (https://open.spotify.com/playlist/37i9dQZF1DXcb6CQIjdqKy)",
            "top_hits": "Top Hits (https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M)"
        }

        # 1. Construct Prompt (Optimized for Speed and Personalization)
        
        distress_keywords = ["sad", "sadness", "stressed", "stress", "anxious", "anxiety", "overwhelmed", "depressed", "fear", "anger"]
        is_distressed = any(k in mood.lower() for k in distress_keywords)

        guidelines = ""
        structure_instruction = """
4. Structure (3 Steps):
   - 1: Micro-task/Breathing (Focus: Biology/Body)
   - 2: Main Activity (Focus: Engagement/Dopamine) - PREFER user interests!
   - 3: Music/Affirmation/Game (Focus: Mood Lift) - PREFER user interests!
"""

        if is_distressed:
            guidelines = """
*** CRITICAL EMOTIONAL REGULATION PROTOCOL (ACTIVE) ***
For this user, you MUST prioritizing REGULATION over distraction.
1. REQUIRED: Include one JOURNALING step: "Write a short message expressing how you feel right now."
2. REQUIRED: Include gentle physical movement (e.g., "Slow stretch", "Walk for 2 mins", "Posture reset").
3. MUSIC: Use CALM/SLOW music (Chill/Worship). Do not force happiness.
4. GAME: Only suggest calming games like "Visual Memory" or "Tic Tac Toe". Avoid high-stress games.
"""
            structure_instruction = """
4. Structure (3-4 Steps for Regulation):
   - 1: Body Regulation (Breathing/Grounding)
   - 2: Gentle Movement (Stretching/Walking)
   - 3: Emotional Processing (Journaling: "Express how you feel")
   - 4: Calm Music/Soothing Game (Optional)
"""

        # Check for Fatigue/Low Energy (Overrides Distress if present)
        fatigue_keywords = [
            "sleepy", "tired", "exhausted", "fatigue", "fatigued", "drained", "burnout", "no energy", 
            "cant do anything", "can't do anything", "can't keep eyes open", "falling asleep",
            "too tired", "brain shutting down"
        ]
        # Check both mood string and raw text if available
        is_fatigued = any(k in mood.lower() for k in fatigue_keywords) or (text and any(k in text.lower() for k in fatigue_keywords))
        
        # Explicit check for "fatigued" mood from emotion_ai
        if mood.lower() == "fatigued":
            is_fatigued = True
            
        print(f"DEBUG: Mood='{mood}', Text='{text}', IsFatigued={is_fatigued}")

        if is_fatigued:
            guidelines = """
*** CRITICAL PHYSIOLOGICAL NEED: SLEEP PROTOCOL ACTIVE ***
User is PHYSICALLY EXHAUSTED. Prioritize REST over all else.
1. GOAL: Restore capacity. Do NOT activate or stimulate.
2. FORBIDDEN: movement, games, cognitive tasks, journaling, productivity.
3. ALLOWED: rest, environment_adjustment, calming_audio.
4. TONE: Gentle, permission-giving, soft.
"""
            structure_instruction = """
4. Structure (Strictly 2-3 Steps):
   - 1: Permission to Rest (Type: "rest") -> e.g., "Lie down and close your eyes."
   - 2: Environment Setup (Type: "environment_adjustment") -> e.g., "Dim the lights."
   - 3: Sensory Support (Type: "calming_audio") -> e.g., "Play soft rain sounds."
"""

        system_prompt = f"""You are an empathetic, intelligent personalized activity planner. Create a mood improvement plan.
        
The user's interests are: {interests_str}. 
YOU MUST try to align activities with these interests if possible.

AVAILABLE GAMES (Suggest ONLY these): {", ".join(AVAILABLE_GAMES)}
AVAILABLE PLAYLISTS (Suggest ONLY from these for music): {", ".join([f"{k}: {v}" for k, v in AVAILABLE_PLAYLISTS.items()])}

{guidelines}

Rules:
1. Return ONLY a JSON ARRAY.
2. Objects: {{"type": "...", "description": "...", "time_minutes": N}}
3. Types: "breathing", "micro_task", "activity", "music", "affirmation", "game", "journal", "social", "rest", "environment_adjustment", "calming_audio".
{structure_instruction}
5. If suggesting a GAME, use the exact name from the available list.
6. If suggesting MUSIC, mention the playlist name from the available list.
7. Keep descriptions SHORT, WARM, and ACTIONABLE.
"""

        user_prompt = f"""
Mood: {mood} (Intensity: {intensity})

Generate JSON plan:
"""
        plan = []

        # 3. Call LLM
        try:
            response_text = await llm_service.generate(system_prompt, user_prompt)
            print(f"DEBUG LLM RAW: {response_text}")
            # Clean response to ensure valid JSON
            cleaned_text = response_text
            if "```json" in response_text:
                cleaned_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                cleaned_text = response_text.split("```")[1].split("```")[0].strip()
                
            parsed = json.loads(cleaned_text)
            
            if isinstance(parsed, dict) and "plan" in parsed:
                parsed = parsed["plan"]
                
            if not isinstance(parsed, list):
                raise ValueError("LLM response is not a list")
            
            if len(parsed) == 0:
                raise ValueError("LLM returned empty plan")
            
            plan = parsed

        except Exception as e:
            self.logger.error(f"Planner Agent failed: {e}")
            # Smart Fallback
            step3_type = "music" if mood in ["sad", "sadness", "depressed", "anxious", "stress", "stressed"] else "affirmation"
            desc = "Listen to some healing frequencies." if step3_type == "music" else "You are doing your best."
            
            plan = [
                {"type": "breathing", "description": "Take 5 deep breaths.", "time_minutes": 1},
                {"type": "micro_task", "description": "Look away from the screen for 20 seconds.", "time_minutes": 1},
                {"type": step3_type, "description": desc, "time_minutes": 5 if step3_type == "music" else 0}
            ]


        # 4. Inject Game Recommendation (Bonus for Boredom/Stress, but NOT Fatigue)
        game_triggers = ["bored", "boredom", "stressed", "anxious", "low_energy", "neutral", "sad", "sadness"]
        should_suggest_game = any(t in mood.lower() for t in game_triggers)
        
        if should_suggest_game and not is_fatigued:
                games = ["Snake Evolution", "Memory Flip", "Chimp Test", "Visual Memory", "Number Guess", "Aim Trainer", "Reaction Time", "Tic Tac Toe", "Rock Paper Scissors"]
                plan.append({
                    "type": "game",
                    "description": f"Play {random.choice(games)} to reset your focus.",
                    "time_minutes": 5
                })

        # 5. Inject Music Recommendation (Universal)
        for step in plan:
            if step.get("type") == "music":
                playlists = spotify_service.get_mood_playlists(mood, limit=1)
                if playlists:
                    if "metadata" not in step:
                        step["metadata"] = {}
                    step["metadata"]["spotify_uri"] = playlists[0]["uri"]
                    step["metadata"]["playlist_name"] = playlists[0]["name"]
                    step["metadata"]["image"] = playlists[0].get("image")
                    step["description"] += f" (Try: {playlists[0]['name']})"

        return plan

planner_agent = PlannerAgent()
