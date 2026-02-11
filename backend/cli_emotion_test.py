
import os
import sys
import logging
from transformers import pipeline

# Configure logging
logging.basicConfig(level=logging.ERROR) # Only show errors to keep CLI clean

def interact_with_model():
    # --- Path Configuration ---
    # Try models in order: V3 -> V2 -> V1
    model_v3 = os.path.abspath("models/fine_tuned_roberta_v3")
    model_v2 = os.path.abspath("models/fine_tuned_roberta_v2")
    model_v1 = os.path.abspath("models/fine_tuned_roberta")
    
    model_path = None
    if os.path.exists(model_v3) and os.path.exists(os.path.join(model_v3, "config.json")):
        model_path = model_v3
        print(f"✨ Loading Latest Model (V3) from: {model_path}")
    elif os.path.exists(model_v2) and os.path.exists(os.path.join(model_v2, "config.json")):
        model_path = model_v2
        print(f"✨ Loading Model (V2) from: {model_path}")
    elif os.path.exists(model_v1) and os.path.exists(os.path.join(model_v1, "config.json")):
        model_path = model_v1
        print(f"✨ Loading Model (V1) from: {model_path}")
    else:
        print("❌ No fine-tuned model found in 'models/' directory.")
        return

    try:
        classifier = pipeline("text-classification", model=model_path, top_k=None)
        print("✅ Model Loaded Successfully!")
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

                # Run inference
                results = classifier(user_input)[0]
                # Sort by score descending
                results.sort(key=lambda x: x['score'], reverse=True)
                
                top_result = results[0]
                
                print(f"\n🧠 Top Prediction: \033[1m{top_result['label'].upper()}\033[0m ({top_result['score']:.4f})")
                print("📊 All Scores:")
                for res in results[:5]: # Show top 5
                    print(f"   - {res['label']}: {res['score']:.4f}")

            except KeyboardInterrupt:
                print("\nGoodbye! 👋")
                break
            except Exception as e:
                print(f"❌ Error processing text: {e}")

    except Exception as e:
        print(f"❌ Failed to load model: {e}")

if __name__ == "__main__":
    # Ensure we are running from backend root or adjust path
    if not os.path.exists("models"):
        # Try to change to backend directory if script run from project root
        if os.path.exists("backend/models"):
            os.chdir("backend")
    
    interact_with_model()
