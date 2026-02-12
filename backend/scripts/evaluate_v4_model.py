"""
V4 Model Evaluation Script
===========================
Balanced test dataset of 60 labeled sentences across 7 core emotions.
Tests whether the model understands emotional MEANING, not just keyword matching.

Includes: grief, loneliness, anxiety, frustration, hope, connection,
          ambiguous statements, short/long inputs, conversational tone.
"""

import os
import sys
import logging
from transformers import pipeline

logging.basicConfig(level=logging.ERROR)

# ============================================================
# TEST DATASET: 60 sentences, ~8-9 per emotion
# ============================================================
test_data = [
    # ============================
    # SADNESS (9) - grief, loss, hopelessness, loneliness
    # ============================
    ("I keep reaching for my phone to text her before I remember she's gone.", "sadness"),
    ("The house feels too quiet now.", "sadness"),
    ("I smiled at our old photos and then just broke down crying.", "sadness"),
    ("Everyone moved on but I'm still stuck in that moment.", "sadness"),
    ("I don't even have the energy to pretend I'm okay anymore.", "sadness"),
    ("It hits different when you realize nobody noticed you were struggling.", "sadness"),
    ("I sat in the parking lot for twenty minutes because I couldn't face going inside.", "sadness"),
    ("Some days I forget, and then it all comes crashing back.", "sadness"),
    ("I miss who I used to be.", "sadness"),

    # ============================
    # JOY (9) - happiness, gratitude, accomplishment, connection
    # ============================
    ("I got the job! After six months of trying, I finally got it!", "joy"),
    ("My daughter took her first steps today and I ugly cried.", "joy"),
    ("Just had the best coffee of my life at this tiny place downtown.", "joy"),
    ("We stayed up talking until 3am and it felt like no time passed.", "joy"),
    ("I finished the marathon. I actually finished it.", "joy"),
    ("The sunset tonight made everything feel worth it.", "joy"),
    ("My dog learned a new trick and he's so proud of himself lol.", "joy"),
    ("For the first time in months, I woke up looking forward to the day.", "joy"),
    ("She said yes.", "joy"),

    # ============================
    # LOVE (8) - deep affection, connection, warmth, tenderness
    # ============================
    ("Watching him sleep peacefully makes my heart so full.", "love"),
    ("I would cross oceans for the people at this table.", "love"),
    ("She doesn't know it yet but she saved my life just by being there.", "love"),
    ("The way my grandmother holds my hand — I want to remember it forever.", "love"),
    ("I found someone who makes silence comfortable.", "love"),
    ("He remembered the small things, and that meant everything.", "love"),
    ("My best friend drove four hours just because I sounded sad on the phone.", "love"),
    ("I look at my kids and I understand what unconditional means.", "love"),

    # ============================
    # ANGER (9) - frustration, injustice, resentment, betrayal
    # ============================
    ("They promoted the guy who takes credit for everyone else's work.", "anger"),
    ("I trusted you and you used it against me.", "anger"),
    ("How many times do I have to explain the same thing before someone listens.", "anger"),
    ("The system is designed to keep people like us down.", "anger"),
    ("I'm tired of being the bigger person while they get away with everything.", "anger"),
    ("Don't tell me to calm down when you're the reason I'm upset.", "anger"),
    ("They knew exactly what they were doing and they did it anyway.", "anger"),
    ("I gave this company ten years and they let me go over email.", "anger"),
    ("Sick of fake people.", "anger"),

    # ============================
    # FEAR (9) - anxiety, dread, vulnerability, uncertainty
    # ============================
    ("What if they find out I have no idea what I'm doing.", "fear"),
    ("I can't stop thinking about all the ways this could go wrong.", "fear"),
    ("Every time my phone rings late at night my heart drops.", "fear"),
    ("The doctor said they need to run more tests.", "fear"),
    ("I'm terrified of ending up alone.", "fear"),
    ("Sometimes I lie awake imagining the worst possible outcome.", "fear"),
    ("I froze during the presentation and now I can't stop replaying it.", "fear"),
    ("The thought of starting over at my age is paralyzing.", "fear"),
    ("I keep checking the locks. I know I already checked but I can't stop.", "fear"),

    # ============================
    # SURPRISE (8) - shock, disbelief, unexpected events
    # ============================
    ("Wait, WHAT? You're telling me this NOW?", "surprise"),
    ("I never expected to hear from them again after all these years.", "surprise"),
    ("Plot twist — the quiet kid in class is a published author.", "surprise"),
    ("I opened the door and everyone was there. I had no clue.", "surprise"),
    ("They actually apologized. I'm genuinely speechless.", "surprise"),
    ("I checked my bank account and there's an extra deposit I can't explain.", "surprise"),
    ("My test results came back completely normal. I was bracing for the worst.", "surprise"),
    ("He showed up at my doorstep with flowers after ten years apart.", "surprise"),

    # ============================
    # EMOTIONALLY FLAT (8) - numbness, apathy, detachment, autopilot
    # ============================
    ("I watched the news and felt absolutely nothing.", "emotionally_flat"),
    ("People keep asking how I am and I don't know what to say.", "emotionally_flat"),
    ("I ate because it was lunchtime, not because I was hungry.", "emotionally_flat"),
    ("Things that used to excite me just feel like noise now.", "emotionally_flat"),
    ("I'm not sad. I'm not happy. I'm just here.", "emotionally_flat"),
    ("I scrolled through my phone for three hours and can't remember a single thing.", "emotionally_flat"),
    ("Someone told me great news and I couldn't even fake a reaction.", "emotionally_flat"),
    ("I've been staring at this wall for twenty minutes and I don't care.", "emotionally_flat"),
]

