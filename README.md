# 🚀 AI-Powered Boredom Breaker System
**An intelligent, mood-aware ecosystem designed to detect burnout, combat boredom, and enhance mental well-being for students.**

---

## 📌 Project Vision
Most boredom-reduction apps simply provide random distractions. The **AI Boredom Breaker** takes a clinical yet empathetic approach by first understanding the user's *internal state*. Whether a user is "Restless Bored" (high energy, no outlet) or "Low Energy Bored" (exhaustion masquerading as boredom), the system adapts its strategy to provide the right intervention at the right time.

---

## 🧠 The Emotion Intelligence Engine (Deep Dive)
The core of this project is a multi-layered **Hybrid Classification Engine** that combines Deep Learning with a Rule-Based Expert System.

### 1. The Emotion Workflow
When a user provides input (Journal, Chat, or Mood Check), the text passes through a 6-stage pipeline:

1.  **🚀 Semantic Fast-Path**: If the input is short (<10 words) and contains definitive keywords (e.g., "so bored"), the system uses the **Semantic Engine** for an instant result, bypassing GPU/CPU inference to save ~2 seconds of latency.
2.  **🛡️ Safety & Risk Intercept**: Before any AI processing, a **Risk Assessment** layer scans for Crisis signals (self-harm, deep distress) in multiple languages (including English and Tamil). If detected, it triggers a **Crisis Protocol** override.
3.  **🤖 Transformer Inference (Fine-Tuned RoBERTa)**: The text is processed by a `roberta-base` model. We use an ensemble approach, prioritizing our latest fine-tuned weights (`v14_final_model`) before falling back to base versions.
4.  **🎭 Ensemble Fusion**: The system "fuses" the Transformer's context awareness with the Semantic Engine's keyword accuracy.
    *   *Consensus:* If both agree, confidence is boosted.
    *   *Contrastive Logic:* If the user says "I am sad BUT happy for him," the system identifies the "But" and prioritizes the Transformer's contextual understanding over simple keyword counts.
5.  **📉 Tactical Overrides**:
    *   *Mundane Filter:* Prevents "Happy" or "Sad" flags for logistical text (e.g., "I'm eating toast").
    *   *Task-Blocked Detection:* Identifies when a user is frustrated specifically by work/assignments.
6.  **🚦 State Synthesis**: The engine outputs a multi-dimensional state:
    *   **Mood/Emotion**: (e.g., `Anxious`, `Stressed`, `Boredom`).
    *   **Nervous System State**: `Hyperaroused` (Anxiety/Anger) vs `Hypoaroused` (Boredom/Depression).
    *   **Strategy Guidance**: Direct instructions for the LLM on how to treat the user (e.g., "NO GAMES. PRIORITY: REST.").

---

## 🛠 Fine-Tuning Methodology
The standard `cardiffnlp/twitter-roberta-base-emotion` model is trained on broad social media categories (Joy, Anger, etc.). To make it effective for student wellness, we performed **Domain Adaptation**.

### Why Fine-Tune?
Standard models often confuse "Boredom" with "Neutrality" or "Sadness." We needed the model to distinguish between:
*   **Restless Boredom**: Needs engagement (Arcade/Activity).
*   **Cognitive Fatigue**: Needs rest/breathing.
*   **Overthinking**: Needs grounding/micro-tasks.

### The Training Pipeline
*   **Base Architecture**: `RoBERTa-base`.
*   **Data Strategy**: Synthetic curation of ~50-100 high-signal student expressions (e.g., "My brain is fried," "I'm just doomscrolling").
*   **Label Schema**: 10 custom labels including `restless_bored`, `overthinking`, `focused`, and `emotionally_flat`.
*   **Fallback Logic**: The `EmotionAnalyzer` uses a `threading.Lock` to load models dynamically. If the fine-tuned weights Fail to load, it seamlessly reverts to the base `twitter-roberta` to ensure 100% uptime.

---

## 🤖 The Multi-Agent Ecosystem (CrewAI Orchestration)
The system is powered by **CrewAI Enterprise**, using a distributed agentic workforce managed via a cloud-based **Agents Repository**. This ensures that agent personas remain consistent across multiple environments.

