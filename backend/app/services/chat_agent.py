import re
import asyncio
import logging
from crewai import Agent, Task, Crew
from app.services.llm_service import llm_service
from app.services.emotion_ai import emotion_analyzer
from app.services.guardrail_service import guardrail_service

class ChatAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        # Your specific persona constraints
        self.persona_rules = """
        STRICT FORMATTING RULE:
        Keep responses EXTREMELY concise (1-2 sentences). Act like you are text messaging a friend.
        
        MAPPING RULES:
        - If anxious/scared: Suggest 'Chill playlist' or 'Zen Mode'.
        - If sad/lonely: Suggest 'Happy', 'Christian', or 'Chill' playlist.
        - If bored/unmotivated: Suggest 'Energize' or 'Top Hits' playlist, or 'Snake'/'Memory Flip'.
        - If angry/frustrated: Suggest 'Focus playlist', 'Zen Mode', or 'Tic Tac Toe'.
        """

    async def generate_response(self, user_message: str, history: list = None, session_context: str = "") -> str:
        # 1. Guardrails
        is_safe, refusal_reason = await guardrail_service.analyze(user_message)
        if not is_safe: return refusal_reason

        # 2. Emotional Context
        analysis = emotion_analyzer.analyze(user_message)
        emotion = analysis.get("emotion", "neutral")
        risk_level = analysis.get("risk_level", "LOW_NORMAL")

        # 3. Memory Pipeline
        transcript = ""
        if history:
            for msg in history[-6:]:
                role = "User" if msg.get("role") == "user" else "Luno"
                transcript += f"{role}: {msg.get('content')}\n"
        transcript += f"User: {user_message}\n"

        # 4. CrewAI Call
        agent = await asyncio.to_thread(
            Agent, 
            from_repository="empathetic-ai-companion", 
            llm=llm_service.crew_llm
        )

        task = Task(
            description=(
                f"A friend is reaching out. They feel {emotion}.\n"
                f"History:\n{transcript}\n"
                f"Rules: {self.persona_rules}\n"
                f"Session Summary: {session_context}"
            ),
            expected_output="A warm, text-style response (1-2 sentences max).",
            agent=agent
        )

        crew = Crew(agents=[agent], tasks=[task], verbose=False)

        try:
            response = await asyncio.to_thread(crew.kickoff)
            cleaned = re.sub(r'\[.*?\]', '', str(response)).strip()
            return cleaned if not cleaned.startswith("Luno:") else cleaned[5:].strip()
        except Exception as e:
            self.logger.error(f"Luno Chat Error: {e}")
            return "I'm here for you, always. Tell me more?"

chat_agent = ChatAgent()
