import time
from fastapi import Request, status
from starlette.middleware.base import BaseHTTPMiddleware
from ..utils.responses import standardized_response
from ..core.config import settings
from typing import Dict, List

class RateLimitingMiddleware(BaseHTTPMiddleware):
    # Dict mapping client IP to request timestamps
    _rate_limit_records: Dict[str, List[float]] = {}

    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        
        if request.url.path == "/api/health" or settings.ENV == "testing":
            return await call_next(request)

        now = time.time()
        
        if client_ip not in self._rate_limit_records:
            self._rate_limit_records[client_ip] = []
            
        # Clean older requests outside the 60 seconds boundary window
        self._rate_limit_records[client_ip] = [
            t for t in self._rate_limit_records[client_ip] if now - t < 60
        ]
        
        if len(self._rate_limit_records[client_ip]) >= settings.RATE_LIMIT_PER_MINUTE:
            return standardized_response(
                success=False,
                message="Rate limit exceeded. Please try again in a minute.",
                status_code=status.HTTP_429_TOO_MANY_REQUESTS
            )
            
        self._rate_limit_records[client_ip].append(now)
        return await call_next(request)
