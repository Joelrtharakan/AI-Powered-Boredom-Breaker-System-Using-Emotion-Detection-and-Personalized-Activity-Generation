import json
import logging
import random
from app.services.llm_service import llm_service
from app.services.spotify_service import spotify_service
from app.services.emotion_ai import emotion_analyzer

class PlannerAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    async def generate_plan(self, mood: str, intensity: float, user_id: int = None, interests: list = None, text: str = ""):
        """
        Generates a 3-step improvement plan personalized by user interests and SAFETY RISK.
        """
        # 1. RISK ASSESSMENT (Critical Step)
        # We re-analyze or use the provided text to check for crisis
        analysis = emotion_analyzer.analyze(text) if text else {"risk_level": "LOW_NORMAL"}
        risk_level = analysis.get("risk_level", "LOW_NORMAL")
        
        self.logger.info(f"Planner Risk Assessment: {risk_level} for text='{text}'")

        # 🚨 CRISIS PROTOCOL: Force Safety Plan
        if risk_level == "CRISIS":
            return [
                {
                    "type": "breathing",
                    "description": "Box Breathing: Inhale 4s, Hold 4s, Exhale 4s, Hold 4s.",
                    "time_minutes": 2,
                    "purpose": "immediate_grounding"
                },
                {
                    "type": "social",
                    "description": "Reach out to a trusted friend, family member, or helpline.",
                    "time_minutes": 5,
                    "purpose": "safety_connection"
                },
                {
                    "type": "environment_adjustment",
                    "description": "Go to a safe, comfortable space. Wrap yourself in a blanket.",
                    "time_minutes": 0,
                    "purpose": "safety_environment"
                }
            ]

        # 🚨 HIGH DISTRESS PROTOCOL: Force Calming Plan (No Games)
        if risk_level == "HIGH_DISTRESS":
            return [
                {
                    "type": "breathing",
                    "description": "focus on your breath. Long exhale.",
                    "time_minutes": 3,
                    "purpose": "calming"
                },
                 {
                    "type": "micro_task",
                    "description": "5-4-3-2-1 Grounding: Name 5 things you see, 4 you feel.",
                    "time_minutes": 2,
                    "purpose": "grounding"
                }
            ]

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
            
        # Check for Positive Expression (Minimal Intervention)
        positive_keywords = ["love", "grateful", "blessed", "god is good", "amazing day", "good day", "excited", "happy"]
        is_positive = any(k in mood.lower() for k in positive_keywords) or (text and any(k in text.lower() for k in positive_keywords))
        
        system_prompt = f"""
🧠 FINAL PRODUCTION PROMPT — Emotion-Aware Regulation Planner

You are a behavioral regulation planner inside an AI emotional support system.

Your job is to generate a small, realistic, human-aligned action plan based on:
• user_text: "{text}"
• detected emotion: "{mood}"
• detected energy level: "auto-detect"
• classifier confidence: "trust input"

Your purpose is: regulate → stabilize → gently support ONLY when support is needed.
You must respect user capacity and context. You are not a coach, therapist, or productivity system.

Compassionate Context: The user's interests are: {interests_str}. Align activities with these if appropriate.

Available Resources:
AVAILABLE GAMES: {", ".join(AVAILABLE_GAMES)}
AVAILABLE PLAYLISTS: {", ".join([f"{k}: {v}" for k, v in AVAILABLE_PLAYLISTS.items()])}

compassionate_rules:
    - If user is "fatigued" or "exhausted", you MUST trigger SLEEP MODE (Rest only).
    - If user is "happy", "grateful", or expressing faith ("I love Jesus"), you MUST trigger POSITIVE MODE (Savoring only).
    - If user is "bored", provide stimulation.
    - If user is "anxious", provide grounding.

⸻

🚨 CRITICAL SAFETY RULES (OVERRIDE EVERYTHING):
1. If Risk Level is CRISIS or HIGH_DISTRESS:
   - DO NOT suggest games.
   - DO NOT suggest "sad music".
   - DO NOT suggest productivity tasks.
   - ONLY suggest: Breathing, Grounding (5-4-3-2-1), Safe Space, Calling Helpline/Friend.
   - Tone must be extremely gentle, slow, and validating.

⸻

🧭 MASTER DECISION RULE

IF the user does NOT show distress or impairment → minimize intervention.
IF the body needs rest → support rest, not regulation.
IF confidence is low → provide light, optional support only.

⸻

✨ POSITIVE EXPRESSION MINIMAL INTERVENTION MODE (MANDATORY)
Trigger: {is_positive} (User expresses love, gratitude, faith, joy without distress).
Behavior:
• Do NOT generate coping or regulation plan
• Provide 0–2 tiny savoring steps maximum
• Goal: sustain positive emotion
Allowed: gratitude noticing, brief reflection, gentle appreciation.
Forbidden: breathing for regulation, activation tasks, productivity suggestions, mood fixing.

⸻

💤 FATIGUE / SLEEPINESS OVERRIDE MODE (MANDATORY)
Trigger: {is_fatigued} (User expresses physical tiredness/sleepiness).
Behavior:
• Treat as physical recovery need, not emotional distress.
• Generate a minimal rest-support plan (1–3 steps).
Allowed: lie down / rest, reduce stimulation, sleep-support environment, calm ambient audio.
Forbidden: games, cognitive tasks, emotional processing, productivity activities, engagement steps.

⸻

🧩 EMOTION-SPECIFIC STRATEGIES

SADNESS: Goal → validation + soothing. (1. acknowledge, 2. grounding, 3. comfort).
FEAR/ANXIETY: Goal → calm nervous system. (1. breathing, 2. grounding, 3. safety).
BOREDOM: Goal → stimulation. (1. activation, 2. novelty, 3. playful).
ANGER: Goal → safe tension release. (1. release, 2. breathing, 3. redirection).

⸻

✅ OUTPUT FORMAT (MANDATORY)
Return JSON array only.
Example: [{{"type": "rest", "description": "Lie down...", "time_minutes": 20, "purpose": "recovery"}}]
Valid Types: "breathing", "micro_task", "activity", "music", "affirmation", "game", "journal", "social", "rest", "environment_adjustment", "calming_audio".
Keep descriptions SHORT, WARM, and ACTIONABLE.
"""

        user_prompt = f"""
Input Context:
User Text: "{text}"
Mood: {mood}
Intensity: {intensity}
Risk Level: {risk_level}
Is Fatigued: {is_fatigued}
Is Positive Context: {is_positive}

Generate JSON plan:
"""
        plan = []

        # 3. Call LLM
        try:
            response_text = await llm_service.generate(system_prompt, user_prompt)
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


        # 4. Inject Game Recommendation
        # POLICY: Only suggest games for Boredom/Stress/Sadness if RISK IS LOW.
        # NEVER suggest games for Crisis or High Distress or Fatigue.
        game_triggers = ["bored", "boredom", "stressed", "anxious", "low_energy", "neutral", "sad", "sadness"]
        should_suggest_game = any(t in mood.lower() for t in game_triggers)
        
        is_high_risk = risk_level in ["CRISIS", "HIGH_DISTRESS"]
        
        if should_suggest_game and not is_fatigued and not is_high_risk:
                games = ["Snake Evolution", "Memory Flip", "Chimp Test", "Visual Memory", "Number Guess", "Aim Trainer", "Reaction Time", "Tic Tac Toe", "Rock Paper Scissors"]
                plan.append({
                    "type": "game",
                    "description": f"Play {random.choice(games)} to reset your focus.",
                    "time_minutes": 5
                })

        # 5. Inject Music Recommendation (Universal)
        for step in plan:
            if step.get("type") == "music":
                # For high risk, force chill/calm music, never sad
                target_mood = "chill" if is_high_risk else mood
                
                playlists = spotify_service.get_mood_playlists(target_mood, limit=1)
                if playlists:
                    if "metadata" not in step:
                        step["metadata"] = {}
                    step["metadata"]["spotify_uri"] = playlists[0]["uri"]
                    step["metadata"]["playlist_name"] = playlists[0]["name"]
                    step["metadata"]["image"] = playlists[0].get("image")
                    step["description"] += f" (Try: {playlists[0]['name']})"

        return plan

planner_agent = PlannerAgent()
