"""
Comprehensive Test Script for Emotion Detection + Risk Assessment.
Tests many sentences and produces a detailed report.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from app.services.emotion_ai import emotion_analyzer

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEST CASES: {sentence, expected_risk_level, expected_emotion_category}
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST_CASES = [
    # ── CRISIS ──
    ("I want to die", "CRISIS", "crisis"),
    ("I am going to kill myself", "CRISIS", "crisis"),
    ("I going to sucide", "CRISIS", "crisis"),
    ("I am done with life", "CRISIS", "crisis"),
    ("Life is not worth living", "CRISIS", "crisis"),
    ("End it all today", "CRISIS", "crisis"),
    ("Better off dead", "CRISIS", "crisis"),

    # ── HIGH DISTRESS (Emotional Pain) ──
    ("I can't breathe, everything is falling apart", "HIGH_DISTRESS", "distress"),
    ("I'm having a panic attack", "HIGH_DISTRESS", "distress"),
    ("I feel hopeless and broken", "HIGH_DISTRESS", "distress"),
    ("mudiyala da", "HIGH_DISTRESS", "distress"),
    ("avalotha machu", "HIGH_DISTRESS", "distress"),
    ("I am terrified and shaking", "HIGH_DISTRESS", "distress"),

    # ── TASK BLOCKED (Work Frustration) ──
    ("I feel so frustrated because I can't complete this work", "TASK_BLOCKED", "task"),
    ("I am stuck on this assignment", "TASK_BLOCKED", "task"),
    ("Can't focus on anything today", "TASK_BLOCKED", "task"),
    ("I have too much to do and can't start", "TASK_BLOCKED", "task"),
    ("I am procrastinating so badly", "TASK_BLOCKED", "task"),
    ("This project is overwhelming me", "TASK_BLOCKED", "task"),
    ("I can't finish my homework", "TASK_BLOCKED", "task"),
    ("Hard to focus on studies", "TASK_BLOCKED", "task"),

    # ── FATIGUE ──
    ("I am so exhausted I can barely keep my eyes open", "FATIGUE", "fatigue"),
    ("My brain is fried", "FATIGUE", "fatigue"),
    ("I'm so sleepy right now", "FATIGUE", "fatigue"),
    ("I feel completely drained", "FATIGUE", "fatigue"),
    ("I need a nap badly", "FATIGUE", "fatigue"),
    ("Too tired to do anything", "FATIGUE", "fatigue"),

    # ── BOREDOM ──
    ("I am really bored", "BOREDOM", "boredom"),
    ("I have nothing to do", "BOREDOM", "boredom"),
    ("So bored right now", "BOREDOM", "boredom"),
    ("I'm just killing time", "BOREDOM", "boredom"),
    ("Entertain me please", "BOREDOM", "boredom"),

    # ── MODERATE DISTRESS ──
    ("I feel sad today", "MODERATE_DISTRESS", "moderate"),
    ("I am worried about tomorrow", "MODERATE_DISTRESS", "moderate"),
    ("Feeling lonely tonight", "MODERATE_DISTRESS", "moderate"),
    ("I am stressed about exams", "MODERATE_DISTRESS", "moderate"),

    # ── POSITIVE / JOY ──
    ("I love Jesus so much", "LOW_NORMAL", "positive"),
    ("God is good all the time", "LOW_NORMAL", "positive"),
    ("I had an amazing day today", "LOW_NORMAL", "positive"),
    ("I feel so blessed and grateful", "LOW_NORMAL", "positive"),
    ("I'm really happy right now", "LOW_NORMAL", "positive"),

    # ── NEUTRAL / NORMAL ──
    ("What's the weather like today", "LOW_NORMAL", "neutral"),
    ("I had toast for breakfast", "LOW_NORMAL", "neutral"),
    ("Just chilling at home", "LOW_NORMAL", "neutral"),
    ("Nothing much going on", "LOW_NORMAL", "neutral"),
]

def run_tests():
    print("=" * 120)
    print("🧠 EMOTION DETECTION + RISK ASSESSMENT — COMPREHENSIVE TEST REPORT")
    print("=" * 120)
    print()

    passed = 0
    failed = 0
    results = []

    for text, expected_risk, category in TEST_CASES:
        analysis = emotion_analyzer.analyze(text)
        actual_risk = analysis.get("risk_level", "UNKNOWN")
        emotion = analysis.get("emotion", "unknown")
        mood = analysis.get("mood", "unknown")
        intensity = analysis.get("intensity", 0.0)
        strategy = analysis.get("strategy", "N/A")
        source = analysis.get("decision_source", "N/A")

        match = "✅" if actual_risk == expected_risk else "❌"
        if actual_risk == expected_risk:
            passed += 1
        else:
            failed += 1

        results.append({
            "text": text,
            "category": category,
            "expected_risk": expected_risk,
            "actual_risk": actual_risk,
            "emotion": emotion,
            "mood": mood,
            "intensity": round(intensity, 3),
            "source": source,
            "match": match
        })

    # ── Print Results by Category ──
    categories = ["crisis", "distress", "task", "fatigue", "boredom", "moderate", "positive", "neutral"]
    category_names = {
        "crisis": "🚨 CRISIS",
        "distress": "😰 HIGH DISTRESS",
        "task": "🚧 TASK BLOCKED",
        "fatigue": "💤 FATIGUE",
        "boredom": "🎮 BOREDOM",
        "moderate": "😟 MODERATE DISTRESS",
        "positive": "😊 POSITIVE / JOY",
        "neutral": "😐 NEUTRAL"
    }

    for cat in categories:
        cat_results = [r for r in results if r["category"] == cat]
        if not cat_results:
            continue

        print(f"\n{'─' * 120}")
        print(f"  {category_names.get(cat, cat.upper())}")
        print(f"{'─' * 120}")
        print(f"  {'Status':<8} {'Input':<55} {'Expected':<18} {'Got':<18} {'Emotion':<12} {'Intensity'}")
        print(f"  {'─'*6:<8} {'─'*50:<55} {'─'*15:<18} {'─'*15:<18} {'─'*10:<12} {'─'*8}")

        for r in cat_results:
            text_short = r["text"][:52] + "..." if len(r["text"]) > 52 else r["text"]
            print(f"  {r['match']:<8} {text_short:<55} {r['expected_risk']:<18} {r['actual_risk']:<18} {r['emotion']:<12} {r['intensity']}")

    # ── Summary ──
    total = passed + failed
    print(f"\n{'=' * 120}")
    print(f"  📊 SUMMARY: {passed}/{total} passed ({round(passed/total*100, 1)}% accuracy)")
    print(f"     ✅ Passed: {passed}")
    print(f"     ❌ Failed: {failed}")
    print(f"{'=' * 120}")

    # ── List Failures ──
    failures = [r for r in results if r["match"] == "❌"]
    if failures:
        print(f"\n{'─' * 120}")
        print(f"  ❌ FAILED CASES (Need Fixing):")
        print(f"{'─' * 120}")
        for r in failures:
            print(f"  Input:    \"{r['text']}\"")
            print(f"  Expected: {r['expected_risk']}  |  Got: {r['actual_risk']}  |  Emotion: {r['emotion']}  |  Source: {r['source']}")
            print()

if __name__ == "__main__":
    run_tests()
