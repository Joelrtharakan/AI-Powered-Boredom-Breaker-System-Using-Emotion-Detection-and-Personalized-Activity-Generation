import asyncio
import json
import random
import logging
from crewai import Agent, Task, Crew
from app.services.llm_service import llm_service
from app.services.chroma_service import chroma_service

class MicroTaskAgent:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        # Categories preserved from your script
        self.categories = ["mindfulness", "creativity", "physical", "riddle", "observation", "humor"]
    
    async def generate(self, mood: str = "neutral"):
        """Generates a contextual micro-task using ChromaDB RAG and CrewAI."""
        
        # 1. RETRIEVE FROM CHROMADB (RAG)
        try:
            # Query for tasks semantically related to the mood
            query_text = f"a quick {mood} task to reset"
            raw_tasks = chroma_service.query_microtasks(query_text=query_text, n_results=3)
            canonical_tasks = ""
            if raw_tasks and raw_tasks.get('documents') and raw_tasks['documents'][0]:
                docs = raw_tasks['documents'][0]
                canonical_tasks = "\n".join([f"- {d}" for d in docs])
                self.logger.info(f"Retrieved {len(docs)} micro-tasks from ChromaDB.")
        except Exception as e:
            self.logger.error(f"ChromaDB Retrieval Failed: {e}")
            canonical_tasks = "None found in database."

        # 2. Directive mapping
        if mood in ["stressed", "anxious"]:
            focus = "calming mindfulness and grounding"
        elif mood in ["bored", "low_energy"]:
            focus = "engaging physical activity, creativity or humor to boost energy"
        else:
            focus = "a creative or observation-based task"

        # 3. Create Task with RAG context
        agent = await asyncio.get_event_loop().run_in_executor(
            None, 
            lambda: Agent(from_repository="micro-task-specialist", llm=llm_service.crew_llm)
        )

        task = Task(
            description=(
                f"Create a unique, one-sentence micro-task for a user feeling {mood}.\n"
                f"Focus Area: {focus}.\n"
                f"CANONICAL EXAMPLES (Use as inspiration): \n{canonical_tasks}\n"
                f"Category must be one of: {self.categories}."
            ),
            expected_output="JSON with keys 'micro_task' (string) and 'category' (string).",
            agent=agent
        )

        crew = Crew(agents=[agent], tasks=[task], verbose=False)

        try:
            response = await asyncio.to_thread(crew.kickoff)
            cleaned = str(response)
            if "```json" in cleaned:
                cleaned = cleaned.split("```json")[1].split("```")[0].strip()
            
            data = json.loads(cleaned)
            return {
                "micro_task": data.get("micro_task", "Take a slow, deep breath."),
                "category": data.get("category", "mindfulness"),
                "target_mood": mood,
                "source": "ChromaDB_RAG" if canonical_tasks else "LLM_Generated"
            }
        except Exception as e:
            self.logger.error(f"MicroTask LLM Failed: {e}")
            return {
                "micro_task": "Find 3 blue objects in your room and count them.",
                "category": "observation",
                "target_mood": mood,
                "source": "Fallback"
            }

microtask_agent = MicroTaskAgent()
