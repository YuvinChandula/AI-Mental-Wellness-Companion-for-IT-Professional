import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import settings
from .core.logging import setup_logging
from .core.exceptions import setup_exception_handlers
from .core.firebase import FirebaseService
from .middleware.logging_middleware import RequestLoggingMiddleware
from .middleware.rate_limit_middleware import RateLimitingMiddleware
from .middleware.security_headers_middleware import SecurityHeadersMiddleware
from .api.endpoints import health, predict, recommendations, analytics, notifications
from .ml.pipeline import BurnoutPipeline
from .services.scheduler import BackgroundScheduler
from .services.model_manager import ModelManager

# 1. Setup Loguru structured logging
setup_logging()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="MindSync AI - Production Backend Microservices Serving Telemetry Analytics and Burnout Forecasting."
)

# 2. Register Global Exception Mapping
setup_exception_handlers(app)

# 3. Add Security and Audit Middlewares
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(RateLimitingMiddleware)
app.add_middleware(SecurityHeadersMiddleware)

# 4. Startup lifecycle hooks
@app.on_event("startup")
def startup_event():
    # Initialize Firebase Admin SDK
    FirebaseService.initialize()
    
    # Initialize Model Manager
    ModelManager().initialize()
    
    # Start Background Scheduler
    BackgroundScheduler().start()
    
    # Pre-load ML pipeline models
    try:
        pipeline = BurnoutPipeline()
        pipeline.initialize()
    except Exception as e:
        print(f"Warning: Failed to load ML model at startup: {str(e)}")

# 5. Include API Routers
app.include_router(health.router)
app.include_router(predict.router, prefix=settings.API_STR)
app.include_router(recommendations.router, prefix=settings.API_STR)
app.include_router(analytics.router, prefix=settings.API_STR)
app.include_router(notifications.router, prefix=settings.API_STR)

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
