from fastapi import APIRouter
from datetime import datetime, timezone
from ...services.model_manager import ModelManager
from ...services.scheduler import BackgroundScheduler
from ...core.firebase import FirebaseService
from ...core.config import settings

router = APIRouter()

@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": settings.VERSION
    }

@router.get("/health/details")
def health_details():
    # 1. Get Model Manager state
    model_health = ModelManager().get_model_health()

    # 2. Verify Database Connection
    db_healthy = False
    try:
        if FirebaseService.db is not None:
            db_healthy = True
    except Exception:
        pass

    # 3. Verify Groq API connectivity config
    api_key = settings.GROQ_API_KEY
    ai_healthy = api_key is not None and not api_key.startswith("mock")

    # 4. Verify Background Scheduler status
    worker_healthy = BackgroundScheduler()._running

    return {
        "status": "healthy",
        "api": "healthy",
        "database": "healthy" if db_healthy else "degraded",
        "ai_service": "healthy" if ai_healthy else "mocked",
        "ml_model": model_health,
        "background_worker": "running" if worker_healthy else "stopped",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": settings.VERSION
    }
