
import random
import pandas as pd
import os

# ============================================================
# RICH SYNTHETIC DATA GENERATOR
# Purpose: Create diverse, natural-sounding training examples
# for each emotion category. Unlike the original 10-template
# generator, this has 50+ templates per category with
# variations in phrasing, slang, and intensity.
# ============================================================

templates = {

    # ============================================
    # SADNESS - Deep emotional pain, hopelessness
    # ============================================
    "sadness": [
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
        "i can't take it anymore",
        "cant take it anymore",
        "i am so done with everything",
        "why does nothing work out for me",
        "feeling empty inside",
        "my heart hurts",
        "i just want to disappear",
        "nobody cares about me",
        "i feel so alone",
        "everything is falling apart",
        "i'm drowning",
        "lost all hope",
        "why am i even here",
        "i am so unhappy",
        "crying myself to sleep",
        "why is life been like this",
        "i am disturbed",
        "life has been so unfair",
        "i feel completely destroyed",
        "everything hurts",
        "feels like the end",
        "i can't stop crying",
        "so much pain",
        "i feel worthless",
        "no reason to go on",
        "i'm devastated",
        "heartbroken beyond repair",
        "life is meaningless",
        "i just want it to stop",
        "everything is hopeless",
        "i feel defeated",
    ],

    # ============================================
    # LOW ENERGY BORED - Lethargic, unmotivated
    # ============================================
    "low_energy_bored": [
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
        "so dull",
        "I've been staring at the wall for hours doing nothing",
        "Doomscrolling and I can't stop even though I hate it",
        "Literally just laying in bed rotting",
        "Brain empty, no thoughts, just bored",
        "Too tired to do anything fun but too bored to sleep",
        "Feeling so lethargic, can't even get up",
        "My energy is at zero, just melting into the couch",
        "I have absolutely nothing to do and no motivation",
        "Watching paint dry would be more exciting than this",
        "Just scrolling aimlessly through my phone",
        "i need a break from this boring life",
        "today has been so uneventful",
        "bored out of my mind",
        "nothing to look forward to",
        "just existing",
        "dead inside from boredom",
        "another boring day",
        "mind-numbingly boring",
        "i have zero motivation",
        "can't be bothered to do anything",
        "so understimulated right now",
        "feel like a zombie",
        "dragging through the day",
        "utterly bored",
        "kill me with this boredom",
        "there is nothing to do",
        "staring at the ceiling again",
        "this day is going nowhere",
        "flat out bored",
        "need something to do",
        "i am so bored i could cry",
        "uneventful and dull",
        "my life is so mundane",
        "stuck in a rut",
        "everything feels repetitive",
    ],

    # ============================================
    # RESTLESS BORED - High energy, nowhere to go
    # ============================================
    "restless_bored": [
        "I wanna do something but idk what to do",
        "Got so much energy but stuck in this room",
        "Need to go out or I will explode",
        "Bouncing off the walls rn",
        "Itching to start a project but can't focus on one",
        "I feel like running a marathon but I'm trapped here",
        "So restless, I can't sit still for more than a minute",
        "My leg won't stop shaking, I need stimulation",
        "Feel like screaming just to break the silence",
        "Need an adventure or something exciting to happen ASAP",
        "Pacing around the house with nothing to do",
        "I need to get out of here",
        "Can't sit still, need to move",
        "Climbing the walls with boredom",
        "I am crawling out of my skin",
        "So antsy right now",
        "fidgety and restless",
        "I need action, something, anything",
        "explosive energy with nowhere to channel it",
        "I could run through a wall right now",
        "can't focus on one thing, brain is everywhere",
        "hyper but trapped",
        "bouncing off the walls with all this energy",
        "i need to go somewhere NOW",
        "so much pent up energy",
        "can't settle down",
        "agitated and can't relax",
        "i need stimulation or i'll go crazy",
        "feel like i'm going to burst",
        "fidgeting like crazy",
    ],

    # ============================================
    # STRESSED - Pressure, overwhelmed
    # ============================================
    "stressed": [
        "So many deadlines I'm actually cooked",
        "This assignment is killing me slowly",
        "Pressure is getting to me I might crash out",
        "So much work to do and zero time",
        "My head is pounding from all this stress",
        "I am overwhelmed by everything on my plate right now",
        "Can't believe how much I have to get done",
        "Feeling crushed under the weight of expectations",
        "Stress level 100, about to lose it",
        "Panic mode initiated, too much to do",
        "i need a break",
        "i need a break from all this",
        "everything is piling up",
        "too much on my plate",
        "drowning in work",
        "my brain is fried from all this work",
        "under so much pressure right now",
        "stressed beyond belief",
        "can't handle all this responsibility",
        "so overwhelmed right now",
        "i'm going to explode from pressure",
        "burning out at work",
        "work is destroying me",
        "deadline after deadline",
        "no time to breathe",
        "my head is splitting from stress",
        "juggling too many things",
        "i'm spread too thin",
        "responsibilities are crushing me",
        "too much is going on",
        "i'm maxed out",
        "stress is eating me alive",
        "need to decompress",
        "on the verge of a breakdown from work",
        "so much pressure it hurts",
        "heavy workload is killing me",
        "i'm suffocating under all this work",
        "when will this stress end",
        "working myself to death",
        "the grind never stops and i'm tired of it",
    ],

    # ============================================
    # ANXIOUS - Worry, dread, unease
    # ============================================
    "anxious": [
        "What if I fail this exam I'm scared",
        "Heart beating so fast for no reason",
        "Feeling kinda nervous about tomorrow",
        "Spiraling rn can't breathe properly",
        "Got that pit in my stomach feeling",
        "My hands are shaking and I feel uneasy",
        "Worried that something bad is about to happen",
        "Can't shake this feeling of dread",
        "Anxiety is high today, hard to focus",
        "Feeling jittery and on edge",
        "i am so nervous",
        "my heart won't stop racing",
        "constant state of worry",
        "something feels off and I'm scared",
        "i keep getting panic attacks",
        "what if everything goes wrong",
        "i'm terrified of the future",
        "anxiety through the roof",
        "sweating and shaking for no reason",
        "i feel like something terrible is coming",
        "can't calm down",
        "restless with fear",
        "worried sick about everything",
        "my mind won't stop worrying",
        "living in constant fear",
        "feel like i'm on the edge",
        "tight chest and racing thoughts",
        "i don't feel safe",
        "everything makes me anxious",
        "scared of what's next",
    ],

    # ============================================
    # OVERTHINKING - Rumination, mental loops
    # ============================================
    "overthinking": [
        "Why did I say that stupid thing earlier",
        "Replaying that conversation over and over in my head",
        "My brain won't shut up about the past",
        "Thinking about every possible way this could go wrong",
        "Stuck in a loop of negative thoughts",
        "Can't stop analyzing every little detail",
        "Wondering if they hate me after what I said",
        "My mind is racing with what ifs",
        "Trapped in my own head right now",
        "Obsessing over things I can't change",
        "i really dont know what to do",
        "can't stop thinking about it",
        "going in circles in my head",
        "second guessing every decision",
        "did i make the right choice",
        "overanalyzing everything",
        "what if they're mad at me",
        "my thoughts won't let me rest",
        "spiraling into negative thoughts",
        "brain is on overdrive",
        "can't sleep because of my thoughts",
        "going over it again and again",
        "the thought won't leave my head",
        "should I have done that differently",
        "constantly questioning myself",
        "my mind is a mess of thoughts",
        "analyzing every word they said",
        "lost in thought and can't escape",
        "mental hamster wheel going nonstop",
        "thinking too much about everything",
    ],

    # ============================================
    # EMOTIONALLY FLAT - Numb, apathetic
    # ============================================
    "emotionally_flat": [
        "Just feeling kinda meh today",
        "Not happy not sad just existing",
        "Empty inside ngl",
        "Don't really care about anything rn",
        "Emotionally numb just floating",
        "Feel like a robot, programmed to just be",
        "Nothing really matters to me right now",
        "Apathy is the only thing I feel",
        "Just going through the motions",
        "Blank mind, blank feelings",
        "nothing seems to be happening in life right now",
        "i feel nothing",
        "emotionally dead inside",
        "can't feel anything",
        "numb to everything",
        "don't care anymore",
        "flatlined emotionally",
        "existing without purpose",
        "no emotions left",
        "autopilot mode",
        "hollow inside",
        "disconnected from everything",
        "i'm on autopilot",
        "just surviving not living",
        "empty shell",
        "void of emotion",
        "indifferent to everything",
        "no highs no lows just... nothing",
        "lost interest in everything",
        "going through life on mute",
    ],

    # ============================================
    # CALM - Peaceful, relaxed
    # ============================================
    "calm": [
        "Just vibing with some music",
        "Finally relaxing after a long day",
        "Feeling peaceful rn",
        "Chilling at home watching movies",
        "Zen mode activated",
        "Enjoying the quiet moment",
        "Feeling centered and at peace",
        "No stress, just relaxation",
        "Taking a nice warm bath and chilling",
        "Meditation really helped, feeling calm",
        "at peace with everything",
        "serene and relaxed",
        "tranquil evening",
        "calm and collected",
        "deep breaths, feeling good",
        "everything is okay right now",
        "relaxed and content",
        "unwinding nicely",
        "peaceful state of mind",
        "chill vibes only",
        "feeling balanced and grounded",
        "quiet mind, happy heart",
        "stress-free moment",
        "letting go of worries",
        "in my happy place",
        "soaking in the calmness",
        "nothing bothering me right now",
        "tranquility at last",
        "just breathing and being",
        "comfortable and at ease",
    ],

    # ============================================
    # FOCUSED - In the zone, productive
    # ============================================
    "focused": [
        "Locked in on this project",
        "Totally in the zone rn",
        "Grinding on this code",
        "Studying hard and making progress",
        "Laser focused distinct lack of distractions",
        "Hyper-fixated on finishing this task",
        "Productivity is through the roof",
        "Nothing can distract me right now",
        "Deep work session, feeling good",
        "Coding marathon, fully immersed",
        "in flow state",
        "tunnel vision on my work",
        "can't stop won't stop, making progress",
        "head down, grinding",
        "100% concentration",
        "completely absorbed in what i'm doing",
        "crushing my to-do list",
        "focused like a laser beam",
        "no distractions allowed",
        "full steam ahead on this project",
        "brain is firing on all cylinders",
        "peak performance mode",
        "undivided attention on work",
        "dialed in and productive",
        "cranking through tasks",
        "making serious headway",
        "everything is clicking today",
        "in the flow and loving it",
        "singular focus right now",
        "on a roll and can't stop",
    ],

    # ============================================
    # POSITIVE ENGAGED - Happy, excited, upbeat
    # ============================================
    "positive_engaged": [
        "Omg this is amazing let's gooo!",
        "Feeling so hyped for tonight",
        "Actually having a good day for once",
        "This song slaps I'm happy",
        "Can't wait to see my friends",
        "So excited about the news!",
        "Feeling great and full of energy",
        "Loving life right now!",
        "Today is going to be awesome",
        "Radiating positive vibes",
        "best day ever",
        "on top of the world",
        "i'm so happy right now",
        "life is beautiful",
        "everything is going right",
        "feeling blessed",
        "so pumped for this",
        "pure joy right now",
        "can't stop smiling",
        "heart is full",
        "incredible day",
        "ecstatic about everything",
        "good vibes only today",
        "living my best life",
        "this made my day",
        "feeling alive and grateful",
        "bursting with happiness",
        "today is a great day to be alive",
        "so much to celebrate",
        "feeling euphoric",
    ],

    # ============================================
    # NEUTRAL - Neither positive nor negative
    # ============================================
    "neutral": [
        "Ok",
        "Alright",
        "I guess so",
        "Maybe later",
        "Its fine",
        "Just normal",
        "Whatever",
        "Sure",
        "Not much happening",
        "Standard day",
        "the sky is blue",
        "i went to the store",
        "it is what it is",
        "hello there",
        "just wondering",
        "what time is it",
        "random thoughts",
        "nothing special",
        "average day",
        "just a regular Tuesday",
        "hmm okay",
        "I see",
        "that's fine",
        "makes sense",
        "cool",
        "understood",
        "got it",
        "no comment",
        "noted",
        "fair enough",
    ],
}

