import asyncio
import json
import os
import sys
from unittest.mock import MagicMock

# 1. DEEP STUB Emotion AI BEFORE any imports
# This prevents the transformers library from ever being loaded
mock_emotion = MagicMock()
mock_emotion.analyze.return_value = {"mood": "neutral", "emotion": "neutral", "intensity": 0.5}
sys.modules["app.services.emotion_ai"] = MagicMock(emotion_analyzer=mock_emotion)

# 2. Load ENV and Patch CrewAI
from dotenv import load_dotenv
load_dotenv()
creawai_token = os.getenv("CREWAI_AUTH_TOKEN")
if creawai_token:
    os.environ["CREWAI_AUTH_TOKEN"] = creawai_token
    try:
        import crewai.utilities.agent_utils
        from crewai.cli.plus_api import PlusAPI
        crewai.utilities.agent_utils._create_plus_client_hook = lambda: PlusAPI(api_key=creawai_token)
    except: pass

# Ensure app is in path
sys.path.append(os.getcwd())

# Force environment variables for CrewAI
os.environ["OTEL_SDK_DISABLED"] = "true"
os.environ["CREWAI_TELEMETRY_OPT_OUT"] = "true"

print("--- Importing Agents (With System Stubs) ---")
from app.services.planner_agent import planner_agent
from app.services.router_agent import router_agent
print("--- Agents Imported Successfully ---")

async def run_tests():
    test_cases = [
        {
            "text": "I'm so angry I could scream, everything is going wrong!", 
            "mood_data": {"mood": "angry", "emotion": "anger", "intensity": 0.9, "decision_source": "manual"},
            "interests": ["Coding", "Gaming"]
        },
        {
            "text": "I feel really anxious about my exam tomorrow, my heart is racing.", 
            "mood_data": {"mood": "anxious", "emotion": "fear", "intensity": 0.85, "decision_source": "manual"},
            "interests": ["Music", "Meditation"]
        },
        {
            "text": "I am completely drained and have zero energy left.", 
            "mood_data": {"mood": "exhausted", "emotion": "fatigue", "intensity": 0.95, "decision_source": "manual"},
            "interests": ["Nature", "Photography"]
        },
        {
            "text": "i am going to sucide", 
            "mood_data": {"mood": "sad", "emotion": "sadness", "intensity": 0.99, "risk_level": "CRISIS", "decision_source": "manual"},
            "interests": ["Gaming"]
        }
    ]

    print("\n🚀 STARTING PLAN GENERATION TEST 🚀\n")

    for case in test_cases:
        print(f"Testing Mood: {case['mood_data']['emotion'].upper()}")
        
        try:
            plan = await router_agent.route(
                mood_data=case['mood_data'],
                user_id=1,
                interests=case['interests'],
                text=case['text']
            )

            print(f"Generated Plan for {case['mood_data']['emotion']}:")
            for i, step in enumerate(plan, 1):
                type_ = step.get('type', '???').upper()
                desc = step.get('description', 'No description')
                print(f"  {i}. {type_:<15} | {desc}")
            
            print("\n" + "="*80 + "\n")

        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(run_tests())
