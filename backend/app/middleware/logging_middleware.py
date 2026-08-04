import time
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from loguru import logger

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        client_host = request.client.host if request.client else "unknown"
        
        logger.info(f"Incoming Request | Method: {request.method} | Path: {request.url.path} | Client IP: {client_host}")
        
        try:
            response = await call_next(request)
            duration_ms = (time.time() - start_time) * 1000
            
            # Log response timing
            logger.info(
                f"Outgoing Response | Method: {request.method} | Path: {request.url.path} "
                f"| Status: {response.status_code} | Process Time: {duration_ms:.2f}ms"
            )
            return response
        except Exception as e:
            duration_ms = (time.time() - start_time) * 1000
            logger.error(
                f"Failed Request | Method: {request.method} | Path: {request.url.path} "
                f"| Error: {str(e)} | Process Time: {duration_ms:.2f}ms"
            )
            raise e
