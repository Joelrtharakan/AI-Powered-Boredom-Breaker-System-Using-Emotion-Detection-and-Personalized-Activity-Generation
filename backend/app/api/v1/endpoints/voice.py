from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import logging
from app.services.llm_service import llm_service

router = APIRouter()
logger = logging.getLogger(__name__)

class VoiceResponse(BaseModel):
    reply: str
    mood: str
    action: Optional[str] = None
    transcript: str

@router.post("/chat", response_model=VoiceResponse)
async def voice_chat(
    transcript: str = Form(...),
    user_id: Optional[str] = Form(None)
):
    try:
        logger.info(f"Voice chat request: {transcript}")
        
        # 1. Generate AI Response
        system_prompt = (
            "You are Luno, a compassionate, witty, and helpful AI companion. "
            "Your goal is to have a natural spoken conversation with the user. "
            "Keep your responses concise (1-2 sentences) as they will be spoken aloud. "
            "If the user seems bored or stressed, subtly suggest a quick activity, but prioritize empathy. "
            "Do not use markdown or emojis in your response."
        )
        
        reply = llm_service.generate(system_prompt, transcript)
        
        # Clean up response (remove special tokens and action descriptions)
        reply = reply.replace("<s>", "").replace("</s>", "").replace('"', "").strip()
        # Remove text between asterisks (actions like *smiles*)
        import re
        reply = re.sub(r'\*.*?\*', '', reply).strip()
        
        # 2. Simple Sentiment Analysis (Mock for now, or lightweight)
        # We can ask LLM to return JSON, but for speed, let's keep it simple text and infer mood
        mood = "neutral"
        lower_trans = transcript.lower()
        if any(w in lower_trans for w in ["sad", "tired", "bored", "lonely"]):
            mood = "low_energy"
        elif any(w in lower_trans for w in ["angry", "stressed", "hate"]):
            mood = "stressed"
        elif any(w in lower_trans for w in ["happy", "great", "good"]):
            mood = "happy"

        return {
            "reply": reply,
            "mood": mood,
            "action": None,
            "transcript": transcript
        }

    except Exception as e:
        logger.error(f"Voice chat error: {e}")
        raise HTTPException(status_code=500, detail="Failed to process voice")

