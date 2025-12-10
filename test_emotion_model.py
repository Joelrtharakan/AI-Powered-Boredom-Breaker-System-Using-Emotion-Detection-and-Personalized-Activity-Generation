
import sys
import os

# Add backend to path to allow imports
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.services.emotion_ai import emotion_analyzer

def test_emotion_model():
    test_phrases = [
        # Standard Emotions
        "I am absolutely thrilled about this new project!", # Joy
        "I feel so lonely and down today.",              # Sadness
        "This is so frustrating, I hate waiting!",        # Anger/Stress
        "I am worried about the upcoming exam.",          # Anxiety

        # Boredom / Low Energy
        "I have absolutely nothing to do and I'm bored.", # Boredom
        "This activity is so dull and boring.",           # Boredom
        "I'm just really tired and drained of energy.",   # Exhaustion
        
        # Depression / Distress (Critical Safety Checks)
        "i am done with life and cant take it anymore",   # User reported case
        "I am done with life cant take it anymore",       # Previous case
        "I'm done with this life",                        # Variation
        "I can't take this anymore",                      # Variation
        "I just want to give up on everything.",          # Distress -> Sad
        "I feel like ending it all.",                     # Distress -> Sad

        # Slang & Colloquialisms
        "I am absolutely cooked right now.",              # Exhaustion/Defeat -> Low Energy/Sad
        "This day is mid honestly.",                      # Boredom/Neutral -> Low Energy
        "ScreenShot taken from nobraras discord server",  # Informational -> Neutral (New Case)
        "great another feature update that breaks everything", # Sarcasm -> Anger/Stress (New Case)
        "No cap I am actually having the best day.",      # Joy -> Happy
        "I'm lowkey stressed about this.",                # Anxiety -> Anxious
        "Bro I am dead, this is too funny.",              # Joy -> Happy (Tricky: 'dead' usually means laughing)
        "I'm weak right now.",                            # Joy/Laughter -> Happy (Tricky)
        "My social battery is dead.",                     # Exhaustion -> Low Energy
        "Living rent free in my head, so annoying.",      # Annoyance -> Stressed
        "Touch grass, I'm staying inside.",               # Boredom/Introversion -> Low Energy?
        "I'm spiraling right now.",                       # Anxiety -> Anxious
        "It's giving depression.",                        # Sadness -> Sad
        "Whole vibe is off today."                        # Sadness/Discomfort -> Sad/Stressed
    ]

    print(f"{'Text':<50} | {'Mood':<15} | {'Emotion':<15} | {'Score/Accuracy':<10}")
    print("-" * 100)

    for text in test_phrases:
        try:
            result = emotion_analyzer.analyze(text)
            print(f"{text:<50} | {result['mood']:<15} | {result['emotion']:<15} | {result['intensity']:.4f}")
        except Exception as e:
            print(f"Error analyzing '{text}': {e}")

if __name__ == "__main__":
    print("Initializing Emotion Model (this might take a moment if downloading)...")
    test_emotion_model()
