# 🚀 AI-Powered Boredom Breaker System
**An intelligent, mood-aware application designed to combat boredom and improve mental well-being.**

## 📌 Project Overview
The Boredom Breaker System detects a user's current emotional state using advanced Natural Language Processing (NLP) and generates personalized activities, games, music recommendations, and supportive chat interactions based on their specific mood. It combines deep learning with rule-based safety checks to provide an empathetic and responsive user experience. 

## ✨ Key Features
- **Intelligent Dashboard & Mood Detection**: Analyzes text or voice input to understand your current state.
- **RAG Planner**: Generates personalized, step-by-step 3-part activity plans (e.g., Breathing, Micro-task, Activity) based on mood and energy level.
- **Voice Assistant (Luno)**: A real-time, bi-directional conversational AI with STT/TTS and context memory.
- **🧠 Arcade Zone**: Play classic games like Tic-Tac-Toe (against an unbeatable Minimax AI), Snake, and Rock-Paper-Scissors.
- **📝 Mood Journal**: An encrypted diary where users can log entries, complete with sentiment analysis and a history graph.
- **💬 AI Friend Chat**: A supportive chatbot that adopts different personas (Empathetic Listener or Fun Companion) based on how you feel.
- **"Surprise Me" Module**: Instant, 20-word maximum random fact, joke, or micro-challenge for quick boredom relief.
- **Robust Authentication**: Secure login, registration, and password reset flows powered by JWT.

## 🛠 Tech Stack
- **Frontend**: React (Vite), Tailwind CSS, Framer Motion, Recharts.
- **Mobile**: Flutter.
- **Backend**: Python FastAPI, SQLAlchemy (SQLite), Pydantic.
- **AI/ML Infrastructure**:
  - **Vector DB**: ChromaDB for RAG embeddings.
  - **Emotion Model**: Hugging Face Transformers (`cardiffnlp/twitter-roberta-base-emotion`, fine-tuned).
  - **LLM Integration**: OpenRouter (Mistral) for Agentic workflows.

## 🧠 AI & Architecture Deep Dive

### 1. The Emotion AI Engine
The system uses a hybrid classification engine for unparalleled accuracy and safety:
- **Fine-Tuned RoBERTa Model**: Originally trained on social media data, the model was fine-tuned on a custom dataset of student expressions to recognize nuanced cognitive states like `restless_bored`, `overthinking`, and `focused`.
- **Lexical/Rule-Based Overrides**:
  - **Critical Distress Detection**: Bypasses the AI to immediately flag self-harm or deep crisis signals to ensure user safety.
  - **Gen Z Slang Support**: Hardcoded rules for modern terminology ("cooked", "mid", "touch grass").
  - **Garbage Detectors & Anti-Bias**: Prevents hallucinating emotions from key-mashes or neutral logistical text.

### 2. Multi-Agent Ecosystem
- **Planner Agent**: Synthesizes the exact mood, energy level, and ChromaDB search results to build 3-step JSON action plans.
- **AI Friend Chat Agent**: Provides warm, non-judgmental conversational support without explicitly stating it is an AI.
- **Micro Task Agent**: Generates under-60-second actionable tasks matching the user's energy level.
- **Surprise Agent**: Curates immediate feel-good micro-content (facts, jokes, motivational lines).

### 3. Resiliency
- **Retry & Fallback Mechanism**: If external LLM providers experience downtime, the system fails over to precached "Offline Mode" responses to ensure zero UI crashes.

## 🚀 Setup Instructions

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\\Scripts\\activate
pip install -r requirements.txt
```

### 2. Environment Variables
Create a `backend/.env` file:
```env
SECRET_KEY=supersecret_dev_key
SQLALCHEMY_DATABASE_URI=sqlite:///./boredom_breaker.db

# Optional
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
```

### 3. Run Backend Server
```bash
cd backend
# This will automatically download the ~500MB HuggingFace model on the first run and create tables
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 4. Web Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

### 5. Mobile App Setup (Flutter)
```bash
cd boredom_breaker_mobile
flutter pub get
flutter emulators --launch apple_ios_simulator  # Or your specific emulator
flutter run --no-enable-impeller
```

## 🔜 Roadmap & Next Steps
- **Deep Spotify Integration**: Seamless connection to user accounts for mood-based direct playback control.
- **Expanded Fine-Tuning Data**: Collect more real-world logs to expand the Transformer's accuracy across more obscure cognitive states.
- **Gamification**: Implement streaks and badges for consistent journaling and mood management.
