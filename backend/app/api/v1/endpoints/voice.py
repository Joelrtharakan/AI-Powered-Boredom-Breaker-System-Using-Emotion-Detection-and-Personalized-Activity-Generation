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
    user_id: Optional[str] = Form(None),
    history: Optional[str] = Form(None) # JSON string of list of dicts
):
    try:
        logger.info(f"Voice chat request: {transcript}")
        
        # 1. Build Context from History
        import json
        messages_context = []
        if history:
            try:
                messages_context = json.loads(history)
            except:
                pass
        
        # Limit history to last 6 turns to keep context usually relevant but not huge
        messages_context = messages_context[-6:]
        
        # Prevent duplication: If the last message in history is the same as the current transcript,
        # remove it from context because we append the transcript explicitly below.
        if messages_context and messages_context[-1].get("role") == "user" and messages_context[-1].get("content") == transcript:
            messages_context.pop()

        # Construct System Prompt
        system_prompt = (
            "You are Luno, a compassionate, witty, and helpful AI companion. "
            "Your goal is to have a natural spoken conversation with the user. "
            "Keep your responses concise (1-2 sentences) as they will be spoken aloud. "
            "Listen carefully to what the user says and ask relevant follow-up questions to deepen the conversation. "
            "Do not change the subject abruptly. Only suggest activities if the user explicitly says they are bored. "
            "Do not use markdown or emojis in your response. "
            "IMPORTANT: Do not output any internal tokens like ['OUT'] or <s>."
        )

        # Merge history into a prompt format that the simple LLM service can handle
        full_transcript = ""
        for msg in messages_context:
            role = "User" if msg.get("role") == "user" else "Luno"
            content = msg.get("content", "")
            full_transcript += f"{role}: {content}\n"
        
        full_transcript += f"User: {transcript}\nLuno:"
        
        # Call LLM
        reply = llm_service.generate(system_prompt, full_transcript)
        
        # Clean up response (remove special tokens and action descriptions)
        reply = reply.replace("<s>", "").replace("</s>", "").replace('"', "").replace("['OUT']", "").strip()
        # Remove text between asterisks (actions like *smiles*)
        import re
        reply = re.sub(r'\*.*?\*', '', reply)
        reply = re.sub(r'\[.*?\]', '', reply) # Remove bracketed text like [smiles]
        reply = reply.strip()
        
        # Fix possible prefixing (LLM might repeat "Luno: ")
        if reply.startswith("Luno:"):
            reply = reply[5:].strip()

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

