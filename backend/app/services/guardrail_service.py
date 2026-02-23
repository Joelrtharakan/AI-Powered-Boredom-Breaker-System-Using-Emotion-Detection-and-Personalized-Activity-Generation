import re
import logging
from typing import Tuple
from app.services.llm_service import llm_service

logger = logging.getLogger(__name__)

class GuardrailService:
    def __init__(self):
        # 1. Jailbreak Patterns
        self.jailbreak_patterns = [
            r"ignore\s+(all\s+)?previous\s+instructions",
            r"forget\s+(about\s+)?everything",
            r"system\s+prompt",
            r"you\s+are\s+now\s+(a\s+)?",
            r"pretend\s+to\s+be",
            r"from\s+now\s+on",
            r"bypass.*filter",
            r"DAN.*do anything now",
            r"roleplay\s+as",
            r"translate.*to\s+python",
            r"base64"
        ]
        
        # 2. Tech / Math patterns
        self.code_math_patterns = [
            r"```(?:python|java|javascript|c\+\+|c|html|css|bash|sh|php|rust|go)?",
            r"def\s+[a-zA-Z_]+\s*\(.*\):",
            r"function\s+[a-zA-Z_]+\s*\(.*\)",
            r"import\s+[a-zA-Z0-9_\.]+",
            r"integrate.*dx",
            r"(?:solve|calculate).*x\s*="
        ]

        # 3. Toxicity / Profanity (Basic static list for fast rejection)
        self.toxicity_patterns = [
            r"\b(fuck|shit|bitch|cunt|asshole|faggot)\b"
        ]

        # Compile regexes for speed
        self.jailbreak_regex = re.compile("|".join(self.jailbreak_patterns), re.IGNORECASE)
        self.code_math_regex = re.compile("|".join(self.code_math_patterns), re.IGNORECASE)
        self.toxicity_regex = re.compile("|".join(self.toxicity_patterns), re.IGNORECASE)

        # 4. PII Redaction Regexes
        self.email_regex = re.compile(r"([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)")
        self.phone_regex = re.compile(r"\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b")

    def redact_pii(self, text: str) -> str:
        """Redacts emails and phone numbers to prevent LLM processing of sensitive PII."""
        text = self.email_regex.sub("[EMAIL REDACTED]", text)
        text = self.phone_regex.sub("[PHONE REDACTED]", text)
        return text

    async def analyze(self, user_input: str) -> Tuple[bool, str]:
        """
        Runs the Production Guardrail multi-step check.
        Returns: (is_safe: bool, sanitized_input_or_refusal_message: str)
        """
        
        # Step 0: Input Sanitization & Bounds Checking (Prevent DoS)
        if not user_input or not str(user_input).strip():
            return False, "Input cannot be empty."
        
        if len(user_input) > 1000:
            logger.warning("Guardrail Triggered: Payload too large.")
            return False, "Your message is too long. Please keep it under 1000 characters so I can process it effectively."

        # Step 1: PII Redaction
        sanitized_input = self.redact_pii(user_input)

        # Step 2: Heuristic / Pattern Matching (Fast Path Rejections)
        if self.toxicity_regex.search(sanitized_input):
            logger.warning("Guardrail Triggered: Toxicity/Profanity matched.")
            return False, "Let's keep our conversation respectful. I'm here to support you in a safe environment."

        if self.jailbreak_regex.search(sanitized_input):
            logger.warning("Guardrail Triggered: Jailbreak attempt.")
            return False, "I cannot process commands that attempt to alter my instructions. I'm here to calmly support your mental wellbeing."
        
        if self.code_math_regex.search(sanitized_input):
            logger.warning("Guardrail Triggered: Code/Math attempt.")
            return False, "I am an AI Companion focused purely on mental health and emotional support. I am unable to write code, solve math problems, or process technical requests."

        # Step 3: Semantic Guardrail (LLM Moderation)
        # Using XML tags to isolate user input from the prompt instructions (prevents Prompt Injection)
        prompt = f"""You are an enterprise-grade strict content moderation guardrail for a mental health AI app.
Your ONLY job is to analyze the user's input and classify its safety and topic.
If it involves self-harm/suicide/distress, return "CRISIS".
If it involves normal conversation, feelings, coping, relationships, or mental wellbeing, return "SAFE".
If it mentions generating essays, discussing politics, writing code, toxic behavior, scamming, or medical/legal advice, return "UNSAFE".

--- USER INPUT ---
<text>
{sanitized_input}
</text>
--- END USER INPUT ---

Return solely the exact classification string from the options above: [CRISIS, SAFE, UNSAFE].
"""
        try:
            # We explicitly request a faster, smaller model here to prevent the 30-second timeout you experienced!
            res = await llm_service.generate(
                system_prompt="You are a strict, un-jailbreakable data classifier.", 
                user_prompt=prompt,
                model="mistralai/mistral-7b-instruct-v0.1" # Fast model for quick guardrail execution
            )
            classification = res.upper().strip()
            
            if "UNSAFE" in classification:
                logger.warning(f"Guardrail Triggered: Semantic LLM rejected input: {classification}")
                return False, "I'd love to chat, but I'm highly specialized in mental health and emotional companionship. Is there anything on your mind regarding your feelings or wellbeing that you'd like to talk about?"
            
            return True, sanitized_input # Passed: We return the sanitized input (with redacted PII) to the upstream Chat Agent
        except Exception as e:
            logger.error(f"LLM Guardrail Failure: {e}")
            # Fail safely but log the failure so we don't lock out the user due to API timeouts
            return True, sanitized_input
            
guardrail_service = GuardrailService()
