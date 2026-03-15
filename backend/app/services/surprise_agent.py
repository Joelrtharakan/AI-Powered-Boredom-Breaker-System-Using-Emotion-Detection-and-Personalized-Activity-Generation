import asyncio
import random
import logging
from crewai import Agent, Task, Crew
from app.services.llm_service import llm_service
from app.services.microtask_agent import microtask_agent

class SurpriseAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.types = ["fact", "joke", "motivational", "micro_task", "challenge"]
        
    async def generate(self):
        """Generates a joyful surprise using the CrewAI Joy Specialist."""
        type_ = random.choice(self.types)
        
        # 1. Routing to Micro-Task Agent if selected
        if type_ == "micro_task":
             content = await microtask_agent.generate()
             return {
                 "surprise": content['micro_task'],
                 "type": "micro_task"
             }

        # 2. Logic for Challenges (Short actionable tasks)
        if type_ == "challenge":
            challenges = [
                "Drink a glass of water right now.",
                "Text a friend that you appreciate them.",
                "Do a slow, deep stretch for 30 seconds.",
                "Close your eyes and take 5 deep breaths.",
                "Name 3 things you are grateful for."
            ]
            return {"surprise": random.choice(challenges), "type": "challenge"}

        # 3. Agentic Generation for Facts, Jokes, and Motivation
        agent = await asyncio.to_thread(
            Agent, 
            from_repository="joy-specialist", 
            llm=llm_service.crew_llm
        )

        task = Task(
            description=f"Generate one unique and interesting {type_}. Keep it extremely short (under 20 words).",
            expected_output=f"A single short {type_} string.",
            agent=agent
        )

        crew = Crew(agents=[agent], tasks=[task], verbose=False)

        try:
            response = await asyncio.to_thread(crew.kickoff)
            return {
                "surprise": str(response).strip(),
                "type": type_
            }
        except Exception as e:
            self.logger.error(f"Surprise Agent Failed: {e}")
            return {
                "surprise": "Did you know? Honey never spoils. Archaeologists have found edible honey in ancient Egyptian tombs!",
                "type": "fact"
            }

surprise_agent = SurpriseAgent()
