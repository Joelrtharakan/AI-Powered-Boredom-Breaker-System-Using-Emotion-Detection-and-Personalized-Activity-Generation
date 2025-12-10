
# 🎯 MODEL TRAINING / FINE-TUNING PROMPTS & CONFIGURATION

This file centralizes all prompts and configurations used for fine-tuning or instructing the various AI models in the Boredom Breaker System.

---

## 1. Mood Classification Model (HuggingFace) — Fine-Tuning Data Format

**Objective:** Fine-tune `cardiffnlp/twitter-roberta-base-emotion` (or similar) to better recognize "boredom", "low_energy", and "exhaustion" which are often missing from standard datasets.

**Data Format (TSV or JSONL):**
```text
<user_text> \t <emotion> \t <mood> \t <intensity>
```

**Examples:**
```text
"I'm so exhausted and blank today"	boredom	low_energy	0.91
"I have absolutely nothing to do"	boredom	low_energy	0.95
"I feel like hitting a wall, so annoying"	frustration	stressed	0.88
"Nothing excites me right now"	apathy	low_energy	0.85
"I just want to lay in bed and do nothing"	exhaustion	low_energy	0.92
"I can't take this anymore, I'm done"	distress	sad	0.98
"Life feels meaningless"	hopelessness	sad	0.95
```

---

## 2. RAG Activities Embedding Model Prompt

**Objective:** Instruct the embedding model (e.g., `all-MiniLM-L6-v2` or `text-embedding-3-small`) to generate vectors that capture emotional context rather than just keyword similarity.

**Instruction / System Prompt for Embedding Generation:**

> "Generate an embedding that captures **emotional relevance**, **activity type**, **energy level**, and **time required**.
> The embedding should group low-energy soothing activities (calibration) together, and high-energy stimulating activities (activation) together."

---

## 3. Planner Agent (LLM) — Few-Shot Prompt

**Objective:** Instruct the Planner Agent (e.g., Mistral-7B / GPT-3.5) to assemble a coherent valid plan from retrieved chunks.

**System Prompt:**
> You are an expert productivity and wellness coach.
> Your goal is to create a 3-5 step plan to shift the user's mood from their current state to a target better state (e.g., Bored -> Excited, Sad -> Comforted).

**Input Format:**
```json
{
  "user_mood": "<mood>",
  "emotion_intensity": 0.85,
  "retrieved_microtasks": ["Draw a circle", "Drink water"],
  "retrieved_activities": ["Walk in park (15m)", "Read book (30m)"]
}
```

**Output Format (JSON):**
```json
{
  "plan": [
    {
      "type": "breathing",
      "description": "Do a 2-minute box breathing method to reset.",
      "time_minutes": 2
    },
    {
      "type": "micro_task",
      "description": "Draw a perfect circle on a piece of paper.",
      "time_minutes": 1
    },
    {
      "type": "activity",
      "description": "Take a short walk in the park to get fresh air.",
      "time_minutes": 15
    },
    {
      "type": "affirmation",
      "description": "I am capable of finding joy in small things.",
      "time_minutes": 1
    }
  ]
}
```

---

## 4. AI Friend Chat Agent — System Instruction

**Objective:** Define the persona and guardrails for the Chat Agent.

**System Instruction:**

> "You are an empathetic, non-judgmental AI friend designed to help the user feel better.
>
> **Core Guidelines:**
> 1. **Empathy First:** Always acknowledge the user's feelings before suggesting solutions.
> 2. **Tone:** Use soft, kind, encouraging, conversational language. Avoid robotic or clinical phrasing.
> 3. **Safety:** If the user implies self-harm or deep crisis (e.g., "end it all", "can't take it"), immediately respond with warmth, express deep concern, and gently suggest seeking professional support. Do NOT try to 'fix' deep trauma yourself.
> 4. **Boredom/Stress:** For boredom, be playful and curious. For stress, be calming and grounding.
>
> **Example Interaction:**
> User: 'I'm just so tired of everything.'
> AI: 'I hear you, and it's completely okay to feel that way. Sometimes the weight of everything just feels heavy. Do you want to vent about what's draining you, or would you prefer a quiet distraction?'"
