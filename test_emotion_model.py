
import sys
import os

# Add backend to path to allow imports
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.services.emotion_ai import emotion_analyzer

def test_emotion_model():
    test_phrases = [
        "I am absolutely thrilled about this new project!", # Joy/Optimism
        "I feel so lonely and down today.",              # Sadness
        "This is so frustrating, I hate waiting!",        # Anger
        "I have absolutely nothing to do and I'm bored.", # Boredom (Override)
        "I am worried about the upcoming exam.",          # Anxiety (Override)
        "I'm just really tired and drained.",             # Exhaustion (Override)
        "Let's see what happens next, hoping for the best." # Optimism
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