# ============================================================
# EVALUATION
# ============================================================
def evaluate_model():
    model_path = os.path.abspath("models/fine_tuned_roberta_v4")

    if not os.path.exists(os.path.join(model_path, "config.json")):
        print("❌ V4 model not found!")
        return

    print(f"🧠 Loading model from: {model_path}")
    classifier = pipeline(
        "text-classification",
        model=model_path,
        tokenizer=model_path,
        top_k=None,
        truncation=True
    )
    print("✅ Model loaded!\n")

    # Track results
    total = len(test_data)
    correct = 0
    wrong = []
    per_class_correct = {}
    per_class_total = {}

    for text, expected in test_data:
        results = classifier(text)[0]
        predicted = results[0]["label"]
        confidence = results[0]["score"]

        # Track per-class stats
        per_class_total[expected] = per_class_total.get(expected, 0) + 1

        if predicted == expected:
            correct += 1
            per_class_correct[expected] = per_class_correct.get(expected, 0) + 1
        else:
            wrong.append({
                "text": text,
                "expected": expected,
                "predicted": predicted,
                "confidence": confidence,
                "top3": [(r["label"], round(r["score"], 4)) for r in results[:3]]
            })

    # ============================================================
    # REPORT
    # ============================================================
    accuracy = correct / total * 100
    print("=" * 70)
    print(f"📊 EVALUATION RESULTS")
    print("=" * 70)
    print(f"\n   Overall Accuracy: {correct}/{total} ({accuracy:.1f}%)\n")

    print("   Per-Class Accuracy:")
    print("   " + "-" * 45)
    for label in sorted(per_class_total.keys()):
        c = per_class_correct.get(label, 0)
        t = per_class_total[label]
        pct = c / t * 100
        bar = "█" * int(pct / 10) + "░" * (10 - int(pct / 10))
        print(f"   {label:20s} {c}/{t}  {bar} {pct:.0f}%")

    if wrong:
        print(f"\n\n❌ MISCLASSIFICATIONS ({len(wrong)}):")
        print("   " + "-" * 65)
        for w in wrong:
            print(f"\n   Text: \"{w['text'][:70]}\"")
            print(f"   Expected: {w['expected']}  →  Predicted: {w['predicted']} ({w['confidence']:.3f})")
            print(f"   Top 3: {w['top3']}")
    else:
        print("\n\n🎉 PERFECT SCORE — No misclassifications!")

    print("\n" + "=" * 70)

    return accuracy, wrong


if __name__ == "__main__":
    evaluate_model()
