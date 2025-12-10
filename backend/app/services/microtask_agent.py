import random

class MicroTaskAgent:
    def __init__(self):
        self.tasks = {
            "mindfulness": [
                "Take 3 deep breaths and notice the temperature of the air.",
                "Stare at your hands for 30 seconds and notice every detail.",
                "Listen for the farthest sound you can hear right now."
            ],
            "creativity": [
                "Find an object near you and think of 3 unconventional uses for it.",
                "Doodle a shape and turn it into a monster.",
                "Write a sentence where every word starts with 'S'."
            ],
            "physical": [
                "Stand up and stretch to the ceiling for 10 seconds.",
                "Do 10 rapid jumping jacks.",
                "Rotate your wrists and ankles 5 times each way."
            ],
            "riddle": [
                "What has keys but can't open locks? (A piano)",
                "I speak without a mouth and hear without ears. What am I? (An echo)"
            ],
            "observation": [
                "Find 3 blue objects in your room.",
                "Count how many circles you can see from where you are sitting."
            ],
            "humor": [
                "Make a funny face in the mirror (or phone camera).",
                "Laugh out loud for 5 seconds even if it's fake."
            ]
        }
    
    def generate(self, mood: str = "neutral"):
        # Map mood to category preference
        if mood in ["stressed", "anxious"]:
            category = "mindfulness"
        elif mood in ["bored", "low_energy"]:
            category = random.choice(["physical", "creativity", "humor"])
        else:
            category = random.choice(list(self.tasks.keys()))
            
        task = random.choice(self.tasks[category])
        
        return {
            "micro_task": task,
            "category": category,
            "target_mood": mood
        }

microtask_agent = MicroTaskAgent()
