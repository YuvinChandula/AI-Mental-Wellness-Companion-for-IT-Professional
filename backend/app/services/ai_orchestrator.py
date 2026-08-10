import os
import httpx
import asyncio
from typing import Dict, Any, Optional
from ..core.prompt_library import PromptLibrary
from .cache_service import CacheService
from loguru import logger

class AIOrchestrator:
    def __init__(self):
        self.api_key = os.getenv("GROQ_API_KEY", os.getenv("GEMINI_API_KEY", ""))

    async def generate_summary(self, user_id: str, metrics: Dict[str, Any], summary_type: str = "daily") -> str:
        # Check cache first
        cache_key = f"ai_summary_{user_id}_{summary_type}"
        cached = CacheService.get(cache_key)
        if cached:
            logger.info(f"Retrieved {summary_type} summary from Cache Service.")
            return cached

        # Prepare Prompt
        prompt = ""
        if summary_type == "daily":
            prompt = PromptLibrary.get_template("daily_summary").format(
                mood_score=metrics.get("mood_score", 5),
                stress_level=metrics.get("stress_level", 5),
                sleep_hours=metrics.get("sleep_hours", 7.0),
                water_intake=metrics.get("water_intake", 6),
                exercise_minutes=metrics.get("exercise_minutes", 30)
            )
        elif summary_type == "weekly":
            prompt = PromptLibrary.get_template("weekly_report").format(logs=str(metrics))
        else:
            prompt = f"Write a mental wellness check-in summary for these indicators: {str(metrics)}"

        # Fetch from Groq with retries
        summary = await self._execute_groq_request_with_retry(prompt)
        
        # Cache results (TTL = 1 hour for daily, 12 hours for weekly)
        ttl = 3600 if summary_type == "daily" else 43200
        CacheService.set(cache_key, summary, ttl=ttl)
        return summary

    async def _execute_gemini_request_with_retry(self, prompt: str, max_retries: int = 3) -> str:
        return await self._execute_groq_request_with_retry(prompt, max_retries)

    async def _execute_groq_request_with_retry(self, prompt: str, max_retries: int = 3) -> str:
        if not self.api_key or self.api_key.startswith("mock"):
            logger.warning("Mocking Groq AI content generation.")
            return "MindSync Developer Check-in: You are making steady progress. Keep focus high, and take short screen breaks."

        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": "llama-3.3-70b-versatile",
            "messages": [
                {
                    "role": "system",
                    "content": "You are MindSync AI, an expert mental wellness companion for software developers."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "temperature": 0.7,
            "max_tokens": 1024
        }

        async with httpx.AsyncClient() as client:
            for attempt in range(max_retries):
                try:
                    response = await client.post(url, json=payload, headers=headers, timeout=10.0)
                    if response.status_code == 200:
                        data = response.json()
                        text = data['choices'][0]['message']['content']
                        return text.strip()
                    else:
                        logger.warning(f"Groq API returned status {response.status_code}. Retrying...")
                except Exception as e:
                    logger.warning(f"Groq API request failed on attempt {attempt+1}: {e}")
                
                await asyncio.sleep(2 ** attempt)

        # Fallback response
        logger.error("Groq AI API requests failed after maximum retries. Returning fallback.")
        return "MindSync AI: We could not synchronize live suggestions. Focus on balancing your hydration levels and screen timing today."
