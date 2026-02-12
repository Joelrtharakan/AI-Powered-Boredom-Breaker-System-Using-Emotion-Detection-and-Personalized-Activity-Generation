"""
Emotion Model Evaluation Script
=================================
Tests model accuracy on:
  Section 1: Standard 60-sentence balanced test (target: 92%+)
  Section 2: Real-world edge cases (the exact failures from V6 testing)
"""

import os
import sys
import logging
from transformers import pipeline

logging.basicConfig(level=logging.ERROR)

# ============================================================
# SECTION 1: Standard balanced test (60 sentences)
# ============================================================
standard_test = [
    # SADNESS (8)
    ("I keep reaching for my phone to text her before I remember she's gone.", "sadness"),
    ("The house feels too quiet now.", "sadness"),
    ("Everyone moved on but I'm still stuck in that moment.", "sadness"),
    ("I don't even have the energy to pretend I'm okay anymore.", "sadness"),
    ("I cried in the shower so nobody would hear.", "sadness"),
    ("It's been months and the pain hasn't gotten any smaller.", "sadness"),
    ("I feel forgotten.", "sadness"),
    ("I drove around for hours because I didn't want to go home to an empty house.", "sadness"),

    # JOY (8)
    ("I got the job! After six months of trying, I finally got it!", "joy"),
    ("My daughter took her first steps today and I ugly cried.", "joy"),
    ("We stayed up talking until 3am and it felt like no time passed.", "joy"),
    ("I finished the marathon. I actually finished it.", "joy"),
    ("For the first time in months, I woke up looking forward to the day.", "joy"),
    ("The whole room cheered when I finished my presentation.", "joy"),
    ("I've been smiling all day for no reason.", "joy"),
    ("Today was proof that good things still happen.", "joy"),

    # LOVE (7)
    ("Watching him sleep peacefully makes my heart so full.", "love"),
    ("She doesn't know it yet but she saved my life just by being there.", "love"),
    ("The way my grandmother holds my hand — I want to remember it forever.", "love"),
    ("I found someone who makes silence comfortable.", "love"),
    ("My best friend drove four hours just because I sounded sad on the phone.", "love"),
    ("I look at my kids and I understand what unconditional means.", "love"),
    ("Being around them feels like coming home.", "love"),

    # ANGER (8)
    ("They promoted the guy who takes credit for everyone else's work.", "anger"),
    ("I trusted you and you used it against me.", "anger"),
    ("How many times do I have to explain the same thing before someone listens.", "anger"),
    ("I'm tired of being the bigger person while they get away with everything.", "anger"),
    ("Don't tell me to calm down when you're the reason I'm upset.", "anger"),
    ("I gave this company ten years and they let me go over email.", "anger"),
    ("They gaslit me for months and now act like I'm the crazy one.", "anger"),
    ("Sick of fake people.", "anger"),

    # FEAR (8)
    ("What if they find out I have no idea what I'm doing.", "fear"),
    ("I can't stop thinking about all the ways this could go wrong.", "fear"),
    ("Every time my phone rings late at night my heart drops.", "fear"),
    ("The doctor said they need to run more tests.", "fear"),
    ("I'm terrified of ending up alone.", "fear"),
    ("I keep checking the locks. I know I already checked but I can't stop.", "fear"),
    ("My anxiety has been through the roof lately.", "fear"),
    ("I'm one bad day away from completely falling apart.", "fear"),

    # SURPRISE (7)
    ("Wait, WHAT? You're telling me this NOW?", "surprise"),
    ("I never expected to hear from them again after all these years.", "surprise"),
    ("They actually apologized. I'm genuinely speechless.", "surprise"),
    ("I opened the door and everyone was there. I had no clue.", "surprise"),
    ("I looked at the results three times because I didn't believe them.", "surprise"),
    ("My jaw literally dropped when I heard the news.", "surprise"),
    ("Did that really just happen or am I dreaming.", "surprise"),

    # BORED (7)
    ("I've been staring at this wall for twenty minutes and I don't care.", "bored"),
    ("I scrolled through my phone for three hours and can't remember a single thing.", "bored"),
    ("I'm not sad. I'm not happy. I'm just here.", "bored"),
    ("Every day feels like a carbon copy of the one before it.", "bored"),
    ("Nothing sounds appealing right now.", "bored"),
    ("I feel like a zombie on autopilot.", "bored"),
    ("I have access to literally all of human knowledge and I'm still bored.", "bored"),

    # NEUTRAL (7)
    ("It was an average day. Nothing great, nothing bad.", "neutral"),
    ("I finished what I needed to do and went home.", "neutral"),
    ("The meeting went as expected.", "neutral"),
    ("I'm just going with the flow.", "neutral"),
    ("I meditated for ten minutes and I feel centered.", "neutral"),
    ("Just another Tuesday.", "neutral"),
    ("Things are going according to plan.", "neutral"),
]

