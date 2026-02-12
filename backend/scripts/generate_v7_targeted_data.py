"""
V7 Targeted Data Generator
============================
Generates TARGETED training examples to fix V6's real-world failures:
1. Crisis/suicidal language → sadness
2. Single-word emotional keywords → correct label
3. Low-energy/lethargy → bored
4. Short informal phrases (2-5 words) → correct label
5. Physical distress → sadness
6. Alarm/disturbance words → fear

This supplements V6 data — NOT a replacement.
"""

import csv
import os
import random

OUTPUT_PATH = "data/v7_targeted_dataset.csv"

templates = {
    # ================================================================
    # SADNESS — Crisis language, despair, physical/emotional pain
    # ================================================================
    "sadness": [
        # --- Crisis/suicidal language (CRITICAL) ---
        "i want to die",
        "i don't want to live anymore",
        "life isn't worth living",
        "i wish i wasn't here",
        "what's the point of going on",
        "i want it all to end",
        "i can't take this anymore i just want to disappear",
        "nobody would care if i was gone",
        "i feel like giving up on everything",
        "i don't see a reason to keep going",
        "sometimes i think everyone would be better off without me",
        "i just want the pain to stop",
        "i've thought about ending it all",
        "there's no point to any of this",
        "i don't want to wake up tomorrow",
        "i'm tired of existing",
        "i wish i could just stop existing",
        "life feels meaningless",
        "everything feels pointless",
        "what's the point of anything anymore",
        "i feel like a waste of space",
        "i don't belong in this world",
        "nothing will ever get better",
        "i've lost the will to go on",
        "i can't do this anymore",
        "i want to give up",
        "there's no hope left",
        "i feel dead inside",
        "i'm beyond help at this point",
        "why am i even here",
        # --- Physical/emotional pain keywords ---
        "pain",
        "in pain",
        "i'm in so much pain",
        "everything hurts",
        "my heart hurts",
        "it's painful",
        "aching inside",
        "i'm hurting",
        "this pain won't go away",
        "suffering",
        "i'm suffering",
        "i feel nothing but pain",
        "emotionally wrecked",
        "broken",
        "shattered",
        "crushed",
        "devastated",
        "destroyed",
        "heartbroken",
        "torn apart",
        "falling apart",
        "my soul hurts",
        "deep pain",
        "unbearable pain",
        "the pain is too much",
        # --- Single-word sadness ---
        "miserable",
        "hopeless",
        "worthless",
        "helpless",
        "lonely",
        "depressed",
        "grief",
        "despair",
        "sorrow",
        "anguish",
        "mourning",
        "heartache",
        "melancholy",
        "desolate",
        "wretched",
        "forlorn",
        "gloomy",
        "dejected",
        "dismal",
        "bleak",
        # --- Short phrases ---
        "i'm so sad",
        "feeling low",
        "feeling down",
        "really down today",
        "i feel terrible",
        "i feel awful",
        "i feel empty",
        "i feel worthless",
        "i feel hopeless",
        "feeling miserable",
        "everything is falling apart",
        "i hate my life",
        "my life is a mess",
        "i feel so alone",
        "completely devastated",
        "deeply hurt",
        "so much pain inside",
        "i can't stop hurting",
        "the sadness is overwhelming",
        "i feel like crying",
    ],

    # ================================================================
    # FEAR — Alarm, disturbance, anxiety, panic keywords
    # ================================================================
    "fear": [
        # --- Single-word fear ---
        "shaken",
        "troubled",
        "terrified",
        "horrified",
        "panicking",
        "trembling",
        "alarmed",
        "frightened",
        "spooked",
        "startled",
        "petrified",
        "dread",
        "aghast",
        "nervous",
        "uneasy",
        "anxious",
        "worried",
        "paranoid",
        "tense",
        "rattled",
        "unsettled",
        "apprehensive",
        "jittery",
        "edgy",
        "restless",
        "distressed",
        "overwhelmed",
        "panicked",
        # --- Short phrases ---
        "i'm shaken up",
        "feeling troubled",
        "i'm really nervous",
        "my heart is racing",
        "i feel uneasy",
        "something feels wrong",
        "i'm scared right now",
        "i'm trembling",
        "i'm so anxious",
        "i feel panicky",
        "i'm freaking out",
        "i can't calm down",
        "really worried right now",
        "i feel unsafe",
        "i'm terrified right now",
        "my stomach is in knots",
        "i'm having a panic attack",
        "i feel really tense",
        "on edge today",
        "i feel threatened",
        "deeply unsettled",
        "i'm losing my mind with worry",
        "can't stop shaking",
        "something terrible is going to happen",
        "i'm dreading everything",
        "fear is consuming me",
        "i feel vulnerable",
        "everything scares me right now",
        "the anxiety won't stop",
        "i'm paralyzed with fear",
    ],

    # ================================================================
    # BORED — Lethargy, laziness, low energy, unmotivated
    # ================================================================
    "bored": [
        # --- Single-word bored/lethargy ---
        "lethargic",
        "sluggish",
        "unmotivated",
        "bored",
        "listless",
        "apathetic",
        "indifferent",
        "uninterested",
        "lazy",
        "idle",
        "dull",
        "monotonous",
        "tedious",
        "tiresome",
        "stagnant",
        "unenthusiastic",
        "blah",
        "meh",
        "whatever",
        "numb",
        # --- Low energy / lethargy phrases ---
        "i don't have energy",
        "i have no energy",
        "zero energy today",
        "no energy at all",
        "i feel so lethargic",
        "i have become lethargic",
        "feeling really lethargic today",
        "i'm feeling sluggish",
        "i feel sluggish and unmotivated",
        "no motivation whatsoever",
        "i can't motivate myself to do anything",
        "i'm so unmotivated it's not even funny",
        "i have zero drive today",
        "completely drained of motivation",
        "i don't have the energy for anything",
        "too lazy to move",
        "i am lazy",
        "feeling lazy today",
        "i'm being so lazy right now",
        "i just want to lay here and do nothing",
        "i can't be bothered",
        "can't be bothered to do anything",
        "i don't care enough to get up",
        "not in the mood for anything",
        "nothing interests me today",
        "everything feels pointless and dull",
        "i'm just existing, not living",
        "running on empty",
        "i feel like a vegetable",
        "my brain is switched off",
        # --- Restlessness ---
        "i need something to do",
        "there's nothing to do",
        "what do i even do",
        "i'm so bored i could cry",
        "help i'm dying of boredom",
        "bored out of my mind",
        "this is so boring",
        "i have nothing going on",
        "staring at the ceiling again",
        "watching the clock tick",
        # --- Emotional flatness ---
        "i feel nothing",
        "emotionally flat",
        "flatlined emotionally",
        "i feel dead but not sad",
        "i feel like a robot going through routines",
        "i'm on autopilot and i hate it",
        "disconnected from everything",
        "just numb",
        "i don't feel anything anymore",
        "empty but not sad, just empty",
        "feeling sleepy",
        "sleepy and bored",
        "drowsy and unproductive",
        "too tired for anything",
        "feeling sleepy and lazy",
    ],

    # ================================================================
    # ANGER — Short anger keywords and phrases
    # ================================================================
    "anger": [
        # --- Single-word anger ---
        "furious",
        "enraged",
        "outraged",
        "infuriated",
        "irritated",
        "annoyed",
        "aggravated",
        "exasperated",
        "hostile",
        "bitter",
        "resentful",
        "hateful",
        "vengeful",
        "wrathful",
        "irate",
        "incensed",
        "seething",
        "fuming",
        "livid",
        "pissed",
        # --- Short anger phrases ---
        "sick of this",
        "sick of fake people",
        "i'm so pissed right now",
        "i'm fed up",
        "this makes me sick",
        "i hate this",
        "i hate everything",
        "i'm losing my patience",
        "i'm boiling inside",
        "i want to scream",
        "absolutely disgusted",
        "makes my blood boil",
        "done with everyone",
        "what the hell",
        "are you kidding me",
        "i'm beyond angry",
        "i could explode right now",
        "who do they think they are",
        "they have some nerve",
        "the disrespect is unreal",
    ],

    # ================================================================
    # JOY — Short joy keywords (to reinforce correct classification)
    # ================================================================
    "joy": [
        # --- Single-word joy ---
        "happy",
        "ecstatic",
        "thrilled",
        "delighted",
        "elated",
        "overjoyed",
        "blissful",
        "euphoric",
        "cheerful",
        "jubilant",
        "excited",
        "wonderful",
        "amazing",
        "fantastic",
        "brilliant",
        "magnificent",
        "terrific",
        "phenomenal",
        "excellent",
        "glorious",
        # --- Short joy phrases ---
        "i'm so happy right now",
        "feeling great today",
        "today is amazing",
        "life is beautiful",
        "i feel incredible",
        "what a great day",
        "feeling blessed",
        "i'm on top of the world",
        "couldn't be happier",
        "living my best life",
        "this is wonderful",
        "feeling fantastic",
        "so much to be grateful for",
        "i'm beaming",
        "pure happiness",
        "everything is perfect",
        "best day of my life",
        "i feel alive and free",
        "my heart is full of joy",
        "i can't contain my excitement",
    ],

    # ================================================================
    # LOVE — Single-word and short phrases
    # ================================================================
    "love": [
        "adore",
        "cherish",
        "devoted",
        "affectionate",
        "tender",
        "compassionate",
        "caring",
        "smitten",
        "infatuated",
        "enamored",
        "warmth",
        "fondness",
        "attachment",
        "devotion",
        "tenderness",
        "i love you so much",
        "you mean everything to me",
        "i'm so in love",
        "deeply in love",
        "my heart belongs to you",
        "you are my everything",
        "i care about you deeply",
        "i adore this person",
        "unconditional love",
        "love of my life",
        "you complete me",
        "forever yours",
        "deeply attached",
        "head over heels",
        "madly in love",
    ],

    # ================================================================
    # SURPRISE — Single-word and short phrases
    # ================================================================
    "surprise": [
        "astonished",
        "astounded",
        "flabbergasted",
        "bewildered",
        "stunned",
        "dumbfounded",
        "gobsmacked",
        "thunderstruck",
        "incredulous",
        "amazed",
        "baffled",
        "staggered",
        "awestruck",
        "stupefied",
        "nonplussed",
        "what the heck",
        "oh my god",
        "i can't believe it",
        "you're joking right",
        "no freaking way",
        "are you serious right now",
        "i'm absolutely floored",
        "that came out of nowhere",
        "completely caught off guard",
        "my mind is blown",
        "did that just happen",
        "i'm in disbelief",
        "pinch me i must be dreaming",
        "that was totally unexpected",
        "i'm in complete shock",
    ],

    # ================================================================
    # NEUTRAL — Single-word and short phrases
    # ================================================================
    "neutral": [
        "okay",
        "fine",
        "alright",
        "decent",
        "moderate",
        "average",
        "standard",
        "ordinary",
        "typical",
        "regular",
        "unremarkable",
        "passable",
        "acceptable",
        "satisfactory",
        "adequate",
        "it's fine",
        "i'm okay",
        "nothing special",
        "pretty normal",
        "just regular",
        "not bad not good",
        "it was alright",
        "could be worse",
        "nothing to complain about",
        "fairly standard day",
        "everything is as expected",
        "no strong feelings",
        "i'm doing okay i guess",
        "same as usual",
        "just a normal day",
    ],
}


def generate():
    rows = []
    for label, texts in templates.items():
        for text in texts:
            rows.append({"text": text, "label": label})

    random.seed(42)
    random.shuffle(rows)

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["text", "label"])
        writer.writeheader()
        writer.writerows(rows)

    print(f"✅ Generated {len(rows)} V7 targeted samples → {OUTPUT_PATH}")
    print(f"\nLabel distribution:")
    from collections import Counter
    counts = Counter(r["label"] for r in rows)
    for label, count in sorted(counts.items()):
        print(f"  {label:15s} {count}")
    print(f"\n  TOTAL: {len(rows)}")


if __name__ == "__main__":
    generate()
