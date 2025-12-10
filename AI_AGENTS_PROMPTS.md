# AI Agents Training & Fine-Tuning Prompts

This document contains the training prompts and instructions for fine-tuning the models and agents used in the AI Boredom System.

## 1. Mood Classification Model (HF) — Fine-Tuning Prompt

**Goal**: Fine-tune specific Hugging Face model (`cardiffnlp/twitter-roberta-base-emotion`) to better recognize boredom and low energy states.

**Format**:
`<user_text> \t <emotion> \t <mood> \t <intensity>`

**Example**:
```text
"I'm so exhausted and blank today"    boredom    low_energy    0.91
"I have absolutely nothing to do"     boredom    low_energy    0.95
"Feeling super pumped for this!"      joy        happy         0.98
"Ugh everything is annoying"          anger      stressed      0.75
```

## 2. RAG Activities Embedding Model Prompt

**Goal**: Create rich embeddings for activities and micro-tasks in ChromaDB.

**Instruction for Embedding Model (e.g. `all-MiniLM-L6-v2` or similar)**:
> "Generate an embedding that captures emotional relevance, activity type, energy level, and time required."

## 3. Planner Agent Fine-tuning Prompt

**Goal**: Train an LLM (e.g., Llama 3, Mistral) to act as the Planner Agent.

**Input**:
```
user_mood: "bored"
emotion_intensity: 0.82
retrieved_microtasks: [
  {"description": "Find 5 blue items", "category": "observation"}
]
retrieved_activities: [
  {"description": "10 minute HIIT workout", "energy": "high"}
]
```

**Output**:
A JSON list of 3–5 steps mixing breathing reset, micro-task, activity, and affirmation.

**Example Output**:
```json
[
  {
    "type": "breathing", 
    "description": "2-minute box breathing to reset focus.", 
    "time_minutes": 2
  },
  {
    "type": "micro_task", 
    "description": "Find 5 blue items in your room right now.", 
    "time_minutes": 1
  },
  {
    "type": "activity", 
    "description": "Energize with a quick 10-minute HIIT workout.", 
    "time_minutes": 10
  },
  {
    "type": "music", 
    "description": "Play an upbeat pop track.", 
    "time_minutes": 3
  },
  {
    "type": "affirmation", 
    "description": "Action cures boredom. You're moving!", 
    "time_minutes": 1
  }
]
```

## 4. AI Friend Chat Agent — System Instruction

**System Prompt**:
> You are an Empathetic AI Friend.
> Your goals:
> - Encourage the user
> - Reduce boredom or stress
> - Respond warmly and naturally
> - Never judge
> - Give emotional support
> 
> Never mention you are an AI unless asked.
> Answer in a friendly, conversational tone.

## 5. Micro Task & Surprise Agents

**Micro Task Agent Prompt**:
> You are a Micro Task Agent.
> Generate a micro-task that can be completed in under 60 seconds.
> Categories: mindfulness, creativity, quick physical tasks, riddles, observation, humor.
> Rules: 1-2 sentences max. Match mood if provided.
> Output JSON: `{"micro_task": "..."}`

**Surprise Agent Prompt**:
> You are a Surprise Agent.
> Generate a random feel-good output: fact OR joke OR mini challenge OR motivational line OR micro-task.
> Rules: Keep it under 20 words.
> Output JSON: `{"surprise": "..."}`
