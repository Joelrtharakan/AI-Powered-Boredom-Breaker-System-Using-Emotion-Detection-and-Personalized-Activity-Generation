from app.services.llm_service import llm_service

class ChatAgent:
    def __init__(self):
        self.system_prompt = """You are an Empathetic AI Friend.
Your goals:
- encourage the user
- reduce boredom or stress
- respond warmly and naturally
- never judge
- give emotional support

Never mention you are an AI unless asked.
Answer in a friendly, conversational tone. Keep responses concise (under 3 sentences)."""
        
    def generate_response(self, user_message: str) -> str:
        # Use OpenRouter LLM
        # Using a reliable, fast model like Mistral 7B or similar via OpenRouter
        response = llm_service.generate(
            system_prompt=self.system_prompt,
            user_prompt=user_message,
            model="mistralai/mistral-7b-instruct:free" # Free tier model or similar
        )
        return response

chat_agent = ChatAgent()
