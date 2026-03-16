# 🚀 AI-Powered Boredom Breaker System: Technical Deep-Dive

**An advanced, mood-aware recovery ecosystem designed to combat student burnout, stagnation, and emotional fatigue using Multi-Agent Orchestration and Fine-Tuned Transformers.**

---

## 📌 Project Architecture
The system is built on a **Hybrid AI Framework** that bridges deep emotional understanding with actionable behavioral interventions. It doesn't just "distract" the user; it actively diagnoses their emotional state and prescribes a clinically-aligned recovery path.

---

## 🧠 The Brain: Model Fine-Tuning & Algorithms

### 1. Fine-Tuning Methodology (Domain Adaptation)
We utilized a **Transformer-based Architecture** (`RoBERTa-base`) and performed supervised fine-tuning to adapt it for high-fidelity student emotion detection.
*   **The Problem:** Standard models often confuse "Boredom" with "Neutrality." 
*   **The Solution:** We trained a custom layer on a curated dataset of ~1,500 student-specific expressions (slang, stress markers, academic burnout cues).
*   **Technique:** We used **Weighted Cross-Entropy Loss** to prioritize "high-risk" emotions (like Distress or Fatigue) and implemented **Layer Freezing** on the initial RoBERTa blocks to preserve general linguistic intelligence while specializing the final heads for 10 custom labels (e.g., `restless_bored`, `overthinking`, `focused`).

### 2. Core Algorithms
*   **Emotion Detection:** `Transformer Ensemble (RoBERTa)`. Understands context, sarcasm, and complex emotional shifts.
*   **Arcade Logic:** `Minimax Algorithm`. Powers the Tic-Tac-Toe AI with a recursive depth-first search, making it mathematically perfect and "unbeatable."
*   **Agentic Decisions:** `ReAct (Reason + Act) Pattern`. Agents "think" about the user's state before selecting tools (Spotify/Games).
*   **Metadata Integration:** `Regex Word-Boundary Heuristics`. Instantly extracts song/game titles from conversational text to inject deep-links.

---

## 🤖 The Multi-Agent Ecosystem (CrewAI)
The system uses **CrewAI** to orchestrate specialized personas. Agents are built using a **Modular Design Pattern**, ensuring each has a distinct "System Prompt" and behavioral constraint.

| Agent | Role | Logic |
| :--- | :--- | :--- |
| **🧠 Router Agent** | The Strategic Director | Analyzes mood intensity to decide: Do we give a **Plan**, a **Chat**, or a **Micro-Task**? |
| **🗓️ Planner Agent** | The Architect of Recovery | Designs 3-step arcs. Step 1: Grounding -> Step 2: Processing -> Step 3: Modern Music/Game. |
| **💬 Luno (Chat Agent)** | The Empathetic Confidant | A conversational specialist for validation using CBT (Cognitive Behavioral Therapy) dialog patterns. |
| **⚡ Micro-Task Agent** | The Instant Win Specialist | Prescribes 60-second actions (stretches, breathing) for users with zero energy. |
| **🎁 Surprise Agent** | The Dopamine Booster | Delivers random interesting facts, riddles, or "Boredom Buster" surprises. |

---

## 🔄 The Technical Workflow
1.  **Input Ingestion**: User provides text/voice (e.g., "I'm so cooked from these finals").
2.  **Emotion Pipeline**:
    *   **Safety Check**: Scan for crisis markers (Kiran Helpline protocol).
    *   **Transformer Inference**: RoBERTa calculates emotion/intensity/risk.
    *   **Synthesis**: Combines data into a unified `State` (e.g., STRESSED, HIGH INTENSITY).
3.  **Agentic Routing**: The Router decides the intervention depth.
4.  **Generation**: The Planner synthesizes a JSON plan with specific Modern Spotify tracks and Arcade Games.
5.  **Metadata Injection**: Post-processors scan the plan to inject `spotify_url` and `game_buttons`.
6.  **Interactive Delivery**: Mobile UI renders the plan with direct-navigation buttons.

---

## 🎮 Arcade Zone: The Game List
*   **Tic-Tac-Toe**: High-stakes AI using the **Minimax Algorithm**.
*   **Snake Evolution**: classic reflex-based grounding.
*   **Aim Trainer**: Interactive focus and hand-eye coordination.
*   **Reaction Time**: High-speed cognitive engagement.
*   **Memory Flip**: Logic-based pattern recognition.
*   **Chimp Test**: Advanced visual sequence recall.
*   **Guess Number / Rock Paper Scissors**: Quick, low-stakes decision breaks.

---

## 📜 History & Personalization
The **History Page** acts as a "Well-being Ledger":
*   **Temporal Tracking**: Sessions are saved with timestamps, moods, and energy intensity.
*   **Real-Time Sync**: Uses a backend-to-frontend relay ensuring the "Total Logs" count is always accurate.
*   **Personalized Analytics**: The system looks at your history to notice patterns (e.g., "You're often stressed on Tuesdays") and adjusts agent personas to be more supportive during those times.
*   **The Loop**: Your past history is fed back into the **Agent Context**, so Luno remembers your recent struggles and tailors her "Hey there!" to your current recovery progress.

---

## ✨ Features Checklist
*   ✅ **Mood Detection**: Fine-tuned RoBERTa transformer logic.
*   ✅ **Smart Spotify**: Auto-filtering of old 90s music; only modern (2024-2025) recovery tracks.
*   ✅ **Direct Navigation**: Buttons that launch songs or games with one tap.
*   ✅ **Lockbox Vault**: End-to-End Encrypted journaling.
*   ✅ **Luno Voice**: Interactive voice-based AI companion.
*   ✅ **Multilingual Support**: Distress detection in English and Tamil.
*   ✅ **Crisis Override**: Instant access to verified helplines.

---
*Built for students, by code. Stability, Empathy, and Activation.*
