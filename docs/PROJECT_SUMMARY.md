# AI-Powered Boredom Breaker System - Project Summary

## 🚀 Project Overview
An intelligent, mood-aware application designed to combat boredom and improve mental well-being. The system detects the user's current emotional state using advanced NLP and generates personalized activity plans, games, music recommendations, and supportive chat interactions.

## 🛠 Technology Stack
*   **Frontend**: React (Vite), Tailwind CSS, Framer Motion (Animations), Axios, Recharts.
*   **Backend**: Python FastAPI, SQLite, Pydantic.
*   **AI & ML**: 
    *   **Hugging Face Transformers** (`cardiffnlp/twitter-roberta-base-emotion`) for accurate emotion detection.
    *   **OpenRouter / LLMs** for generating personalized activity plans and empathetic chat responsess.

---

## ✨ Key Features Implemented

### 1. Robust Authentication System
*   **Secure Auth**: Full Login and Registration flow with JWT (JSON Web Token) security.
*   **Password Reset**: Implemented a secure password reset flow (hashing & verification).
*   **Context Management**: Centralized `AuthContext` for managing user sessions across the app.

### 2. Advanced Emotion AI Engine (`backend/app/services/emotion_ai.py`)
A sophisticated hybrid classification system that goes beyond simple sentiment analysis:
*   **Hybrid Model**: Combines deep learning (RoBERTa) with a rule-based expert system.
*   **Safety First**: **Critical Distress Detection** instantly identifies self-harm or deep crisis signals (e.g., "done with life") and overrides the AI to ensure safety.
*   **Gen Z & Slang Support**: Accurately interprets modern slang (e.g., "cooked", "mid", "no cap", "touch grass") to map to correct energy levels.
*   **Anti-Hallucination Filters**: 
    *   **Garbage Detector**: Filters out random key-mashes (e.g., "uhiiikkj") as Neural/Low Energy.
    *   **Anti-Bias Logic**: Prevents the model from blindly guessing "Happy" for neutral text (e.g., "Screenshot taken...") by strictly verifying positive keywords vs. confidence scores.

### 3. Intelligent Dashboard
*   **Mood Analysis**: Real-time analysis of user text input.
*   **Smart Suggestions**: Generates a 3-step actionable plan (Breathing, Micro-task, Activity) based on the specific mood and available time.
*   **"Surprise Me"**: Instant random activity generator for quick boredom relief.
*   **Feedback Loop**: User feedback confirms emotion accuracy (showing "No emotion detected" popup for vague inputs).

### 4. Interactive Modules
*   **🧠 Arcade Zone**: Implemented **Tic-Tac-Toe** (Unbeatable Minimax AI), **Snake** (Classic), and **Rock-Paper-Scissors** to engage users.
*   **🎙️ Voice Assistant (Luno)**: A real-time, bi-directional conversational AI named **Luno**.
    *   **Features**: Web Speech API integration for STT/TTS, conversation context memory, and empathetic, concise responses.
    *   **Persona**: Adaptive and supportive, prioritizing natural flow.
*   **📝 Mood Journal**: Users can log entries which are analyzed for sentiment, stored in the database, and visualized on the History page.
*   **💬 AI Friend Chat**: A supportive, context-aware chatbot that adopts a persona (Empathetic Listener or Fun Companion) based on the user's mood.
*   **🎵 Music**: Framework for mood-based playlist generation.

### 5. Resilient Architecture
*   **API Standardization**: Unified API endpoints under `/api` for clean routing.
*   **LLM Reliability**: Implemented a **Retry & Fallback Mechanism** for external AI calls. If the LLM provider is down or rate-limited, the system seamlessly switches to "Offline Mode" responses instead of crashing.

---

## 🔧 Recent Major Refinements
1.  **Voice Assistant Overhaul**:
    *   Replaced mock voice with real STT/TTS loop.
    *   Implemented context-aware history to enable multi-turn conversations.
    *   Solved complex race conditions (double-replies) using React Refs.
2.  **Emotion Model "Fine-Tuning"**:
    *   Moved from a rigid dictionary map back to a flexible **High-Confidence Rule-Based System**.
    *   Added strict validation to prevent false positives (e.g., informational text being flagged as "Happy").
3.  **Frontend-Backend Integration**: 
    *   Standardized all API calls using `VITE_API_URL`.
    *   Fixed Cross-Origin (CORS) and routing issues.

## 🔜 Next Steps / Roadmap
*   **Deep Spotify Integration**: Connect to real Spotify User Accounts for direct playback control.
*   **Gamification**: Add streaks and badges for consistent journaling and mood management.
