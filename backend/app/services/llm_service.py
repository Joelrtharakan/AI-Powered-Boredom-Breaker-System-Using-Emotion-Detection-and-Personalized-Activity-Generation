import httpx
import json
import logging
import asyncio
import os
from app.core.config import settings
from crewai import LLM

# Disable CrewAI Telemetry
os.environ["OTEL_SDK_DISABLED"] = "true"
os.environ["CREWAI_TELEMETRY_OPT_OUT"] = "true"
os.environ["CREWAI_COLLECT_TELEMETRY"] = "false"

class OpenRouterService:
    def __init__(self):
        self.api_key = settings.OPENROUTER_API_KEY
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"
        self.logger = logging.getLogger(__name__)
        # Default model: Gemini 2.0 Flash (Stable)
        self.model = "google/gemini-2.0-flash-001" 
        self.crew_model = f"openrouter/{self.model}"
        
        # CrewAI LLM instance 
        api_key = self.api_key if self.api_key else "dummy_key"
        self.crew_llm = LLM(
            model=self.crew_model,
            base_url="https://openrouter.ai/api/v1",
            api_key=api_key,
            temperature=0.7,
            timeout=20,
            max_retries=1
        )
        
    async def generate(self, system_prompt: str, user_prompt: str, model: str = None, timeout: float = 10.0) -> str:
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
            "max_tokens": 150, 
            "temperature": 0.7,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ]
        }
        
        max_retries = 1
        async with httpx.AsyncClient(timeout=timeout) as client:
            for attempt in range(max_retries):
                try:
                    response = await client.post(self.base_url, headers=headers, json=data)
                    response.raise_for_status()
                    result = response.json()
                    content = result.get('choices', [{}])[0].get('message', {}).get('content', '')
                    return content.strip() if content else ""
                except httpx.HTTPStatusError as e:
                    print(f"❌ OpenRouter HTTP Error: {e.response.status_code} - {e.response.text}")
                    self.logger.error(f"OpenRouter HTTP Error: {e.response.status_code} - {e.response.text}")
                    return self._get_fallback_response(system_prompt)
                except httpx.RequestError as e:
                    print(f"❌ OpenRouter Network Error: {e}")
                    self.logger.error(f"OpenRouter Network Error: {e}")
                    if attempt < max_retries - 1:
                        await asyncio.sleep(2)
                    else:
                        print("❌ Max retries reached. Falling back.")
                        return self._get_fallback_response(system_prompt)
                except Exception as e:
                    print(f"❌ Unexpected LLM error: {e}")
                    self.logger.error(f"Unexpected LLM error: {e}")
                    import traceback
                    traceback.print_exc()
                    return self._get_fallback_response(system_prompt)
    
    def _get_fallback_response(self, system_prompt):
        s_lower = system_prompt.lower()
        if "plan" in s_lower or "json" in s_lower:
             # Return a safe minimal JSON for planner
             return '{"plan": []}' 
        if "affirmation" in s_lower:
            return "You are stronger than you think."
        print("⚠️ DEBUG: Using Fallback Response")
        return "I am currently having trouble connecting to my brain (API Error). Please try again or check the server logs."

llm_service = OpenRouterService()
