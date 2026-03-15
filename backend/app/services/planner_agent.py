import asyncio
import json
import logging
import random
import re
from crewai import Agent, Task, Crew
from app.services.llm_service import llm_service
from app.services.spotify_service import spotify_service
from app.services.emotion_ai import emotion_analyzer

class PlannerAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # SECTION 1: Music Intelligence (Preserved and Enhanced)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    def _get_emotion_music(self, emotion: str, risk_level: str, subtype: str = None) -> dict:
        """Select music based on emotion/subtype. Enforces safety rules."""
        
        music_map = {
            "sadness": {"description": "Hopeful and comforting melodies to ease the heart", "purpose": "mood_transition", "mood_key": "sad"},
            "fear": {"description": "Nervous system regulation audio for grounding", "purpose": "nervous_system_regulation", "mood_key": "distress"},
            "anger": {"description": "Cathartic rhythmic beats for emotional release", "purpose": "de_escalation", "mood_key": "angry"},
            "fatigue": {"description": "Pure ambient restoration and rest tones", "purpose": "restoration", "mood_key": "chill"},
            "bored": {"description": "Upbeat energy shift to spark activation", "purpose": "stimulation", "mood_key": "energize"},
            "joy": {"description": "Positive frequency amplification", "purpose": "amplification", "mood_key": "happy"},
            "neutral": {"description": "Light background concentration flow", "purpose": "ambient", "mood_key": "focus"},
        }

        # Subtype-specific overrides
        base = music_map.get(emotion, music_map["neutral"])
        if subtype == "ATTACHMENT":
            base["description"] = "Warm piano, acoustic, nostalgic tones"
            base["mood_key"] = "sad"

        # Safety overrides
        if risk_level == "CRISIS":
            return {"description": "Emergency clinical priority (no music)", "purpose": "safety", "mood_key": "chill"}
        elif risk_level == "HIGH_DISTRESS":
            base["description"] = "60-70 BPM instrumental (no lyrics)"
            base["mood_key"] = "chill"
        elif risk_level == "FATIGUE":
            base["description"] = "Ambient rainfall or white noise"
            base["mood_key"] = "chill"

        return base

    async def _post_process_plan(self, plan: list, mood_key: str) -> list:
        """Attach metadata for Spotify and Games for direct navigation buttons."""
        if not plan:
            return plan

        loop = asyncio.get_event_loop()
        known_games = {
            "snake": "Snake Evolution",
            "snake evolution": "Snake Evolution",
            "memory flip": "Memory Flip",
            "visual memory": "Visual Memory",
            "chimp test": "Chimp Test",
            "chimp": "Chimp Test",
            "aim trainer": "Aim Trainer",
            "aim": "Aim Trainer",
            "reaction time": "Reaction Time",
            "reaction": "Reaction Time",
            "tic tac toe": "Tic Tac Toe",
            "rock paper scissors": "Rock Paper Scissors",
            "rock paper": "Rock Paper Scissors",
            "guess number": "Guess Number",
            "number guess": "Guess Number"
        }

        for step in plan:
            # 1. Spotify Injection
            if step.get("type") in ["music", "calming_audio"]:
                try:
                    playlists = await loop.run_in_executor(None, spotify_service.get_mood_playlists, mood_key, 1)
                    if playlists:
                        step["metadata"] = {
                            "spotify_uri": playlists[0]["uri"],
                            "spotify_url": playlists[0]["external_url"],
                            "playlist_name": playlists[0]["name"],
                            "image": playlists[0].get("image")
                        }
                        # Force description to mentions Spotify to trigger mobile UI logic if needed
                        if playlists[0]["name"] not in (step.get("description") or ""):
                            step["description"] = f"{step.get('description', '')} (Listen to {playlists[0]['name']})"
                except Exception as e:
                    self.logger.error(f"Spotify Injection Error: {e}")

            # 2. Game Metadata Injection (Search all steps for game matches with word boundaries)
            desc_lower = step.get("description", "").lower()
            
            # Sort keys by length descending to match 'Snake Evolution' before 'Snake'
            sorted_keys = sorted(known_games.keys(), key=len, reverse=True)
            
            for key in sorted_keys:
                official_name = known_games[key]
                # Use regex with word boundaries to avoid matching 'reaction' in 'reactions'
                pattern = rf"\b{re.escape(key)}\b"
                if re.search(pattern, desc_lower):
                    if "metadata" not in step: step["metadata"] = {}
                    step["metadata"]["game_name"] = official_name
                    # Only override type to 'game' if it's not already a high-priority type like 'crisis'
                    if step.get("type") not in ["crisis", "social", "music", "calming_audio"]:
                        step["type"] = "game"
                    break
        
        return plan

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # SECTION 2: Adaptive Plan Modifier
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    def _apply_adaptive_modifiers(self, plan: list, emotion: str, intensity: float, text: str, risk_level: str, subtype: str = None) -> list:
        """Dynamically adapt plan steps based on intensity + clinical protocols."""

        plan_types = [s.get("type", "") for s in plan]
        text_lower = text.lower() if text else ""

        # Social Intelligence: Handle Loneliness & Attachment
        loneliness_markers = ["lonely", "alone", "no one", "isolated", "by myself"]
        is_lonely = any(m in text_lower for m in loneliness_markers) or subtype == "ATTACHMENT"
        
        if is_lonely and "social" not in plan_types and risk_level not in ["CRISIS", "BOREDOM", "LOW_NORMAL"]:
            social_step = {
                "type": "social",
                "description": "Send a short message to someone you trust — connectivity helps.",
                "time_minutes": 5,
                "purpose": "connection"
            }
            if subtype == "ATTACHMENT":
                plan.insert(min(1, len(plan)), social_step) # Priority placement
            else:
                plan.append(social_step)

        # High Intensity Grounding
        if intensity > 0.85 and "micro_task" not in plan_types and risk_level not in ["BOREDOM", "LOW_NORMAL"]:
            plan.insert(min(1, len(plan)), {
                "type": "micro_task",
                "description": "Quick Grounding: Focus on 5 things you see and 4 you can touch right now.",
                "time_minutes": 2,
                "purpose": "immediate_regulation"
            })

        # Recovery Loop Question
        if risk_level not in ["BOREDOM", "LOW_NORMAL"] and "check_in" not in [s.get("type", "") for s in plan]:
            plan.append({
                "type": "check_in",
                "description": "Take a moment to check in: Do you feel even 1% better?",
                "time_minutes": 1,
                "purpose": "recovery_check"
            })

        return plan

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # SECTION 3: Main Agentic Plan Generator
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    async def generate_plan(self, mood: str, intensity: float, user_id: int = None, interests: list = None, text: str = "", subtype: str = None, ns_state: str = None, risk_level: str = None):
        """
        Generates a structured plan by combining clinical protocols with CrewAI generation.
        """
        
        # 1. State Synthesis
        if not risk_level:
            # Re-analyze if data is missing
            analysis = emotion_analyzer.analyze(text) if text else {"risk_level": "LOW_NORMAL", "emotion": "neutral"}
            risk_level = analysis.get("risk_level", "LOW_NORMAL")
            emotion = analysis.get("emotion", "neutral")
            detected_intensity = analysis.get("intensity", intensity)
        else:
            # Extract emotion from the combined mood string if necessary
            emotion = mood.split("(Detected Emotion:")[1].split(")")[0].strip() if "(Detected Emotion:" in mood else "neutral"
            detected_intensity = intensity

        self.logger.info(f"Planner Orchestration: risk={risk_level}, emotion={emotion}")
        
        # 1.5 CRISIS PROTOCOL (Hard Stop)
        # If the user is in crisis, we bypass any dynamic generation and provide emergency resources.
        if risk_level == "CRISIS":
            return [
                {
                    "type": "crisis",
                    "description": "I hear how much pain you're in, and I want you to know you are not alone. Please reach out to the Kiran mental health helpline at 1800-599-0019 or Aasra at +91-9820466726 immediately.",
                    "time_minutes": 0,
                    "purpose": "immediate_safety"
                },
                {
                    "type": "grounding",
                    "description": "Let's focus on your breathing. Inhale deeply for 4 seconds, hold for 4, and exhale for 4. Continue this until you feel even slightly more centered.",
                    "time_minutes": 5,
                    "purpose": "nervous_system_regulation"
                },
                {
                    "type": "social",
                    "description": "Please call a trusted friend or family member right now. Connectivity is one of the strongest buffers against this pain.",
                    "time_minutes": 0,
                    "purpose": "human_connection"
                }
            ]

        # 2. Fast Path - No Emotion Detected
        if risk_level == "NO_EMOTION":
            return [{
                "type": "no_emotion",
                "description": "I couldn't detect any emotion. Try telling me more about how you're feeling!",
                "time_minutes": 0,
                "purpose": "prompt_user",
                "no_plan": True
            }]

        # 3. Preparation for CrewAI
        music_info = self._get_emotion_music(emotion, risk_level, subtype)
        
        # 4. Agentic Execution
        # We offload Agent creation to a thread to avoid event loop conflicts
        agent = await asyncio.to_thread(
            Agent,
            from_repository="psychological-health-planner",
            llm=llm_service.crew_llm
        )

        # Context-rich Task with high specificity rules
        protocol_instruction = ""
        if risk_level in ["CRISIS", "HIGH_DISTRESS", "MODERATE_DISTRESS"]:
            protocol_instruction = (
                "PROGRESSIVE RECOVERY: Your plan must have an arc. \n"
                "Step 1: Immediate Grounding (Breathing/Micro-task). \n"
                "Step 2: Processing (Journaling about the specific trigger). \n"
                "Step 3: Uplifting Transition (Prescribe the music step as the final 'lift' to a better state)."
            )
        elif risk_level == "BOREDOM":
            protocol_instruction = "STIMULATION: Suggest ONE high-engagement game (Snake Evolution, Aim Trainer, or Reaction Time) and ONE upbeat music choice."
        elif risk_level == "FATIGUE":
            protocol_instruction = "RESTORATION: Suggest sensory rest, then ONE ambient/chill music choice."
        else: # LOW_NORMAL / JOY / NEUTRAL
            protocol_instruction = "ENRICHMENT: Suggest ONE strategy/logic game (Chimp Test, Tic Tac Toe, or Memory Flip) or a creative journal prompt, ending with focus/joy music."
        
        task = Task(
            description=(
                f"Create a psychology-aligned recovery plan for a student in a {risk_level} state to help them COPE and move to a BETTER SITUATION.\n"
                f"User Emotion: {emotion}\n"
                f"Intensity: {detected_intensity}\n"
                f"User context: {text}\n"
                f"User Interests: {interests}\n"
                f"Music Recommendation Style: {music_info['description']} (Purpose: {music_info['purpose']})\n"
                f"\nSTRICT EXECUTION RULES:\n"
                f"1. DIRECT NAVIGATION: Use official game names (Snake Evolution, Memory Flip, Visual Memory, Chimp Test, Aim Trainer, Reaction Time, Tic Tac Toe, Rock Paper Scissors, Guess Number) to trigger direct buttons.\n"
                f"2. COPE & LIFT: The plan must start with coping/grounding and end with a positive 'lift'.\n"
                f"3. AUTHORITATIVE: Pick ONE concrete game or song. No lists or options.\n"
                f"4. {protocol_instruction}\n"
                f"5. NO TRIVIAL CHORES/SNACKS: No cooking, cleaning, or generic advice.\n"
                f"6. MUSIC LINK: Always end with a 'music' or 'calming_audio' step.\n"
                f"7. LIMIT: Exactly 3-4 steps total."
            ),
            expected_output="JSON array of objects with keys: 'type', 'description', 'time_minutes', and 'purpose'. 'description' must be a single, specific instruction, NO emojis.",
            agent=agent
        )

        crew = Crew(
            agents=[agent],
            tasks=[task],
            verbose=False
        )

        try:
            # Run the heavy generation in a thread
            response = await asyncio.to_thread(crew.kickoff)
            
            # Extract and parse JSON
            cleaned_text = str(response)
            if "```json" in cleaned_text:
                cleaned_text = cleaned_text.split("```json")[1].split("```")[0].strip()
            elif "```" in cleaned_text:
                cleaned_text = cleaned_text.split("```")[1].split("```")[0].strip()
            
            # Safely parse
            plan_data = json.loads(cleaned_text)
            if isinstance(plan_data, dict) and "plan" in plan_data:
                plan = plan_data["plan"]
            elif isinstance(plan_data, list):
                plan = plan_data
            else:
                raise ValueError("Unexpected JSON format from Agent")

            # 5. Post-Processing: Adaptive Modifiers & Metadata (Music/Games)
            plan = self._apply_adaptive_modifiers(plan, emotion, detected_intensity, text, risk_level, subtype)
            return await self._post_process_plan(plan, music_info['mood_key'])

        except Exception as e:
            self.logger.error(f"Agentic Planning Failed: {e}. Falling back to default protocol.")
            # Protocol Fallback for maximal system stability
            fallback_plan = [
                {"type": "breathing", "description": "Take 3 deep, slow breaths.", "time_minutes": 1, "purpose": "reset"},
                {"type": "affirmation", "description": "You're handling this well. Small steps matter.", "time_minutes": 1, "purpose": "support"},
                {"type": "music", "description": f"{music_info['description']}.", "time_minutes": 10, "purpose": "regulation"}
            ]
            return await self._post_process_plan(fallback_plan, music_info['mood_key'])

planner_agent = PlannerAgent()
