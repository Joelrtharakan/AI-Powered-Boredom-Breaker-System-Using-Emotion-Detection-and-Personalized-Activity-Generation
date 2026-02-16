import sys
import os
import asyncio
import logging

# Ensure the app module can be found
sys.path.append(os.getcwd())

from app.services.emotion_ai import emotion_analyzer
from app.services.router_agent import router_agent

# Configure logging
logging.basicConfig(level=logging.ERROR)

async def test_sentences():
    test_cases = [
        "Today has been a good day",
        "I am feeling very very sleepy and i cant do anything",
        "I'm bored as hell",
        "I feel like trash",
        "Wsg gang"
    ]

    print(f"{'INPUT SENTENCE':<55} | {'MOOD':<10} | {'EMOTION':<10} | {'PLAN'}")
    print("-" * 120)

    for text in test_cases:
        # 1. Detect Emotion
        try:
            emotion_result = emotion_analyzer.analyze(text)
            mood = emotion_result['mood']
            emotion = emotion_result['emotion']
            intensity = emotion_result['intensity']
            
            # 2. Generate Plan
            plan_items = await router_agent.route(
                mood_data={
                    "mood": mood,
                    "emotion": emotion,
                    "intensity": intensity
                },
                user_id=1, # Mock user ID
                interests=["Coding", "Music"], # Mock interests
                text=text
            )

            # Format Plan Output
            plan_summary = []
            for item in plan_items:
                type_ = item.get('type', 'unknown')
                desc = item.get('description', '')
                plan_summary.append(f"[{type_.upper()}] {desc}")
            
            plan_str = " -> ".join(plan_summary)
            
            print(f"{text:<55} | {mood:<10} | {emotion:<10} | {plan_str}")

        except Exception as e:
            print(f"{text:<55} | ERROR: {e}")

if __name__ == "__main__":
    asyncio.run(test_sentences())
