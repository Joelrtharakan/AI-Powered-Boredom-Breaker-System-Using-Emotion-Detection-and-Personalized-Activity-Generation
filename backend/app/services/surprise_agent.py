import random
from app.services.microtask_agent import microtask_agent

class SurpriseAgent:
    def __init__(self):
        self.facts = [
            "Honey never spoils. You can eat 3000 year old honey.",
            "Octopuses have three hearts.",
            "Bananas are curved because they grow towards the sun."
        ]
        self.jokes = [
            "Why don't scientists trust atoms? Because they make up everything!",
            "I'm on a seafood diet. I see food and I eat it.",
            "Parallel lines have so much in common. It’s a shame they’ll never meet."
        ]
        self.motivational = [
            "The best time to plant a tree was 20 years ago. The second best time is now.",
            "You are stronger than you think.",
            "Every moment is a fresh beginning."
        ]
        
    def generate(self):
        # type: fact, joke, challenge, motivational, or micro-task
        type_ = random.choice(["fact", "joke", "motivational", "micro_task", "challenge"])
        
        if type_ == "fact":
             content = random.choice(self.facts)
        elif type_ == "joke":
             content = random.choice(self.jokes)
        elif type_ == "motivational":
             content = random.choice(self.motivational)
        elif type_ == "micro_task":
             content = microtask_agent.generate()['micro_task']
        else: # challenge
             challenges = [
                 "Drink a glass of water right now.",
                 "Text a friend that you appreciate them.",
                 "Do a slow, deep stretch for 30 seconds.",
                 "Close your eyes and take 5 deep breaths.",
                 "Name 3 things you are grateful for."
             ]
             content = random.choice(challenges)
             
        return {
            "surprise": content,
            "type": type_
        }

surprise_agent = SurpriseAgent()
