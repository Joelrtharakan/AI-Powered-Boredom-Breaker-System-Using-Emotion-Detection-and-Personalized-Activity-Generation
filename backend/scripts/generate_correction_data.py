
import random
import pandas as pd
import os

def generate_correction_dataset():
    data = []

    # 1. DEPRESSION / GIVING UP (Mistaken for Joy/Neutral)
    # Target: sadness
    depression_phrases = [
        "I am done with life",
        "i am done",
        "i give up",
        "i can't do this anymore",
        "leaving this world",
        "there is no point",
        "what is the use of trying",
        "i hate my life",
        "i just want to end it",
        "why is everything so hard",
        "nothing matters anymore",
        "i feel like crying",
        "the pain never stops",
        "i am hopeless",
        "darkness is consuming me",
        "i'm ready to quit",
        "forget about me",
        "i'm broken",
        "torn apart inside",
        "lost causes"
    ]
    for p in depression_phrases:
         for _ in range(50): # Repeat to add weight
             data.append({"text": p, "label": "sadness"})
             data.append({"text": p.lower(), "label": "sadness"})
             data.append({"text": p.upper(), "label": "sadness"})

    # 2. BOREDOM (Mistaken for Neutral/Joy)
    # Target: low_energy_bored or restless_bored
    boredom_phrases = [
        "life is boring",
        "this is so boring",
        "i am bored",
        "dull existence",
        "nothing exciting ever happens",
        "same old routine",
        "watching paint dry",
        "unstimulated",
        "monotonous day",
        "bored to tears",
        "dying of boredom",
        "not interested in anything",
        "yawn",
        "meh",
        "so dull"
    ]
    for p in boredom_phrases:
        for _ in range(50):
            data.append({"text": p, "label": "low_energy_bored"})
            data.append({"text": p.lower(), "label": "low_energy_bored"})

    # 3. EXHAUSTION (Mistaken for Neutral)
    # Target: low_energy_bored (mapping to low_energy mood) or sadness
    exhaustion_phrases = [
        "i am drained",
        "physically exhausted",
        "mentally fried",
        "burnout is real",
        "can't move a muscle",
        "need to sleep for a week",
        "running on fumes",
        "batteries dead",
        "wiped out"
    ]
    for p in exhaustion_phrases:
        for _ in range(40):
            data.append({"text": p, "label": "low_energy_bored"})

    # 4. RANDOM GENERAL CONVERSATION (Keep Neutral)
    neutral_phrases = [
        "the sky is blue",
        "i went to the store",
        "it is what it is",
        "hello there",
        "just wondering",
        "what time is it",
        "random thoughts"
    ]
    for p in neutral_phrases:
        for _ in range(20):
            data.append({"text": p, "label": "neutral"})

    df = pd.DataFrame(data)
    
    # Shuffle
    df = df.sample(frac=1).reset_index(drop=True)

    output_path = "data/correction_dataset.csv"
    os.makedirs("data", exist_ok=True)
    df.to_csv(output_path, index=False)
    print(f"Generated {len(df)} correction samples into {output_path}")

if __name__ == "__main__":
    generate_correction_dataset()
