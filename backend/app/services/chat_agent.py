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
        EMPATHY-FIRST PROTOCOL:
        1. LISTEN & VALIDATE: Acknowledge the user's specific emotion. Mirror their feelings to show you truly understand.
        2. CONVERSE: Ask meaningful, open-ended follow-up questions to keep them sharing (e.g., "What's been the hardest part of your day?" or "How are you holding up with all that?").
        3. DELAY SUGGESTIONS: Never suggest a task or activity in the first few turns unless the user explicitly asks for one. Let them vent first.

        STRICT FORMATTING RULE:
        Keep responses warm, concise (1-2 sentences), and conversational. You are a listener first, a guide second.

        TASK SUGGESTION PROTOCOL (ONLY FOR 'ACTIVATION' STATE):
        - ANXIOUS/OVERWHELMED: Suggest 'Zen Mode' or a 'Chill' playlist as a quiet escape.
        - SAD/LONELY/TIRED: Suggest 'Happy' or 'Chill' playlists for comfort.
        - BORED/UNMOTIVATED: Suggest 'Snake', 'Memory Flip', or an 'Energize' playlist.
        - ANGRY/FRUSTRATED: Suggest 'Tic Tac Toe' for a distraction or 'Zen Mode' to vent.
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
        # Deepened states: Validation -> Exploration -> Activation
        state = "validation"
        if history and len(history) > 6:
            state = "activation"
        elif history and len(history) > 3:
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
                f"STATE INSTRUCTION: \n"
                f"- If in 'validation', focus 100% on listening. Ask a gentle follow-up question to learn more. Do NOT suggest any activities.\n"
                f"- If in 'exploration', continue the conversation. You can mention that you have tools to help, but keep the focus on their story.\n"
                f"- If in 'activation' or if they ALREADY asked for something to do, suggest a specific activity from the 'TASK SUGGESTION PROTOCOL'."
            ),
            expected_output="A deeply empathetic, high-EQ response that sounds like a supportive friend's text (1-2 sentences).",
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
