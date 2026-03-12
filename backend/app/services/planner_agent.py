import json
import logging
import random
from app.services.llm_service import llm_service
from app.services.spotify_service import spotify_service
from app.services.emotion_ai import emotion_analyzer

class PlannerAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # SECTION 4: Music Intelligence
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    def _get_emotion_music(self, emotion: str, risk_level: str, subtype: str = None) -> dict:
        """Select music based on emotion/subtype. Enforces safety rules."""

        # ABSOLUTE RULES:
        # - No lyrical music in CRISIS or HIGH_DISTRESS
        # - No upbeat music in CRISIS
        # - No stimulating music in FATIGUE
        # - Music is supportive, not primary intervention

        music_map = {
            "sadness": {"description": "Soft piano, slow instrumental", "purpose": "emotional_comfort", "mood_key": "chill"},
            "fear": {"description": "Low tempo ambient, deep breathing tones", "purpose": "nervous_system_regulation", "mood_key": "chill"},
            "anger": {"description": "Rhythmic instrumental, controlled tempo", "purpose": "de_escalation", "mood_key": "chill"},
            "fatigue": {"description": "Ambient, white noise, rainfall", "purpose": "restoration", "mood_key": "chill"},
            "bored": {"description": "Upbeat, energetic music", "purpose": "stimulation", "mood_key": "energize"},
            "joy": {"description": "Celebratory, feel-good music", "purpose": "amplification", "mood_key": "happy"},
            "neutral": {"description": "Light background music", "purpose": "ambient", "mood_key": "chill"},
        }

        base = music_map.get(emotion, music_map["neutral"])

        # Subtype overrides
        if subtype == "ATTACHMENT":
            base["description"] = "Warm piano, acoustic, nostalgic tones"
            base["mood_key"] = "sad"

        # Safety overrides
        if risk_level == "CRISIS":
            base["description"] = "Soft instrumental (no lyrics)"
            base["mood_key"] = "chill"
        elif risk_level == "HIGH_DISTRESS":
            base["description"] = "60-70 BPM instrumental (no lyrics)"
            base["mood_key"] = "chill"
        elif risk_level == "FATIGUE":
            base["description"] = "Ambient rainfall or white noise"
            base["mood_key"] = "chill"

        return base

    def _inject_spotify(self, plan: list, mood_key: str) -> list:
        """Attach Spotify playlist metadata to music/calming_audio steps."""
        for step in plan:
            if step.get("type") in ["music", "calming_audio"]:
                try:
                    playlists = spotify_service.get_mood_playlists(mood_key, limit=1)
                    if playlists:
                        if "metadata" not in step:
                            step["metadata"] = {}
                        step["metadata"]["spotify_uri"] = playlists[0]["uri"]
                        step["metadata"]["playlist_name"] = playlists[0]["name"]
                        step["metadata"]["image"] = playlists[0].get("image")
                        step["description"] += f" (Try: {playlists[0]['name']})"
                except Exception as e:
                    self.logger.warning(f"Spotify injection failed: {e}")
        return plan

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # SECTION 5: Adaptive Plan Modifier
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    def _apply_adaptive_modifiers(self, plan: list, emotion: str, intensity: float, text: str, risk_level: str, subtype: str = None) -> list:
        """Dynamically adapt plan steps based on emotion + intensity."""

        plan_types = [s.get("type", "") for s in plan]
        text_lower = text.lower() if text else ""

        # Section 6: Social Intelligence
        # If sadness subtype = ATTACHMENT: Social step must be first or second.
        # If loneliness detected: Add “Send a short message” suggestion.
        loneliness_markers = ["lonely", "alone", "no one", "nobody", "isolated", "by myself"]
        is_lonely = any(m in text_lower for m in loneliness_markers) or subtype == "ATTACHMENT"
        
        if is_lonely and "social" not in plan_types and risk_level not in ["CRISIS", "BOREDOM", "LOW_NORMAL"]:
            social_step = {
                "type": "social",
                "description": "Send a short message to someone you trust — even a quick text helps.",
                "time_minutes": 5,
                "purpose": "connection"
            }
            if subtype == "ATTACHMENT":
                plan.insert(min(1, len(plan)), social_step) # First or second
                plan_types.insert(min(1, len(plan_types)), "social")
            else:
                plan.append(social_step)
                plan_types.append("social")

        # Rule 1: intensity > 0.85 → Add grounding step and warmth if not already present
        if intensity > 0.85 and "micro_task" not in plan_types and risk_level not in ["BOREDOM", "LOW_NORMAL"]:
            plan.insert(min(1, len(plan)), {
                "type": "micro_task",
                "description": "5-4-3-2-1 Grounding: Name 5 things you see, 4 you can touch, 3 you hear.",
                "time_minutes": 2,
                "purpose": "grounding"
            })
            plan_types.insert(min(1, len(plan_types)), "micro_task")

        if intensity > 0.85 and emotion == "sadness" and "environment_adjustment" not in plan_types and risk_level not in ["BOREDOM", "LOW_NORMAL"]:
            plan.append({
                "type": "environment_adjustment",
                "description": "Wrap yourself in a blanket or make some warm tea.",
                "time_minutes": 2,
                "purpose": "warmth_comfort"
            })
            plan_types.append("environment_adjustment")

        # Intensity > 0.95 -> Strengthen social support
        if intensity > 0.95 and "social" not in plan_types and risk_level not in ["BOREDOM", "LOW_NORMAL"]:
             plan.append({
                "type": "social",
                "description": "Reach out for stronger support. Call a friend or helpline.",
                "time_minutes": 5,
                "purpose": "connection"
            })
             plan_types.append("social")

        # Rule 2: fear → Ensure breathing is Step 1, longer if high intensity
        if emotion == "fear":
            if plan and plan[0].get("type") != "breathing":
                plan.insert(0, {
                    "type": "breathing",
                    "description": "Slow, deep breaths. Inhale for 4, exhale for 6.",
                    "time_minutes": 3 if intensity > 0.85 else 2,
                    "purpose": "nervous_system_reset"
                })
            elif plan and plan[0].get("type") == "breathing" and intensity > 0.85:
                plan[0]["time_minutes"] = max(plan[0].get("time_minutes", 0), 3)

        # Rule 4: anger → Add physical reset
        if emotion == "anger" and "activity" not in plan_types and risk_level not in ["CRISIS"]:
            plan.append({
                "type": "activity",
                "description": "Stretch for 1 minute or take a short walk.",
                "time_minutes": 2,
                "purpose": "physical_release"
            })

        # Section 8: Recovery Loop Question
        if risk_level not in ["BOREDOM", "LOW_NORMAL"] and "check_in" not in [s.get("type", "") for s in plan]:
            plan.append({
                "type": "check_in",
                "description": "Short check-in: Do you feel slightly better?",
                "time_minutes": 1,
                "purpose": "recovery_check"
            })

        return plan

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # MAIN PLAN GENERATOR
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    async def generate_plan(self, mood: str, intensity: float, user_id: int = None, interests: list = None, text: str = "", subtype: str = None, ns_state: str = None, risk_level: str = None):
        """
        Generates a structured micro-intervention plan based on emotion + risk.
        Follows the 5-section production specification.
        """
        # 1. RISK ASSESSMENT
        # 1. OPTIMIZED RISK/EMOTION ASSESSMENT
        if subtype or ns_state or risk_level:
            # We already have the metadata, use it! (HUGE SPEED BOOST)
            analysis = {
                "risk_level": risk_level or "LOW_NORMAL",
                "emotion": mood.split("(Detected Emotion:")[1].strip().replace(")", "") if "(Detected Emotion:" in mood else "neutral",
                "subtype": subtype,
                "nervous_system_state": ns_state or "regulated",
                "intensity": intensity
            }
        else:
            # Fallback for old calls or missing data
            analysis = emotion_analyzer.analyze(text) if text else {"risk_level": "LOW_NORMAL", "emotion": "neutral", "intensity": 0.5, "subtype": None, "nervous_system_state": "regulated"}
        
        risk_level = analysis.get("risk_level", "LOW_NORMAL")
        emotion = analysis.get("emotion", "neutral")
        subtype = analysis.get("subtype", None)
        ns_state = analysis.get("nervous_system_state", "regulated")
        detected_intensity = analysis.get("intensity", intensity)

        self.logger.info(f"Planner [Fast Track]: risk={risk_level}, emotion={emotion}, subtype={subtype}, intensity={detected_intensity}, ns_state={ns_state}")

        # ⚖️ LAYER 2 SAFETY OVERRIDE: Work Context
        work_keywords = ["work", "assignment", "submit", "project", "deadline", "study", "exam", "task", "job"]
        if risk_level == "HIGH_DISTRESS" and any(w in text.lower() for w in work_keywords):
            self.logger.info("Override: HIGH_DISTRESS → TASK_BLOCKED (work context)")
            risk_level = "TASK_BLOCKED"

        # Get emotion-matched music
        music_info = self._get_emotion_music(emotion, risk_level, subtype)

        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # SECTION 3: Protocol-Based Plan Generation
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        # 🚫 NO EMOTION DETECTED — Random/Nonsensical input
        if risk_level == "NO_EMOTION":
            return [{
                "type": "no_emotion",
                "description": "I couldn't detect any emotion from that. Try expressing how you're really feeling — I'm here to help! 💬",
                "time_minutes": 0,
                "purpose": "prompt_user",
                "no_plan": True
            }]

        # 🚨 CRISIS PROTOCOL
        if risk_level == "CRISIS":
            plan = [
                {"type": "breathing", "description": "Box Breathing: Inhale 4s, Hold 4s, Exhale 4s, Hold 4s.", "time_minutes": 2, "purpose": "immediate_grounding"},
                {"type": "micro_task", "description": "5-4-3-2-1 Grounding: Name 5 things you see, 4 you can touch, 3 you hear.", "time_minutes": 2, "purpose": "grounding"},
                {"type": "social", "description": "Reach out to a trusted friend, family member, or helpline.", "time_minutes": 5, "purpose": "safety_connection"},
                {"type": "environment_adjustment", "description": "Go to a safe, comfortable space. Wrap yourself in a blanket.", "time_minutes": 0, "purpose": "safety_environment"},
                {"type": "calming_audio", "description": f"{music_info['description']} — only after you feel grounded.", "time_minutes": 10, "purpose": "supportive_music"}
            ]
            plan = self._apply_adaptive_modifiers(plan, emotion, detected_intensity, text, risk_level, subtype)
            return self._inject_spotify(plan, music_info['mood_key'])

        # 😰 HIGH DISTRESS PROTOCOL
        if risk_level == "HIGH_DISTRESS":
            plan = [
                {"type": "breathing", "description": "Focus on your breath. Long exhale — inhale 4s, exhale 6s.", "time_minutes": 3, "purpose": "calming"},
                {"type": "micro_task", "description": "5-4-3-2-1 Grounding: Name 5 things you see, 4 you feel, 3 you hear.", "time_minutes": 2, "purpose": "grounding"},
                {"type": "calming_audio", "description": f"{music_info['description']}.", "time_minutes": 10, "purpose": "nervous_system_regulation"}
            ]
            plan = self._apply_adaptive_modifiers(plan, emotion, detected_intensity, text, risk_level, subtype)
            return self._inject_spotify(plan, music_info['mood_key'])

        # 💤 FATIGUE PROTOCOL
        if risk_level == "FATIGUE":
            plan = [
                {"type": "rest", "description": "Close your eyes and rest for 15 minutes. No screens.", "time_minutes": 15, "purpose": "recovery"},
                {"type": "activity", "description": "Drink a glass of water.", "time_minutes": 1, "purpose": "hydration"},
                {"type": "calming_audio", "description": f"{music_info['description']}.", "time_minutes": 10, "purpose": "soothing"}
            ]
            plan = self._apply_adaptive_modifiers(plan, emotion, detected_intensity, text, risk_level, subtype)
            return self._inject_spotify(plan, music_info['mood_key'])

        # 🚧 TASK BLOCKED PROTOCOL
        if risk_level == "TASK_BLOCKED":
            plan = [
                {"type": "breathing", "description": "Take 3 deep breaths to clear the frustration.", "time_minutes": 1, "purpose": "calm_reset"},
                {"type": "micro_task", "description": "Identify just ONE small step (e.g., open the doc).", "time_minutes": 2, "purpose": "clarity"},
                {"type": "activity", "description": "Work for 5 minutes only. You can stop after.", "time_minutes": 5, "purpose": "momentum"},
                {"type": "calming_audio", "description": "Focus instrumental music — no lyrics.", "time_minutes": 10, "purpose": "focus_support"}
            ]
            plan = self._apply_adaptive_modifiers(plan, emotion, detected_intensity, text, risk_level, subtype)
            return self._inject_spotify(plan, music_info['mood_key'])

        # 🎮 BOREDOM PROTOCOL
        if risk_level == "BOREDOM":
            games = ["Snake Evolution", "Memory Flip", "Chimp Test", "Visual Memory", "Number Guess", "Aim Trainer", "Reaction Time"]
            game1 = random.choice(games)

            plan = [
                {"type": "game", "description": f"Jump into {game1} to wake up your brain!", "time_minutes": 5, "purpose": "activation"},
                {"type": "micro_task", "description": "Do something totally new for 2 minutes (doodle, stretch, dance).", "time_minutes": 2, "purpose": "novelty"},
                {"type": "music", "description": f"{music_info['description']}.", "time_minutes": 10, "purpose": "stimulation"}
            ]
            return self._inject_spotify(plan, music_info['mood_key'])

        # 😟 MODERATE DISTRESS PROTOCOL (UPGRADED)
        if risk_level == "MODERATE_DISTRESS":
            plan = [
                {"type": "calming_audio", "description": f"{music_info['description']}.", "time_minutes": 10, "purpose": "emotional_regulation"},
                {"type": "micro_task", "description": "Take a moment — place your hand on your chest and breathe slowly.", "time_minutes": 2, "purpose": "grounding"},
            ]
            plan = self._apply_adaptive_modifiers(plan, emotion, detected_intensity, text, risk_level, subtype)
            return self._inject_spotify(plan, music_info['mood_key'])

        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # LOW_NORMAL — Minimal / Optional intervention
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        # Check for Positive Expression
        positive_keywords = ["love", "grateful", "blessed", "god is good", "amazing day", "good day", "excited", "happy"]
        is_positive = any(k in mood.lower() for k in positive_keywords) or (text and any(k in text.lower() for k in positive_keywords))

        if is_positive:
            # POSITIVE: Affirmation + optional light game
            games = ["Snake Evolution", "Memory Flip", "Chimp Test", "Visual Memory", "Number Guess", "Aim Trainer", "Reaction Time", "Tic Tac Toe", "Rock Paper Scissors"]
            plan = [
                {"type": "affirmation", "description": "Take a moment to celebrate this feeling. You deserve it!", "time_minutes": 2, "purpose": "positive_reinforcement"},
                {"type": "game", "description": f"Play {random.choice(games)} for some extra fun.", "time_minutes": 5, "purpose": "enjoyment"}
            ]
            return plan

        # NEUTRAL: No heavy intervention — offer optional engagement only
        plan = [
            {"type": "affirmation", "description": "You're doing just fine. Here if you need anything.", "time_minutes": 0, "purpose": "acknowledgement"}
        ]
        return plan

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # LLM-BASED PLAN (for complex/ambiguous cases — future use)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    async def _generate_llm_plan(self, mood: str, intensity: float, risk_level: str, text: str, is_positive: bool):
        """Fallback to LLM for complex cases. Not used in protocol-based flow."""

        system_prompt = f"""
🧠 Emotion-Aware Regulation Planner

Generate a small, psychologically aligned action plan.

Current State: {risk_level} (Mood: {mood})
User Input: "{text}"

RULES:
- CRISIS/HIGH_DISTRESS: Safety only. No games.
- TASK_BLOCKED: Focus recovery. No relaxation.
- FATIGUE: Rest only. No cognitive load.
- BOREDOM: Games + novelty.
- MODERATE: Calming audio + grounding.
- LOW_NORMAL: Minimal. Affirmation only.

OUTPUT: JSON array only.
Valid Types: "breathing", "micro_task", "activity", "music", "affirmation", "game", "social", "rest", "environment_adjustment", "calming_audio".
"""

        user_prompt = f"""
User Text: "{text}"
Mood: {mood}
Intensity: {intensity}
Risk Level: {risk_level}
Is Positive: {is_positive}

Generate JSON plan:
"""
        try:
            response_text = await llm_service.generate(system_prompt, user_prompt)
            cleaned_text = response_text
            if "```json" in response_text:
                cleaned_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                cleaned_text = response_text.split("```")[1].split("```")[0].strip()

            parsed = json.loads(cleaned_text)
            if isinstance(parsed, dict) and "plan" in parsed:
                parsed = parsed["plan"]
            if not isinstance(parsed, list) or len(parsed) == 0:
                raise ValueError("Invalid LLM plan")
            return parsed

        except Exception as e:
            self.logger.error(f"LLM plan failed: {e}")
            return None

planner_agent = PlannerAgent()