# ============================================================
# SECTION 2: Real-world edge cases (V6 failures + tricky inputs)
# ============================================================
edge_cases = [
    # --- Crisis language (MUST be sadness) ---
    ("i want to die", "sadness"),
    ("i don't want to live anymore", "sadness"),
    ("what's the point of going on", "sadness"),
    ("i think there is no point of me living", "sadness"),
    ("nobody would care if i was gone", "sadness"),

    # --- Pain/distress single words (sadness) ---
    ("pain", "sadness"),
    ("suffering", "sadness"),
    ("heartbroken", "sadness"),
    ("devastated", "sadness"),
    ("broken", "sadness"),

    # --- Alarm/fear single words ---
    ("shaken", "fear"),
    ("troubled", "fear"),
    ("terrified", "fear"),
    ("panicking", "fear"),
    ("anxious", "fear"),

    # --- Lethargy/boredom ---
    ("lethargic", "bored"),
    ("i am lazy", "bored"),
    ("i dont have energy", "bored"),
    ("i have become lethargic", "bored"),
    ("feeling sleepy", "bored"),
    ("zero motivation", "bored"),
    ("sluggish", "bored"),

    # --- Anger short phrases ---
    ("sick of fake people", "anger"),
    ("i'm so pissed right now", "anger"),
    ("this makes my blood boil", "anger"),

    # --- Joy that shouldn't be confused ---
    ("best day ever", "joy"),
    ("i'm so happy right now", "joy"),

    # --- Neutral/calm ---
    ("i'm okay", "neutral"),
    ("fine", "neutral"),
    ("not bad", "neutral"),

    # --- Tricky ambiguous ---
    ("lost my time my life its moving", "sadness"),
    ("i feel nothing", "bored"),
    ("everything feels pointless", "sadness"),
]


def run_eval(test_name, test_data, classifier):
    total = len(test_data)
    correct = 0
    wrong = []
    per_class_correct = {}
    per_class_total = {}

    for text, expected in test_data:
        results = classifier(text)[0]
        predicted = results[0]["label"]
        confidence = results[0]["score"]

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

    accuracy = correct / total * 100

    print(f"\n{'='*70}")
    print(f"📊 {test_name}")
    print(f"{'='*70}")
    print(f"\n   Overall Accuracy: {correct}/{total} ({accuracy:.1f}%)\n")

    print("   Per-Class Accuracy:")
    print("   " + "-" * 50)
    for label in sorted(per_class_total.keys()):
        c = per_class_correct.get(label, 0)
        t = per_class_total[label]
        pct = c / t * 100
        bar = "█" * int(pct / 10) + "░" * (10 - int(pct / 10))
        status = "✅" if pct >= 70 else "⚠️" if pct >= 50 else "❌"
        print(f"   {status} {label:12s} {c}/{t}  {bar} {pct:.0f}%")

    if wrong:
        print(f"\n\n   ❌ MISCLASSIFICATIONS ({len(wrong)}):")
        print("   " + "-" * 65)
        for w in wrong:
            print(f"\n   Text: \"{w['text'][:70]}\"")
            print(f"   Expected: {w['expected']}  →  Got: {w['predicted']} ({w['confidence']:.3f})")
            print(f"   Top 3: {w['top3']}")
    else:
        print("\n\n   🎉 PERFECT SCORE — No misclassifications!")

    return accuracy, wrong


def evaluate_model(model_dir="models/fine_tuned_roberta_v7"):
    model_path = os.path.abspath(model_dir)

    if not os.path.exists(os.path.join(model_path, "config.json")):
        print(f"❌ Model not found at: {model_path}")
        return

    print(f"🧠 Loading model from: {model_path}")
    classifier = pipeline(
        "text-classification", model=model_path, tokenizer=model_path,
        top_k=None, truncation=True
    )
    print("✅ Model loaded!")

    # Run both tests
    acc1, _ = run_eval("SECTION 1: Standard Test (60 sentences)", standard_test, classifier)
    acc2, _ = run_eval("SECTION 2: Real-World Edge Cases", edge_cases, classifier)

    print(f"\n{'='*70}")
    print(f"📋 SUMMARY")
    print(f"{'='*70}")
    print(f"   Standard test:    {acc1:.1f}%  {'✅ PASS' if acc1 >= 92 else '❌ BELOW 92%'}")
    print(f"   Edge cases:       {acc2:.1f}%  {'✅ PASS' if acc2 >= 85 else '⚠️ NEEDS WORK'}")
    print(f"{'='*70}\n")


if __name__ == "__main__":
    model = sys.argv[1] if len(sys.argv) > 1 else "models/fine_tuned_roberta_v7"
    evaluate_model(model)
