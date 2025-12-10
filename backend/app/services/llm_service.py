import requests
import json
from app.core.config import settings
import logging

class OpenRouterService:
    def __init__(self):
        self.api_key = settings.OPENROUTER_API_KEY
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"
        self.logger = logging.getLogger(__name__)
        # Default model (TinyLlama or similar efficient model)
        self.model = "openai/gpt-3.5-turbo" # Default fallback, user can change to any openrouter model ID
        
    def generate(self, system_prompt: str, user_prompt: str, model: str = None) -> str:
        if not self.api_key:
            self.logger.warning("OPENROUTER_API_KEY not set. Returning mock response.")
            return "I'm a placeholder AI response because no API key was configured."

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "HTTP-Referer": "http://localhost:8000", # Optional, for including your app on openrouter.ai rankings.
            "X-Title": settings.PROJECT_NAME,
            "Content-Type": "application/json"
        }
        
        data = {
            "model": model or self.model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ]
        }
        
        try:
            response = requests.post(self.base_url, headers=headers, json=data)
            response.raise_for_status()
            result = response.json()
            return result['choices'][0]['message']['content'].strip()
        except Exception as e:
            self.logger.error(f"OpenRouter generation failed: {e}")
            return f"Sorry, I couldn't think of a response right now. (Error: {str(e)})"

llm_service = OpenRouterService()
