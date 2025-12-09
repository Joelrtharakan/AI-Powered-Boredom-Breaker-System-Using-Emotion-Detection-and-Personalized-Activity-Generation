# 🚀 Boredom Breaker - AI Powered Mood Companion

## Project Overview
Full-stack application detecting mood and suggesting activities.

## 🛠 Tech Stack
- **Frontend**: React (Vite), Tailwind CSS, Framer Motion
- **Backend**: FastAPI, SQLAlchemy, ChromaDB, Transformers (Emotion Model)

## 🚀 Setup Instructions

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\\Scripts\\activate
pip install -r requirements.txt
```

### 2. Environment Variables
Create `backend/.env`:
```env
SECRET_KEY=supersecret
SQLALCHEMY_DATABASE_URI=sqlite:///./boredom_breaker.db
# Optional
SPOTIFY_CLIENT_ID=
SPOTIFY_CLIENT_SECRET=
```

### 3. Run Backend
```bash
cd backend
# This will create tables on first run
uvicorn app.main:app --reload
```
*Note: The first run will download the HuggingFace model (~500MB).*

### 4. Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

## 🎮 Features
- **Mood Detection**: Enter text or use voice.
- **RAG Planner**: Generates personalized plans based on mood.
- **Mini Games**: React-based games.
- **Journaling**: Encrypted diary.
