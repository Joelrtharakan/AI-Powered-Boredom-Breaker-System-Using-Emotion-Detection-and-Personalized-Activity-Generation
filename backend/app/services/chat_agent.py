import re
from app.services.llm_service import llm_service
from app.services.emotion_ai import emotion_analyzer
from app.services.guardrail_service import guardrail_service

class ChatAgent:
    def __init__(self):
        # Base Persona
        self.base_system_prompt = """You are Luno, an empathetic and supportive AI companion.
Your objective is to provide a safe space, support the user's emotional wellbeing, and act as a gentle confidant.
Always be warm, understanding, and validating.

STRICT FORMATTING RULE:
Keep your responses EXTREMELY concise and conversational. Act like you are text messaging a friend.
NEVER write more than 1 to 2 short sentences unless explicitly asked to explain something. Do not write multiple paragraphs.
"""

    async def generate_response(self, user_message: str, history: list = None) -> str:
        # 0. Execute Robust Multi-Layer Guardrail
        is_safe, refusal_reason = await guardrail_service.analyze(user_message)
        if not is_safe:
            return refusal_reason

        # 1. Analyze Emotion & Risk (V14 Model)
        try:
            analysis = emotion_analyzer.analyze(user_message)
            risk_level = analysis.get("risk_level", "LOW_NORMAL")
            emotion = analysis.get("emotion", "neutral")
            strategy = analysis.get("strategy", "Provide clear help.")
        except Exception as e:
            print(f"Emotion Analysis Failed: {e}")
            risk_level = "LOW_NORMAL"
            emotion = "neutral"
            strategy = "Provide warm, comforting support."

        # 2. Construct Context-Aware Prompt
        dynamic_instruction = f"""
[CURRENT CONTEXT]
User Emotion: {emotion}
Risk Level: {risk_level}
Required Strategy: {strategy}

[RESPONSE FORMAT GUIDANCE]
"""
        if risk_level in ["CRISIS", "HIGH_DISTRESS"]:
            dynamic_instruction += """
1. Acknowledge & Validate (show deep empathy)
2. Support/Grounding (slow the moment)
3. Gentle Next Step (encourage professional connection)
Keep it under 2 sentences. Be exceptionally warm.
"""
        elif risk_level == "MODERATE_DISTRESS":
            dynamic_instruction += """
1. Validate the feeling. Be extremely comforting.
2. Offer supportive guidance or a therapeutic perspective.
Keep it strictly under 2 sentences.
"""
        else:
            dynamic_instruction += """
Respond warmly and conversationally in just 1 or 2 short sentences. Act like a friend texting back.
"""
            
        dynamic_instruction += """
When suggesting activities:
- If suggesting music, explicitly name one of these EXACT playlists: Chill, Focus, Energize, Sad, Happy, Christian, or Top Hits. (e.g., "try the Chill playlist")
- If suggesting a game, explicitly name one of these EXACT games: Snake, Tic Tac Toe, Memory Flip, or Aim Trainer. (e.g., "let's play Snake")
"""

        full_system_prompt = self.base_system_prompt + dynamic_instruction
        
        # 3. Memory Pipeline
        full_transcript = ""
        if history:
            # We already have the previous messages. Let's pick the last 6 for context depth.
            context_msgs = history[-6:]
            for msg in context_msgs:
                content = msg.get('content', '')
                # Prevent "API Error" fallback messages from poisoning the AI's contextual memory
                if "API Error" in content or "Trouble connecting to my brain" in content:
                    continue
                    
                role_label = "User" if msg.get("role") == "user" else "Assistant"
                full_transcript += f"{role_label}: {content}\n"
        
        full_transcript += f"User: {user_message}\nAssistant: [SYSTEM NOTE: Remember to reply with a maximum of 2 short sentences.]\n"

        # 4. Call LLM
        response = await llm_service.generate(
            system_prompt=full_system_prompt,
            user_prompt=full_transcript
        )
        
        # Clean artifacts
        cleaned = re.sub(r'\[.*?\]', '', response) 
        cleaned = cleaned.replace("<s>", "").replace("</s>", "").strip()
        # Edge case artifacting on generic LLM
        if cleaned.startswith("Assistant:"):
            cleaned = cleaned[10:].strip()
            
        return cleaned

chat_agent = ChatAgent()
