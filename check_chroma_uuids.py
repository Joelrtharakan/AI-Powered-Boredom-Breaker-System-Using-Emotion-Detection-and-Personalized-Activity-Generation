import sys
import os
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.services.chroma_service import chroma_service

try:
    print(f"Activities Collection ID: {chroma_service.activities_collection.id}")
except Exception as e:
    pass

try:
    print(f"Microtasks Collection ID: {chroma_service.microtasks_collection.id}")
except Exception as e:
    pass
