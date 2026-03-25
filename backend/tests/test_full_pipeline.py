"""
COMPREHENSIVE 57-Sentence End-to-End Pipeline Test.
Validates BOTH classification AND plan correctness against production spec.
"""
import sys, os, asyncio, random
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from app.services.emotion_ai import emotion_analyzer
from app.services.planner_agent import planner_agent

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 57 TEST CASES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST_CASES = [
    # ── CRISIS (8) ──
    ("I want to die", "CRISIS"),
    ("I am going to kill myself", "CRISIS"),
    ("Life is not worth living", "CRISIS"),
    ("I am done with life", "CRISIS"),
    ("End it all today", "CRISIS"),
    ("Better off dead", "CRISIS"),
    ("I don't want to exist anymore", "CRISIS"),
    ("Why am I alive", "CRISIS"),

    # ── HIGH DISTRESS (7) ──
    ("I can't breathe, everything is falling apart", "HIGH_DISTRESS"),
    ("I'm having a panic attack", "HIGH_DISTRESS"),
    ("I feel hopeless and broken", "HIGH_DISTRESS"),
    ("I am terrified and shaking", "HIGH_DISTRESS"),
    ("Everything feels unbearable right now", "HIGH_DISTRESS"),
    ("mudiyala da", "HIGH_DISTRESS"),
    ("I am at my breaking point", "HIGH_DISTRESS"),

    # ── TASK BLOCKED (10) ──
    ("I feel so frustrated because I can't complete this work", "TASK_BLOCKED"),
    ("I am stuck on this assignment", "TASK_BLOCKED"),
    ("Can't focus on anything today", "TASK_BLOCKED"),
    ("I have too much to do and can't start", "TASK_BLOCKED"),
    ("This project is overwhelming me", "TASK_BLOCKED"),
    ("I can't finish my homework", "TASK_BLOCKED"),
    ("Hard to focus on studies", "TASK_BLOCKED"),
    ("I am procrastinating so badly", "TASK_BLOCKED"),
    ("I keep losing focus while studying", "TASK_BLOCKED"),
    ("I'm distracted and can't get anything done", "TASK_BLOCKED"),

    # ── FATIGUE (8) ──
    ("I am so exhausted I can barely keep my eyes open", "FATIGUE"),
    ("My brain is fried", "FATIGUE"),
    ("I'm so sleepy right now", "FATIGUE"),
    ("I feel completely drained", "FATIGUE"),
    ("I need a nap badly", "FATIGUE"),
    ("Too tired to do anything", "FATIGUE"),
    ("I'm running on empty, no energy left", "FATIGUE"),
    ("I am burnt out and wiped out", "FATIGUE"),

    # ── BOREDOM (8) ──
    ("I am really bored", "BOREDOM"),
    ("I have nothing to do", "BOREDOM"),
    ("So bored right now", "BOREDOM"),
    ("I'm just killing time", "BOREDOM"),
    ("Entertain me please", "BOREDOM"),
    ("This is so boring I need something fun", "BOREDOM"),
    ("I'm bored out of my mind", "BOREDOM"),
    ("There's absolutely nothing to do here", "BOREDOM"),

    # ── MODERATE DISTRESS (6) ──
    ("I feel sad today", "MODERATE_DISTRESS"),
    ("I am worried about tomorrow", "MODERATE_DISTRESS"),
    ("Feeling lonely tonight", "MODERATE_DISTRESS"),
    ("I am stressed about exams", "MODERATE_DISTRESS"),
    ("I'm crying and I don't know why", "MODERATE_DISTRESS"),
    ("I feel so anxious about everything", "MODERATE_DISTRESS"),

    # ── POSITIVE / JOY (5) ──
    ("I love Jesus so much", "LOW_NORMAL"),
    ("I had an amazing day today", "LOW_NORMAL"),
    ("I feel so blessed and grateful", "LOW_NORMAL"),
    ("I'm really happy right now", "LOW_NORMAL"),
    ("God is good all the time", "LOW_NORMAL"),

    # ── NEUTRAL (5) ──
    ("What's the weather like today", "LOW_NORMAL"),
    ("I had toast for breakfast", "LOW_NORMAL"),
    ("Just chilling at home", "LOW_NORMAL"),
    ("Nothing much going on", "LOW_NORMAL"),
    ("I'm reading a book right now", "LOW_NORMAL"),
]

# Plan validation per risk level (updated for production spec)
PLAN_RULES = {
    "CRISIS": {"must_have": ["breathing", "micro_task", "social"], "must_not_have": ["game"]},
    "HIGH_DISTRESS": {"must_have": ["breathing", "micro_task"], "must_not_have": ["game"]},
    "TASK_BLOCKED": {"must_have": ["breathing", "micro_task", "activity"], "must_not_have": ["game"]},
    "FATIGUE": {"must_have": ["rest"], "must_not_have": ["game"]},
    "BOREDOM": {"must_have": ["game"], "must_not_have": ["social"]},
    "MODERATE_DISTRESS": {"must_have": ["calming_audio", "micro_task"], "must_not_have": ["game"]},
    "LOW_NORMAL": {"must_have": [], "must_not_have": []},
}

def validate_plan(plan, risk_level):
    rules = PLAN_RULES.get(risk_level, {"must_have": [], "must_not_have": []})
    plan_types = [s.get("type", "") for s in plan]
    issues = []
    for req in rules["must_have"]:
        if req not in plan_types:
            issues.append(f"MISSING '{req}'")
    for ban in rules["must_not_have"]:
        if ban in plan_types:
            issues.append(f"UNWANTED '{ban}'")
    return issues

