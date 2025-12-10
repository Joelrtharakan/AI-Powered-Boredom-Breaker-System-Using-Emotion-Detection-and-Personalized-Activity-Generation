import requests
import json
from app.core.config import settings
import logging

class OpenRouterService:
    def __init__(self):
        self.api_key = settings.OPENROUTER_API_KEY
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"
        self.logger = logging.getLogger(__name__)
        # Default model: Mistral 7B (Free, Fast, Good Instruction Following)
        self.model = "mistralai/mistral-7b-instruct:free" 
        
    def generate(self, system_prompt: str, user_prompt: str, model: str = None) -> str:
        if not self.api_key:
            self.logger.warning("OPENROUTER_API_KEY not set. Returning mock response.")
            return self._get_fallback_response(system_prompt)

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "HTTP-Referer": "http://localhost:8000",
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
        
        import time
        max_retries = 3
        for attempt in range(max_retries):
            try:
                response = requests.post(self.base_url, headers=headers, json=data, timeout=10)
                response.raise_for_status()
                result = response.json()
                return result['choices'][0]['message']['content'].strip()
            except requests.exceptions.RequestException as e:
                self.logger.error(f"OpenRouter attempt {attempt+1} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(2) # Wait 2 seconds before retrying
                else:
                    return self._get_fallback_response(system_prompt)
            except Exception as e:
                self.logger.error(f"Unexpected LLM error: {e}")
                return self._get_fallback_response(system_prompt)
    
    def _get_fallback_response(self, system_prompt):
        s_lower = system_prompt.lower()
        if "affirmation" in s_lower:
            return "You are stronger than you think."
        if "plan" in s_lower or "activities" in s_lower:
             # Return a safe minimal JSON for planner
             return '{"plan": []}' 
        return "I am currently offline, but I hear you. Take a deep breath."

llm_service = OpenRouterService()
