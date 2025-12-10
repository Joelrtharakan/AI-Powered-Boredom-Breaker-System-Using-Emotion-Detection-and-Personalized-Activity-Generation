from app.services.planner_agent import planner_agent
import logging

# Configure logging to see what's happening
logging.basicConfig(level=logging.INFO)

print("Testing Planner Agent for mood='stressed'...")
try:
    plan = planner_agent.generate_plan(mood="stressed", intensity=0.8)
    print("\n--- PLAN GENERATED ---")
    import json
    print(json.dumps(plan, indent=2))
    
    # Check if it meets criteria
    if isinstance(plan, list) and len(plan) == 3:
        print("\n✅ SUCCESS: Plan has 3 items.")
    else:
        print(f"\n❌ FAIL: Expected 3 items, got {len(plan) if isinstance(plan, list) else 'Not a list'}")

except Exception as e:
    print(f"\n❌ ERROR: {e}")
