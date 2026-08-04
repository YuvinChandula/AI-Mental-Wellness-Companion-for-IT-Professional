from datetime import datetime
import uuid
from typing import Any, Optional
from fastapi.responses import JSONResponse

def standardized_response(
    success: bool,
    message: str,
    data: Any = None,
    status_code: int = 200
) -> JSONResponse:
    content = {
        "success": success,
        "message": message,
        "data": data,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "requestId": str(uuid.uuid4())
    }
    return JSONResponse(status_code=status_code, content=content)
