import os
import sys
import json
import logging
import asyncio

# Add backend to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))), '..')))

from app.services.llm_service import llm_service

async def generate_synthetic_dataset(num_samples=100):
    """Generates synthetic student emotional data using an LLM for domain adaptation."""
    print(f"🚀 Generating {num_samples} synthetic student emotional samples...")
    
    categories = ["burnout", "exam_stress", "loneliness", "boredom", "neutral_daily"]
    dataset = []

    for cat in categories:
        print(f"Generating for category: {cat}")
        prompt = f"""Generate 20 distinct, realistic text messages or diary entries from a college student experiencing {cat}.
        Include slang like 'cooked', 'fried', 'feds', 'mid', 'valid', 'wsg'.
        Return ONLY a JSON list of strings."""
        
        try:
            response = await llm_service.generate(
                system_prompt="You are a dataset generator for student mental health research.",
                user_prompt=prompt,
                model="google/gemini-2.0-flash-001"
            )
            
            # Extract JSON
            cleaned = response
            if "```json" in cleaned:
                cleaned = cleaned.split("```json")[1].split("```")[0].strip()
            elif "```" in cleaned:
                cleaned = cleaned.split("```")[1].split("```")[0].strip()
            
            samples = json.loads(cleaned)
            for s in samples:
                dataset.append({"text": s, "label": cat})
        except Exception as e:
            print(f"Error generating {cat}: {e}")

    # Save to file
    output_file = "synthetic_student_dataset.json"
    with open(output_file, "w") as f:
        json.dump(dataset, f, indent=4)
        
    print(f"\n✅ Created synthetic dataset with {len(dataset)} samples in '{output_file}'.")
    print("This data can be used for secondary fine-tuning or evaluation calibration.")

if __name__ == "__main__":
    asyncio.run(generate_synthetic_dataset())
