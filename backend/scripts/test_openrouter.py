import httpx
import asyncio
import os

# Load key from environment or .env file if available
from app.core.config import settings

# Do not hardcode API keys here!
API_KEY = settings.OPENROUTER_API_KEY
if not API_KEY:
    # Fallback for manual testing if .env not loaded by app config
    API_KEY = os.getenv("OPENROUTER_API_KEY", "")

URL = "https://openrouter.ai/api/v1/chat/completions"
# Using a model that should work on free tier
MODEL = "mistralai/mistral-7b-instruct-v0.1"

async def test_key():
    if not API_KEY or "sk-or-" not in API_KEY:
        print("❌ ERROR: OPENROUTER_API_KEY not found in environment variables.")
        print("Please set it: export OPENROUTER_API_KEY='your_key_here'")
        return

    print(f"Testing API Key: {API_KEY[:10]}...")
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:8000",
        "X-Title": "Boredom Breaker Test"
    }
    
    data = {
        "model": MODEL,
        "messages": [{"role": "user", "content": "Hello, are you online?"}],
    }
    
    async with httpx.AsyncClient() as client:
        try:
            print(f"Sending request to {URL} with model {MODEL}...")
            response = await client.post(URL, headers=headers, json=data)
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.text}")
            
            if response.status_code == 200:
                print("✅ API Key is VALID and Model is WORKING!")
            elif response.status_code == 401:
                print("❌ API Key is INVALID (401 Unauthorized)")
            elif response.status_code == 402:
                print("❌ Insufficient Credits (402 Payment Required)")
            elif response.status_code == 404:
                print("❌ Model Not Found or Endpoint Wrong (404)")
            else:
                print(f"❌ Other Error: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Network/Client Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_key())
