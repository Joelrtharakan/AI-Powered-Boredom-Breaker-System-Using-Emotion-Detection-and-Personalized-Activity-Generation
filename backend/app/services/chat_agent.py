import re
from app.services.llm_service import llm_service

class ChatAgent:
    def __init__(self):
        self.system_prompt = """You are a chill, empathetic friend.
        
STRICT RULES:
1. **Be Concise:** Keep responses short (1-2 sentences max). No long paragraphs.
2. **Be Natural:** Chat like a real friend. Don't be formal or robotic. Don't start with "Hello there! I'm here to...". Just say "Hey" or answer directly.
3. **Scope:** Chat about feelings, hobbies, boredom, and life. If asked about code/math/homework, just say "Nah, let's just chill instead." or "I'm just here to hang out, not do homework."
4. **Safety:** If self-harm is mentioned, suggest professional help warmly.

Example bad response: "Hello! As an AI companion, I can help you with..."
Example good response: "Hey! That sounds rough. Want to talk about it?"
"""
        
    async def generate_response(self, user_message: str) -> str:
        # Use OpenRouter LLM
        # Using a reliable, fast model like Mistral 7B or similar via OpenRouter
        response = await llm_service.generate(
            system_prompt=self.system_prompt,
            user_prompt=user_message
        )
        
        # Clean artifacts
        # Remove [OUT], [INST], [ASSISTANT], [OU], <s>, </s> and any other bracketed text that looks like a tag
        cleaned = re.sub(r'\[.*?\]', '', response) 
        cleaned = cleaned.replace("<s>", "").replace("</s>", "").strip()
        return cleaned

chat_agent = ChatAgent()
