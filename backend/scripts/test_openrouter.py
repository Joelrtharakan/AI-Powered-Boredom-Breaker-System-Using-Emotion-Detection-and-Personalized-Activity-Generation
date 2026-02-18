import httpx
import asyncio
import os

API_KEY = "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"
URL = "https://openrouter.ai/api/v1/chat/completions"
# Using a model that should work on free tier
MODEL = "mistralai/mistral-7b-instruct-v0.1"

async def test_key():
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
