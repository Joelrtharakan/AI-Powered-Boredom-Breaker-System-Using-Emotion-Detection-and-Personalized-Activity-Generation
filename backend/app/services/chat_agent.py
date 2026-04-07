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

    async def _rank_memories(self, memories: dict, current_intensity: float) -> str:
        """Ranks retrieved memories based on similarity, recency, and intensity."""
        if not memories['documents'] or not memories['documents'][0]:
            return ""
        
        docs = memories['documents'][0]
        metas = memories['metadatas'][0]
        dist = memories['distances'][0] if 'distances' in memories else [0]*len(docs)
        
        ranked = []
        import time
        now = time.time()
        
        for i in range(len(docs)):
            # Score = (1 - distance) + recency_weight + intensity_weight
            sim_score = 1 - dist[i]
            rec_score = 1 / ( (now - metas[i]['timestamp']) / 3600 + 1 ) # decay over hours
            int_score = metas[i]['intensity']
            
            total_score = (sim_score * 0.5) + (rec_score * 0.3) + (int_score * 0.2)
            ranked.append((total_score, docs[i]))
            
        ranked.sort(key=lambda x: x[0], reverse=True)
        return "\n".join([f"- {r[1]}" for r in ranked[:3]])

    async def _summarize_interaction(self, text: str, emotion: str) -> str:
        """Creates a compact summary of an interaction for long-term storage."""
        # For efficiency, we use a simple heuristic summary or an LLM call
        return f"User expressed {emotion}: '{text[:100]}...'"

    async def generate_response(self, user_id: int, user_message: str, history: list = None, session_context: str = "") -> str:
        # 1. Guardrails
        is_safe, refusal_reason = await guardrail_service.analyze(user_message)
        if not is_safe: return refusal_reason

        # 2. Emotional Context
        analysis = emotion_analyzer.analyze(user_message)
        emotion = analysis.get("emotion", "neutral")
        intensity = analysis.get("intensity", 0.5)
        risk_level = analysis.get("risk_level", "LOW_NORMAL")

        # 3. Memory Pipeline (Enhanced)
        from app.services.chroma_service import chroma_service
        
        # A. Semantic Recall with Ranking
        raw_memories = chroma_service.query_user_memory(user_id=user_id, query_text=user_message, n_results=5)
        semantic_memory_text = await self._rank_memories(raw_memories, intensity)
        
        # B. Recent Transcript (Max 4 for token efficiency)
        transcript = ""
        if history:
            for msg in history[-4:]:
                role = "User" if msg.get("role") == "user" else "Luno"
                transcript += f"{role}: {msg.get('content')}\n"
        transcript += f"User: {user_message}\n"

        # C. Store Summarized Interaction
        summary = await self._summarize_interaction(user_message, emotion)
        chroma_service.add_user_memory(user_id=user_id, text=summary, metadata={"emotion": emotion, "intensity": intensity})

        # 4. Conversation State Logic
        # Simple states: Validation -> Exploration -> Activation
        state = "validation"
        if history and len(history) > 4:
            state = "activation"
        elif history and len(history) > 2:
            state = "exploration"

        # 5. CrewAI Call with Emotion-Conditioned Prompting
        agent = await asyncio.to_thread(
            Agent, 
            from_repository="empathetic-ai-companion", 
            llm=llm_service.crew_llm
        )

        task = Task(
            description=(
                f"They feel {emotion} (Intensity: {intensity}). State: {state}.\n"
                f"Recent Context:\n{transcript}\n"
                f"Relevant Past:\n{semantic_memory_text}\n"
                f"Rules: {self.persona_rules}\n"
                f"CRITICAL ANTI-REPETITION RULE: Look at the 'Recent Context'. Do NOT repeat the exact same phrases or suggestions. If you just suggested 'Focus playlist', suggest something ELSE like 'Zen Mode' or a different game. Vary your wording.\n"
                f"STATE INSTRUCTION: If in 'validation', acknowledge feelings deeply. If 'activation', gently nudge towards a positive action."
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
