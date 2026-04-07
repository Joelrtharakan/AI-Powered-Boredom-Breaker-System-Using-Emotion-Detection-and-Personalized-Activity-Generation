import os
import sys
import time
import json
import logging

# Add backend to path (scripts/ -> backend/)
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.emotion_ai import emotion_analyzer

def evaluate_model():
    print("🚀 Loading RoBERTa model (this may take a moment)...")
    emotion_analyzer.load_model()
    print("🚀 Starting ML Evaluation...")
    
    # Validation Dataset (Expanded to 50 samples for representative accuracy)
    validation_data = [
        ("I'm so stressed about my finals, I haven't slept in days.", "fear"), 
        ("I aced my exam today! Feels so good.", "joy"),
        ("I'm so bored, I have nothing to do all afternoon.", "bored"),
        ("I feel like I'm falling behind and everyone else is doing better.", "sadness"),
        ("I'm so angry at my group partner for not doing their part.", "anger"),
        ("I'm worried I won't get an internship this summer.", "fear"),
        ("I just want to stay in bed all day, no energy.", "fatigue"),
        ("Let's play some music and chill.", "neutral"),
        ("I don't know what to do with my life anymore.", "sadness"),
        ("This project is actually coming along nicely.", "neutral"),
        ("literally no energy lately", "fatigue"),
        ("extremely scared...", "fear"),
        ("literally makes my blood boil", "anger"),
        ("very fed up right now", "anger"),
        ("literally panic attack at the moment", "fear"),
        ("Doomscrolling twitter and I can't stop.", "bored"),
        ("really unmotivated today", "bored"),
        ("i am all good!", "neutral"),
        ("Why did I say that stupid thing earlier?", "fear"), 
        ("Everything I touch breaks.", "sadness"),
        ("I just failed my driver's test again.", "sadness"),
        ("Found a $20 bill in my old jeans!", "joy"),
        ("My roommate is blasting music at 3 AM.", "anger"),
        ("What if I never find a job in this field?", "fear"),
        ("Staring at a blank screen for three hours.", "bored"),
        ("I finally finished the project! Victory!", "neutral"),
        ("My computer crashed and I lost my work.", "sadness"),
        ("I feel so lonely in this big city.", "sadness"),
        ("The weather is just okay today.", "neutral"),
        ("I am so hyped for the concert tonight!", "joy"),
        ("Just chilling on the couch.", "neutral"),
        ("I'm terrified of public speaking.", "fear"),
        ("They cancelled my favorite show.", "sadness"),
        ("I've been stuck in traffic for an hour.", "anger"),
        ("Just scrolling through my phone.", "bored"),
        ("My pet passed away this morning.", "sadness"),
        ("I got the promotion!", "joy"),
        ("I forgot to study for the quiz.", "neutral"),
        ("Stop touching my stuff!", "anger"),
        ("I have no plans for the weekend.", "bored"),
        ("The coffee shop was closed.", "neutral"),
        ("I'm going to fail this class.", "sadness"),
        ("I can't wait for summer break!", "joy"),
        ("This movie was so slow and dull.", "bored"),
        ("My friend hasn't texted me back in days.", "sadness"),
        ("Who ate my leftovers?!", "anger"),
        ("I'm just sitting here waiting.", "neutral"),
        ("The dark is really spooky.", "fear"),
        ("I won the lottery!", "joy"),
        ("I just need a nap.", "neutral")
    ]
    
    results = []
    latencies = []

    print(f"📊 Evaluating {len(validation_data)} domain-specific samples...")
    
    correct = 0
    for text, expected in validation_data:
        start_time = time.time()
        result = emotion_analyzer.analyze(text)
        end_time = time.time()
        
        pred_emotion = result.get("emotion")
        if pred_emotion == "boredom": pred_emotion = "bored"
        
        is_correct = pred_emotion == expected
        if is_correct: correct += 1
        
        latencies.append(end_time - start_time)
        results.append({
            "text": text,
            "expected": expected,
            "predicted": pred_emotion,
            "latency": latencies[-1],
            "correct": is_correct
        })
        
        status = "✅" if is_correct else "❌"
        # Only print summary for large batches
        if not is_correct:
            print(f"{status} Input: {text[:40]}... -> Expected: {expected}, Got: {pred_emotion}")

    print("\n" + "="*50)
    print("📈 PERFORMANCE METRICS")
    print("="*50)
    
    accuracy = (correct / len(validation_data)) * 100
    avg_latency = sum(latencies) / len(latencies)
    
    print(f"Total Samples: {len(validation_data)}")
    print(f"Correct: {correct}")
    print(f"Accuracy: {accuracy:.2f}%")
    print(f"Average Inference Latency: {avg_latency:.4f} seconds")
    
    # Simple table for terminal (first 10 only to save space)
    print("\nSample Detailed Results (First 10):")
    print(f"{'TEXT':<45} | {'EXPECTED':<10} | {'PREDICTED':<10}")
    print("-" * 75)
    for r in results[:10]:
        text_cut = (r['text'][:42] + '..') if len(r['text']) > 42 else r['text'].ljust(44)
        print(f"{text_cut:<45} | {r['expected']:<10} | {r['predicted']:<10}")
    
    # Store results to a file
    with open("model_evaluation_report.json", "w") as f:
        json.dump({"metrics": {"accuracy": accuracy, "avg_latency": avg_latency}, "details": results}, f, indent=4)
        
    print("\n✅ Evaluation complete. Report saved to 'model_evaluation_report.json'.")

if __name__ == "__main__":
    evaluate_model()
