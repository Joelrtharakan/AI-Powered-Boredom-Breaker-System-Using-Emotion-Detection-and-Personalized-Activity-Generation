
from app.services.emotion_ai import emotion_analyzer
import time

# ==================================================================================
# 🧪 V14 FINAL MODEL VERIFICATION (THE ALL-KNOWING)
# ==================================================================================

NEW_TEST_CASES = [
    # --- COMPLEX / MIXED / NUANCED ---
    ("I'm smiling but I want to cry.", "sad"),  # Mixed, usually dominant sad
    ("It's a bittersweet feeling leaving home.", "sad"),
    ("I'm exhausted but in a good way.", "happy"), # "Good way" implies satisfaction/happy
    ("I'm nervous about the date but also kinda excited.", "anxious"), # Anxiety usually triggers first
    ("I love him but he makes me so mad sometimes.", "stressed"), # Conflict/Anger

    # --- SLANG / MODERN PHRASING ---
    ("This day is dragging.", "low_energy"),
    ("I'm dead inside.", "sad"), # Or low_energy/sad
    ("My brain is fried.", "low_energy"),
    ("I am literally shaking rn.", "anxious"),
    ("Big yikes.", "anxious"), # Or stressed/neutral depending on context, typically anxious/embarrassed
    ("I can't deal with this drama.", "stressed"),
    ("Vibes are off.", "anxious"), # Or low_energy/neutral
    ("Just doomscrolling.", "low_energy"),
    ("I'm spiraling.", "anxious"),
    ("Rent free in my head.", "stressed"), # Usually negative obsession

    # --- INTENT / IMPLICIT ---
    ("I wish he would call me.", "sad"), # Longing/Sadness
    ("Why haven't they replied yet?", "anxious"),
    ("I keep refreshing the page.", "anxious"),
    ("I stared at the ceiling for hours.", "low_energy"), # or Sad
    ("I forgot to eat today.", "stressed"), # Or low_energy/sad
    ("I don't want to get out of bed.", "low_energy"), # or Sad

    # --- MUNDANE / NEUTRAL 2.0 (Tricky) ---
    ("I put on my shoes.", "neutral"),
    ("The train is late.", "neutral"), # Could be stressed, but factual statement is neutral
    ("I drank a glass of water.", "neutral"),
    ("It's cloudy outside.", "neutral"),
    ("I bought some apples.", "neutral"),
    ("Charging my laptop.", "neutral"),
    ("The wifi is connected.", "neutral"),
    ("I have a meeting at 10.", "neutral"),

    # --- EXTREME INTENSITY ---
    ("I am absolutely furious!", "stressed"),
    ("I am on cloud nine!", "happy"),
    ("I am in the depths of despair.", "sad"),
    ("My heart is pounding out of my chest!", "anxious"),
    ("I have never been this bored in my life.", "low_energy"),

    # --- RANDOM / MISC ---
    ("I hope tomorrow is better.", "sad"), # Implies today was bad
    ("Finally finished.", "happy"), # Relief -> Happy
    ("What a mess.", "stressed"),
    ("Silence is loud.", "sad"), # Poetic sad/lonely
    ("Can we just stop?", "stressed"),
]

def run_blind_test():
    print(f"\n🚀 STARTING V11 BLIND TEST with {len(NEW_TEST_CASES)} NEW examples...")
    print("="*80)
    print(f"{'TEXT':<50} | {'EXPECTED':<12} | {'ACTUAL':<12} | {'RESULT'}")
    print("-" * 90)

    correct = 0
    
    # We will map "joy" -> "happy", "fear" -> "anxious", "anger" -> "stressed", "bored" -> "low_energy", "sadness" -> "sad"
    # to match the NEW_TEST_CASES expected labels (which use the internal mood keys)
    
    # The analyzer returns internal moods: happy, sad, anxious, stressed, low_energy, neutral
    
    for text, expected in NEW_TEST_CASES:
        try:
            result = emotion_analyzer.analyze(text)
            actual = result['mood']
            
            # Loose matching for "low_energy" vs "sad" overlap in some subjective cases
            # But let's be strict first.
            
            is_correct = (actual == expected)
            
            # Allow some subjective interpretation mapping if needed? 
            # E.g. "I'm dead inside" -> could be sad or low_energy.
            if not is_correct:
                if expected == "sad" and actual == "low_energy": is_correct = True # Acceptable overlap
                if expected == "low_energy" and actual == "sad": is_correct = True # Acceptable overlap
            
            mark = "✅" if is_correct else "❌"
            if is_correct: correct += 1
            
            color = "\033[92m" if is_correct else "\033[91m"
            reset = "\033[0m"
            
            print(f"{text[:47]+'...':<50} | {expected:<12} | {color}{actual:<12}{reset} | {mark}")
            if not is_correct:
                print(f"   🔎 Reason: {result['reason']}")
                
        except Exception as e:
            print(f"ERROR on '{text}': {e}")

    acc = (correct / len(NEW_TEST_CASES)) * 100
    print("="*80)
    print(f"📊 BLIND TEST ACCURACY: {acc:.1f}%")

if __name__ == "__main__":
    run_blind_test()
