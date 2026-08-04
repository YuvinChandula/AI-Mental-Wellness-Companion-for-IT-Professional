import re
from fastapi import HTTPException, status
from loguru import logger

class AISecurityManager:
    # Common jailbreak and prompt injection patterns
    _injection_patterns = [
        r"(?i)ignore (all )?prior",
        r"(?i)system override",
        r"(?i)jailbreak",
        r"(?i)forget previous instructions",
        r"(?i)bypass restrictions",
        r"(?i)act as a system administrator",
        r"(?i)you are now unrestricted"
    ]

    @classmethod
    def sanitize_prompt(cls, text: str) -> str:
        # Remove basic HTML tags
        cleaned = re.sub(r"<[^>]*>", "", text)
        
        # Check against blacklist patterns
        for pattern in cls._injection_patterns:
            if re.search(pattern, cleaned):
                logger.warning(f"Security Alert: Blocked prompt injection pattern matching '{pattern}'")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Request blocked: Input contains blacklisted system override keywords."
                )
        return cleaned.strip()

    @classmethod
    def append_medical_disclaimer(cls, ai_response: str) -> str:
        disclaimer = (
            "\n\n*Disclaimer: MindSync is a wellness companion and does not replace medical advice. "
            "If you are experiencing distress, please contact a healthcare provider.*"
        )
        if "Disclaimer: MindSync" in ai_response:
            return ai_response
        return ai_response + disclaimer
