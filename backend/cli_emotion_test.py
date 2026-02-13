
import os
import sys
import re
import logging
from typing import Optional
from transformers import pipeline

# Configure logging
logging.basicConfig(level=logging.ERROR)

# ============================================================
# RULE-BASED SAFETY OVERRIDE
# Catches critical misclassifications BEFORE model inference
# ============================================================
OVERRIDE_RULES = {
    "sadness": [
        # Crisis / suicidal language (SAFETY CRITICAL)
        r"\bwant\s+to\s+die\b",
        r"\bwanna\s+die\b",
        r"\bdon'?t\s+want\s+to\s+live\b",
        r"\bwish\s+i\s+was(n'?t)?\s+(here|alive)\b",
        r"\bend\s+(it|my\s+life|everything)\b",
        r"\bkill\s+(my\s*self|myself)\b",
        r"\bsuicid",
        r"\bno\s+(point|reason)\s+(in\s+)?(living|going\s+on|to\s+(live|continue|go\s+on))\b",
        r"\bgive\s+up\s+on\s+(life|everything|living)\b",
        r"\btired\s+of\s+(existing|living|being\s+alive)\b",
        r"\bstop\s+existing\b",
        r"\bdisappear\s+forever\b",
        r"\bbetter\s+off\s+(without\s+me|dead)\b",
        r"\bdon'?t\s+want\s+to\s+wake\s+up\b",
        # Physical/emotional pain
        r"^pain$",
        r"^in\s+pain$",
        r"^suffering$",
        r"^heartbroken$",
        r"^devastated$",
        r"^shattered$",
        r"^crushed$",
        r"^broken$",
        # Hopelessness / despair
        r"\bpointless\b",
        r"\bwhat'?s\s+the\s+point\b",
        r"\bnobody\s+(would\s+)?care",
        r"\blost\s+my\s+(time|life)",
    ],
    "fear": [
        # Alarm / disturbance single words
        r"^shaken$",
        r"^troubled$",
        r"^terrified$",
        r"^panicking$",
        r"^trembling$",
        r"^alarmed$",
        r"^frightened$",
        r"^petrified$",
        r"^horrified$",
        r"^rattled$",
        r"^distressed$",
        r"^anxious$",
    ],
    "bored": [
        # Lethargy / laziness
        r"^lethargic$",
        r"^sluggish$",
        r"^unmotivated$",
        r"^listless$",
        r"\b(i\s+(am|'?m)\s+)?(so\s+)?lazy\b",
        r"\b(feel(ing)?|i'?m|become)\s+(so\s+)?lethargic\b",
        r"\b(no|don'?t\s+have|zero)\s+energy\b",
        r"\bcan'?t\s+be\s+bothered\b",
        r"\bzero\s+motivation\b",
        r"\bfeeling\s+sleepy\b",
        r"\bi\s+feel\s+nothing\b",
    ],
    "anger": [
        r"\bsick\s+of\b",
        r"\bblood\s+boil",
        r"\bso\s+pissed\b",
    ],
}

# Compile all patterns
_compiled_overrides = {}
for label, patterns in OVERRIDE_RULES.items():
    _compiled_overrides[label] = [re.compile(p, re.IGNORECASE) for p in patterns]


def check_override(text: str) -> Optional[str]:
    """Check if text matches any rule-based override. Returns label or None."""
    text_clean = text.strip()
    for label, patterns in _compiled_overrides.items():
        for pattern in patterns:
            if pattern.search(text_clean):
                return label
    return None


# ============================================================
# MAIN CLI
# ============================================================
def interact_with_model():
    # --- Path Configuration ---
    # Try models in order: V9 -> V8 -> V7 -> V6 -> V5 -> V4 -> V1
    models = [
        ("V9", os.path.abspath("models/fine_tuned_roberta_v9")),
        ("V8", os.path.abspath("models/fine_tuned_roberta_v8")),
        ("V7", os.path.abspath("models/fine_tuned_roberta_v7")),
        ("V6", os.path.abspath("models/fine_tuned_roberta_v6")),
        ("V5", os.path.abspath("models/fine_tuned_roberta_v5")),
        ("V4", os.path.abspath("models/fine_tuned_roberta_v4")),
        ("V1", os.path.abspath("models/fine_tuned_roberta")),
    ]
    
    model_path = None
    for version, path in models:
        if os.path.exists(path) and os.path.exists(os.path.join(path, "config.json")):
            model_path = path
            print(f"✨ Loading Latest Model ({version}) from: {model_path}")
            break
    
    if not model_path:
        print("❌ No fine-tuned model found in 'models/' directory.")
        return

    try:
        classifier = pipeline("text-classification", model=model_path, top_k=None)
        print("✅ Model Loaded Successfully!")
        print("🛡️  Rule-based safety overrides: ACTIVE")
        print("-" * 50)
        print("Type a sentence to detect its emotion.")
        print("Type 'exit' or 'quit' to stop.")
        print("-" * 50)

        while True:
            try:
                user_input = input("\n📝 Enter text: ").strip()
                if user_input.lower() in ['exit', 'quit']:
                    print("Goodbye! 👋")
                    break
                
                if not user_input:
                    continue

                # 1. Check rule-based override FIRST
                override_label = check_override(user_input)
                
                if override_label:
                    print(f"\n🛡️  Override: \033[1m{override_label.upper()}\033[0m (rule-based safety catch)")
                    # Still show model output for transparency
                    results = classifier(user_input)[0]
                    results.sort(key=lambda x: x['score'], reverse=True)
                    print(f"   (Model would have said: {results[0]['label']} @ {results[0]['score']:.3f})")
                else:
                    # 2. Normal model inference
                    results = classifier(user_input)[0]
                    results.sort(key=lambda x: x['score'], reverse=True)
                    top_result = results[0]
                    
                    print(f"\n🧠 Top Prediction: \033[1m{top_result['label'].upper()}\033[0m ({top_result['score']:.4f})")
                    print("📊 All Scores:")
                    for res in results[:5]:
                        print(f"   - {res['label']}: {res['score']:.4f}")

            except KeyboardInterrupt:
                print("\nGoodbye! 👋")
                break
            except Exception as e:
                print(f"❌ Error processing text: {e}")

    except Exception as e:
        print(f"❌ Failed to load model: {e}")

if __name__ == "__main__":
    if not os.path.exists("models"):
        if os.path.exists("backend/models"):
            os.chdir("backend")
    
    interact_with_model()
