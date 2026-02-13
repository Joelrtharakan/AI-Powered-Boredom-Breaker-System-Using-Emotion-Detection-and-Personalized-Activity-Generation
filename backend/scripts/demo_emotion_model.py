
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

def demo_loop():
    print("\n🚀 V14 'ALL-KNOWING' EMOTION MODEL DEMO")
    print("Type anything to see how the model feels about it. (Type 'exit' to quit)")
    print("-" * 60)
    
    while True:
        text = input("\n📝 You: ")
        if text.strip().lower() in ["exit", "quit", "q"]:
            break
            
        try:
            result = emotion_analyzer.analyze(text)
            mood = result['mood']
            confidence = result['score'] * 100
            reason = result['reason']
            
            # Color coding
            colors = {
                "happy": "\033[92m", # Green
                "sad": "\033[94m",   # Blue
                "anxious": "\033[93m", # Yellow
                "stressed": "\033[91m", # Red
                "low_energy": "\033[90m", # Gray
                "neutral": "\033[37m" # White
            }
            c = colors.get(mood, "\033[0m")
            r = "\033[0m"
            
            print(f"🤖 AI: {c}{mood.upper()}{r} ({confidence:.1f}%)")
            print(f"   � {reason}")
            
        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    demo_loop()
