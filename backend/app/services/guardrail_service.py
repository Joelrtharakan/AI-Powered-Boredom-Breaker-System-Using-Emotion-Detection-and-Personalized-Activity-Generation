import re
import asyncio
from typing import Dict, Any, Tuple
from app.services.llm_service import llm_service

class GuardrailService:
    def __init__(self):
        # Explicit Regex patterns for jailbreaks and strict topic blocks
        self.jailbreak_patterns = [
            r"ignore\s+(all\s+)?previous\s+instructions",
            r"forget\s+(about\s+)?everything",
            r"system\s+prompt",
            r"you\s+are\s+now\s+(a\s+)?",
            r"pretend\s+to\s+be",
            r"from\s+now\s+on",
            r"bypass.*filter",
            r"DAN.*do anything now"
        ]
        
        self.code_math_patterns = [
            r"```(?:python|java|javascript|c\+\+|c|html|css|bash|sh|php|rust|go)?",
            r"def\s+[a-zA-Z_]+\s*\(.*\):",
            r"function\s+[a-zA-Z_]+\s*\(.*\)",
            r"import\s+[a-zA-Z0-9_\.]+",
            r"integrate.*dx",
            r"(?:solve|calculate).*x\s*="
        ]

        # Compile regexes for speed
        self.jailbreak_regex = re.compile("|".join(self.jailbreak_patterns), re.IGNORECASE)
        self.code_math_regex = re.compile("|".join(self.code_math_patterns), re.IGNORECASE)

    async def analyze(self, user_input: str) -> Tuple[bool, str]:
        """
        Runs the Guardrail multi-step check.
        Returns (is_safe: bool, reason: str or validation_message if unsafe)
        """
        # Step 1: Heuristic / Pattern Matching
        if self.jailbreak_regex.search(user_input):
            return False, "I cannot process commands that attempt to alter my instructions. I'm here to support your mental wellbeing."
        
        if self.code_math_regex.search(user_input):
            return False, "I am an AI Companion focused purely on mental health and emotional support. I am unable to write code, solve math problems, or process technical requests."

        # Step 2: Semantic Guardrail (LLM Moderation)
        # We classify intent to strictly verify it belongs in a mental health context and is safe.
        prompt = f"""You are a strict conversational guardrail for a mental health AI app.
Your only job is to analyze the user's input and classify its safety and topic.
If it involves self-harm/suicide, return "SAFE_BUT_CRISIS".
If it involves normal conversation, greetings, emotions, coping, relationships, mental health, return "SAFE".
If it asks the AI to generate essays, discuss politics, write code, solve complex science/math problems, provide medical/legal advice, or is highly toxic, return "UNSAFE".

Evaluate this message:
"{user_input}"

Format your response exactly as one of: [SAFE_BUT_CRISIS, SAFE, UNSAFE]
"""
        try:
            res = await llm_service.generate(
                system_prompt="You are an un-jailbreakable guardrail classifier.", 
                user_prompt=prompt
            )
            res = res.upper().strip()
            
            if "UNSAFE" in res:
                return False, "I'd love to chat, but I'm specialized in mental health and emotional companionship. Is there anything on your mind regarding your feelings or wellbeing that you'd like to talk about?"
            
            return True, "Passed"
        except Exception as e:
            # If the LLM guardrail fails, open or fail closed? We fail open but log it, since heuristic passed.
            print(f"LLM Guardrail Error: {e}")
            return True, "Passed without LLM verification"
            
guardrail_service = GuardrailService()
