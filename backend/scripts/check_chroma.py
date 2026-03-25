import sys
import os
import json
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.services.chroma_service import chroma_service

try:
    print("=== ACTIVITIES COLLECTION ===")
    activities = chroma_service.activities_collection.get()
    print(json.dumps(activities, indent=2))
except Exception as e:
    print(f"Error checking activities: {e}")

try:
    print("\n=== MICROTASKS COLLECTION ===")
    microtasks = chroma_service.microtasks_collection.get()
    print(json.dumps(microtasks, indent=2))
except Exception as e:
    print(f"Error checking microtasks: {e}")
