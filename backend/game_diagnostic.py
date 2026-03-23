import asyncio
import sys
import os
import random

sys.path.insert(0, os.path.dirname(__file__))

from app.services.game_intelligence import game_intelligence_service

async def test_scenarios():
    scenarios = [
        {
            "name": "Boredom + Medium Energy (New priority rules)",
            "state": {"emotion": "boredom", "energy_level": "medium", "risk_level": "low", "user_intent": "unknown", "emotion_intensity": 0.5}
        },
        {
            "name": "Neutral + Game Request (Intent override)",
            "state": {"emotion": "neutral", "energy_level": "medium", "risk_level": "low", "user_intent": "game_request", "emotion_intensity": 0.4}
        },
        {
            "name": "Fatigue (Blocking Rule still persists)",
            "state": {"emotion": "fatigue", "energy_level": "low", "risk_level": "low", "user_intent": "unknown", "emotion_intensity": 0.6}
        },
        {
            "name": "Severe Stress (Hard block check)",
            "state": {"emotion": "severe_stress", "energy_level": "medium", "risk_level": "low", "user_intent": "game_request", "emotion_intensity": 0.9}
        }
    ]

    print("--- HIGH ENGAGEMENT Game Suggestion Diagnostic ---")
    for s in scenarios:
        allowed = game_intelligence_service.is_game_allowed(s['state'])
        # Run multiple times to see if bandit/random exploration picks games
        results = []
        for _ in range(10):
            res = await game_intelligence_service.decide_intervention(s['state'], 1)
            results.append(res.get('intervention') or res.get('type'))
        
        print(f"\nScenario: {s['name']}")
        print(f"  Allowed: {allowed}")
        print(f"  Types detected (10 runs): {set(results)}")

if __name__ == "__main__":
    asyncio.run(test_scenarios())
