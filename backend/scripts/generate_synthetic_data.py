
import random
import pandas as pd
import os

# Define templates for each emotion category
templates = {
    "low_energy_bored": [
        "I've been staring at {object} for {duration} just doing nothing.",
        "Doomscrolling {app} and I can't stop even though I hate it.",
        "Literally just laying in bed rotting.",
        "Brain empty, no thoughts, just bored.",
        "Too tired to do anything fun but too bored to sleep.",
        "Feeling so lethargic, can't even get up to retrieve the remote.",
        "My energy is at zero, just melting into the couch.",
        "I have absolutely nothing to do and no motivation to find something.",
        "Watching paint dry would be more exciting than this.",
        "Just scrolling aimlessly through my phone."
    ],
    "restless_bored": [
        "I wanna do something but idk what to do!",
        "Got so much energy but stuck in this room.",
        "Need to go out or I will explode.",
        "Bouncing off the walls rn.",
        "Itching to start a project but can't focus on one.",
        "I feel like running a marathon but I'm trapped here.",
        "So restless, I can't sit still for more than a minute.",
        "My leg won't stop shaking, I need stimulation.",
        "Feel like screaming just to break the silence.",
        "Need an adventure or something exciting to happen ASAP."
    ],
    "stressed": [
        "So many deadlines I'm actually cooked.",
        "This assignment is killing me slowly.",
        "Pressure is getting to me I might crash out.",
        "So much work to do and zero time.",
        "My head is pounding from all this stress.",
        "I am overwhelmed by everything on my plate right now.",
        "Can't believe how much I have to get done.",
        "Feeling crushed under the weight of expectations.",
        "Stress level 100, about to lose it.",
        "Panic mode initiated, too much to do."
    ],
    "anxious": [
        "What if I fail this exam I'm scared.",
        "Heart beating so fast for no reason.",
        "Feeling kinda nervous about tomorrow.",
        "Spiraling rn can't breathe properly.",
        "Got that pit in my stomach feeling.",
        "My hands are shaking and I feel uneasy.",
        "Worried that something bad is about to happen.",
        "Can't shake this feeling of dread.",
        "Anxiety is high today, hard to focus.",
        "Feeling jittery and on edge."
    ],
    "overthinking": [
        "Why did I say that stupid thing earlier?",
        "Replaying that conversation over and over in my head.",
        "My brain won't shut up about the past.",
        "Thinking about every possible way this could go wrong.",
        "Stuck in a loop of negative thoughts.",
        "Can't stop analyzing every little detail.",
        "Wondering if they hate me after what I said.",
        "My mind is racing with 'what ifs'.",
        "Trapped in my own head right now.",
        "Obsessing over things I can't change."
    ],
    "emotionally_flat": [
        "Just feeling kinda meh today.",
        "Not happy not sad just existing.",
        "Empty inside ngl.",
        "Don't really care about anything rn.",
        "Emotionally numb just floating.",
        "Feel like a robot, programmed to just be.",
        "Nothing really matters to me right now.",
        "Apathy is the only thing I feel.",
        "Just going through the motions.",
        "Blank mind, blank feelings."
    ],
    "calm": [
        "Just vibing with some music.",
        "Finally relaxing after a long day.",
        "Feeling peaceful rn.",
        "Chilling at home watching movies.",
        "Zen mode activated.",
        "Enjoying the quiet moment.",
        "Feeling centered and at peace.",
        "No stress, just relaxation.",
        "Taking a nice warm bath and chilling.",
        "Meditation really helped, feeling calm."
    ],
    "focused": [
        "Locked in on this project.",
        "Totally in the zone rn.",
        "Grinding on this code.",
        "Studying hard and making progress.",
        "Laser focused distinct lack of distractions.",
        "Hyper-fixated on finishing this task.",
        "Productivity is through the roof.",
        "Nothing can distract me right now.",
        "Deep work session, feeling good.",
        "Coding marathon, fully immersed."
    ],
    "positive_engaged": [
        "Omg this is amazing let's gooo!",
        "Feeling so hyped for tonight.",
        "Actually having a good day for once.",
        "This song slaps I'm happy.",
        "Can't wait to see my friends.",
        "So excited about the news!",
        "Feeling great and full of energy.",
        "Loving life right now!",
        "Today is going to be awesome.",
        "Radiating positive vibes."
    ],
    "neutral": [
        "Ok.",
        "Alright.",
        "I guess so.",
        "Maybe later.",
        "Its fine.",
        "Just normal.",
        "Whatever.",
        "Sure.",
        "Not much happening.",
        "Standard day."
    ]
}

# Fillers to create variation
objects = ["the wall", "the ceiling", "my phone", "the floor", "space"]
durations = ["an hour", "20 minutes", "forever", "all day", "two hours"]
apps = ["tiktok", "instagram", "twitter", "youtube", "reddit"]

data = []

# Generate 50 samples per category (Total 500 samples)
for label, sentences in templates.items():
    for _ in range(50):
        base = random.choice(sentences)
        # Simple variations
        if "{object}" in base:
            base = base.replace("{object}", random.choice(objects))
        if "{duration}" in base:
            base = base.replace("{duration}", random.choice(durations))
        if "{app}" in base:
            base = base.replace("{app}", random.choice(apps))
            
        data.append({"text": base, "label": label})

# Convert to DataFrame
df = pd.DataFrame(data)

# Save
output_path = os.path.join("data", "emotional_wellness_dataset.csv")
# Ensure data dir exists
os.makedirs("data", exist_ok=True)
df.to_csv(output_path, index=False)
print(f"Generated {len(df)} samples into {output_path}")