# Variation functions to increase diversity
def add_typo_variations(text):
    """Create slight variations by adding common typos/shortcuts"""
    variations = [text]
    # lowercase
    variations.append(text.lower())
    # Remove punctuation
    import re
    variations.append(re.sub(r'[^\w\s]', '', text))
    # Common text shortcuts
    text_lower = text.lower()
    replacements = {
        "i'm": "im",
        "i am": "im",
        "can't": "cant",
        "don't": "dont",
        "won't": "wont",
        "what is": "whats",
        "it is": "its",
        "that is": "thats",
        "i have": "ive",
        "does not": "doesnt",
        "do not": "dont",
        "cannot": "cant",
        "will not": "wont",
        "should not": "shouldnt",
    }
    modified = text_lower
    for old, new in replacements.items():
        if old in modified:
            modified = modified.replace(old, new)
            variations.append(modified)
            break
    return list(set(variations))


def generate_dataset():
    data = []
    
    for label, phrases in templates.items():
        for phrase in phrases:
            # Add the original
            data.append({"text": phrase, "label": label})
            
            # Add typo / informal variations
            for var in add_typo_variations(phrase):
                data.append({"text": var, "label": label})
    
    df = pd.DataFrame(data)
    
    # Remove exact duplicates
    df = df.drop_duplicates(subset=["text", "label"])
    
    # Shuffle
    df = df.sample(frac=1, random_state=42).reset_index(drop=True)

    output_path = "data/rich_synthetic_dataset.csv"
    os.makedirs("data", exist_ok=True)
    df.to_csv(output_path, index=False)
    
    print(f"Generated {len(df)} rich synthetic samples into {output_path}")
    print("\nLabel distribution:")
    print(df["label"].value_counts())


if __name__ == "__main__":
    generate_dataset()