*   **Empathetic AI Companion**: Optimized for emotional support and warm, concise conversation. Acts as a gentle confidant.
*   **Psychological Health Planner**: Expert in behavioral psychology. Implements structured micro-intervention protocols based on user risk levels.
*   **Micro-Task Specialist**: Specializes in quick, 60-second actionable transitions such as mindfulness, creativity, or light physical movement.
*   **Joy Specialist**: Focused on delivering delightful surprises, interesting facts, jokes, or mini-challenges to boost dopamine and morale.

### Orchestration Workflow
1.  **Request Ingestion**: The FastAPI backend receives the user's emotional state.
2.  **Remote Persona Loading**: Agents are instantiated using `from_repository` to pull the latest optimized personas from the CrewAI Cloud.
3.  **Task Execution**: Each agent is assigned a context-aware `Task` with strict formatting requirements (JSON plans or concise conversational strings).
4.  **Ensemble Kickoff**: A Crew is formed to execute the task asynchronously, ensuring responsive performance in the mobile app.

---

## 🎮 Arcade Zone
When the system detects `Restless Boredom`, it unlocks the Arcade:
*   **Tic-Tac-Toe**: Features an unbeatable AI using the **Minimax Algorithm**.
*   **Snake**: A classic reflex-based game for grounding.
*   **Rock Paper Scissors**: A quick, low-stakes decision game.

---

## 💻 Tech Stack
| Layer | Technologies |
| :--- | :--- |
| **Frontend** | React (Vite), Tailwind CSS, Framer Motion, Recharts |
| **Mobile** | Flutter (Dart) |
| **Backend** | Python FastAPI, SQLAlchemy, Pydantic |
| **AI/ML** | Hugging Face Transformers, PyTorch, CrewAI, Langchain, OpenRouter |
| **Database** | SQLite (Relational), ChromaDB (Vector/RAG) |

---

## ✨ Key Features
- **voice**: Luno assistant.
- **music**: Spotify/Music.
- **chat**: AI Friend companion.
- **lockbox**: **End-to-End Encrypted (E2EE) Vault** for sensitive journal entries or personal notes, ensuring the server never sees the plaintext data.

---

## 🌍 Multilingual & Cultural Awareness
Unlike generic emotion models, our system is tuned for:
*   **Gen Z / Internet Slang**: Interpets "cooked", "mid", "touch grass", and "no cap" to identify energy levels and emotional weight.
*   **Multilingual Distress**: Includes hardcoded support for **Tamil** distress markers (e.g., "mudiyala", "enaku mudiyala") to prioritize safety in diverse user contexts.
*   **Contextual Refusal**: Detects nonsensical inputs or "garbage" text (key-mashes) and gracefully asks for clarification instead of guessing an emotion.

---

## 🔒 Security & Privacy (The Lockbox)
The project implements a **Digital Lockbox** system:
1.  **Client-Side Encryption**: Data is encrypted locally using the user's keys.
2.  **Encrypted Persistence**: The backend stores the Base64-encoded encrypted blob.
3.  **Local Decryption**: Only a user-authenticated client can retrieve and decrypt the vault, ensuring total privacy.

---

## 🔄 Technical Workflow Summary
1.  **User Input** (Text/Voice) -> 
2.  **API Gateway** (FastAPI) -> 
3.  **Pre-Processor** (Slang/Multilingual Check) -> 
4.  **Semantic Fast-Path** (Keyword Match) -> 
5.  **Transformer Ensemble** (Fine-Tuned RoBERTa v14) -> 
6.  **Regulation Engine** (Safety Overrides) -> 
7.  **Agentic Choice** (Planner/Luno/AI Friend) -> 
8.  **Output** (3-Part Plan/Conversation/Arcade Game).

---

## 🚀 Getting Started

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
*Note: The system will automatically download the ~500MB Transformer model on first boot.*

### 2. Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

### 3. Mobile Setup
```bash
cd boredom_breaker_mobile
flutter pub get
open -a Simulator
flutter run -d EA66F2A1-0EE7-4017-8319-A09259A3E6D3 
```

---

## 🔜 Roadmap
*   **Active Learning**: Frontend "Feedback" button to allow users to correct emotion predictions, automatically expanding the fine-tuning dataset.
*   **Spotify Deep Link**: Direct playback of "Boredom Buster" playlists based on energy levels.
*   **Wearable Integration**: Syncing with heart-rate data for physiological stress detection.