def format_plan_short(plan):
    icons = {
        "breathing": "🫁", "micro_task": "📋", "activity": "🏃",
        "music": "🎵", "game": "🎮", "rest": "😴", "social": "👥",
        "environment_adjustment": "🏠", "affirmation": "💬",
        "calming_audio": "🔊", "journal": "📝",
    }
    parts = []
    for s in plan:
        t = s.get("type", "?")
        icon = icons.get(t, "▪️")
        desc = s.get("description", "")[:55]
        purpose = s.get("purpose", "")
        parts.append(f"{icon} [{t}] {desc}")
    return "\n          ".join(parts)

async def run_test():
    print("=" * 140)
    print("🧠 PRODUCTION SPEC TEST — 57 Sentences — Classification + Plan + Adaptive Modifiers")
    print("=" * 140)

    c_pass = 0; c_fail = 0; p_pass = 0; p_fail = 0
    results_by_cat = {}

    for text, expected_risk in TEST_CASES:
        analysis = emotion_analyzer.analyze(text)
        actual_risk = analysis.get("risk_level", "UNKNOWN")
        emotion = analysis.get("emotion", "?")
        mood = analysis.get("mood", "?")
        intensity = analysis.get("intensity", 0.0)

        try:
            plan = await planner_agent.generate_plan(
                mood=mood, 
                intensity=intensity, 
                user_id=1,
                interests=["games", "music"], 
                text=text,
                risk_level=actual_risk,
                subtype=analysis.get("subtype"),
                ns_state=analysis.get("nervous_system_state")
            )
        except Exception as e:
            print(f"ERROR producing plan for '{text}': {e}")
            plan = [{"type": "error", "description": str(e)}]

        class_ok = actual_risk == expected_risk
        plan_issues = validate_plan(plan, actual_risk)
        plan_ok = not plan_issues

        if class_ok: c_pass += 1
        else: c_fail += 1
        if plan_ok: p_pass += 1
        else: p_fail += 1

        cat = expected_risk
        if cat not in results_by_cat:
            results_by_cat[cat] = []
        results_by_cat[cat].append({
            "text": text, "expected": expected_risk, "actual": actual_risk,
            "emotion": emotion, "intensity": round(intensity, 3),
            "class_ok": "✅" if class_ok else "❌",
            "plan_ok": "✅" if plan_ok else "⚠️",
            "plan_issues": plan_issues, "plan": plan
        })

    # Print by category
    cat_icons = {
        "CRISIS": "🚨 CRISIS", "HIGH_DISTRESS": "😰 HIGH DISTRESS",
        "TASK_BLOCKED": "🚧 TASK BLOCKED", "FATIGUE": "💤 FATIGUE",
        "BOREDOM": "🎮 BOREDOM", "MODERATE_DISTRESS": "😟 MODERATE DISTRESS",
        "LOW_NORMAL": "😊 POSITIVE / NEUTRAL"
    }
    cat_order = ["CRISIS", "HIGH_DISTRESS", "TASK_BLOCKED", "FATIGUE", "BOREDOM", "MODERATE_DISTRESS", "LOW_NORMAL"]

    for cat in cat_order:
        if cat not in results_by_cat: continue
        items = results_by_cat[cat]
        cc = sum(1 for r in items if r["class_ok"] == "✅")
        pp = sum(1 for r in items if r["plan_ok"] == "✅")

        print(f"\n{'━' * 140}")
        print(f"  {cat_icons.get(cat, cat)}  (Class: {cc}/{len(items)}, Plans: {pp}/{len(items)})")
        print(f"{'━' * 140}")

        for r in items:
            ts = r["text"][:60]
            print(f"\n  {r['class_ok']} {r['plan_ok']}  \"{ts}\"")
            print(f"        Risk: {r['actual']:<18} Emotion: {r['emotion']:<10} Intensity: {r['intensity']}")
            print(f"        Plan: {format_plan_short(r['plan'])}")
            if r["plan_issues"]:
                print(f"        ⚠️ Issues: {', '.join(r['plan_issues'])}")

    # Summary
    total = c_pass + c_fail
    print(f"\n{'=' * 140}")
    print(f"  📊 CLASSIFICATION: {c_pass}/{total} ({round(c_pass/total*100,1)}%)")
    print(f"  📦 PLAN QUALITY:   {p_pass}/{total} ({round(p_pass/total*100,1)}%)")
    print(f"{'=' * 140}")

    # Failures
    has_issues = False
    for items in results_by_cat.values():
        for r in items:
            if r["class_ok"] == "❌":
                if not has_issues:
                    print(f"\n  ❌ CLASSIFICATION FAILURES:")
                    has_issues = True
                print(f"     \"{r['text']}\"  Expected: {r['expected']}  Got: {r['actual']}")

    has_plan_issues = False
    for items in results_by_cat.values():
        for r in items:
            if r["plan_ok"] == "⚠️":
                if not has_plan_issues:
                    print(f"\n  ⚠️ PLAN ISSUES:")
                    has_plan_issues = True
                print(f"     \"{r['text']}\" ({r['actual']}): {', '.join(r['plan_issues'])}")
                types = [s.get("type") for s in r["plan"]]
                print(f"       Plan types: {types}")

    if not has_issues and not has_plan_issues:
        print(f"\n  🎉 ALL {total} TESTS PASSED! Classification + Plans both 100% correct!")

if __name__ == "__main__":
    asyncio.run(run_test())
