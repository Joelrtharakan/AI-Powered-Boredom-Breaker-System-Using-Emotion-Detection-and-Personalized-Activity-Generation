import re
from app.services.llm_service import llm_service

from app.services.emotion_ai import emotion_analyzer

class ChatAgent:
    def __init__(self):
        # Base Persona
        self.base_system_prompt = """You are a high-reliability AI assistant focused on understanding intent, context, and user wellbeing.
Your objective is to produce the most helpful, accurate, and appropriate response for the user's situation.

CORE RULES:
1. **Understand before advising:** Validate feelings first if distress is present.
2. **Be Natural & Concise:** Chat like a thoughtful human expert. Avoid robotic phrasing.
3. **Safety First:** If risk is detected, prioritize safety over all else.
"""

    async def generate_response(self, user_message: str, history: list = None) -> str:
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
            strategy = "Provide clear, accurate, efficient help."

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
3. Gentle Next Step (encourage safety/connection)
Keep it under 3 sentences. Be warm and present.
"""
        elif risk_level == "MODERATE_DISTRESS":
            dynamic_instruction += """
1. Validate the feeling.
2. Offer supportive guidance or a simple perspective.
Keep it friendly and concise.
"""
        else:
            dynamic_instruction += """
Directly answer the user's input. Be friendly and engaging.
If it's a casual chat, just hang out.
"""

        full_system_prompt = self.base_system_prompt + dynamic_instruction
        
        # 3. Memory Pipeline
        full_transcript = ""
        if history:
            # We already have the previous messages. Let's pick the last 6 for context depth.
            context_msgs = history[-6:]
            for msg in context_msgs:
                role_label = "User" if msg.get("role") == "user" else "Assistant"
                full_transcript += f"{role_label}: {msg.get('content')}\n"
        
        full_transcript += f"User: {user_message}\nAssistant:"

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
