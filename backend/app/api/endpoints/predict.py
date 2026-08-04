from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from datetime import datetime, timezone
from ...core.security import get_current_user_id
from ...ml.pipeline import BurnoutPipeline

router = APIRouter()

class PredictionRequest(BaseModel):
    sleepHours: float = Field(..., ge=0.0, le=24.0, description="Daily sleep duration in hours.")
    workingHours: float = Field(..., ge=0.0, le=24.0, description="Working duration in hours.")
    moodScore: int = Field(..., ge=1, le=10, description="Mood rating from 1 to 10.")
    stressLevel: int = Field(..., ge=1, le=10, description="Stress rating from 1 to 10.")
    energyLevel: int = Field(5, ge=1, le=10, description="Energy rating from 1 to 10.")
    waterIntake: int = Field(1000, ge=0, description="Water intake. Supports glasses (0-30) or ml.")
    dailySteps: int = Field(..., ge=0, description="Pedometer daily step counts.")
    exerciseMinutes: int = Field(..., ge=0, le=1440, description="Physical activity duration in minutes.")
    consecutiveWorkingDays: int = Field(5, ge=0, le=365, description="Consecutive active working days.")

@router.post("/predict/burnout")
def predict_burnout(
    request: PredictionRequest,
    user_id: str = Depends(get_current_user_id)
):
    try:
        pipeline = BurnoutPipeline()
        
        # Translate ml to glasses for the model if values look like milliliters
        water_glasses = request.waterIntake
        if request.waterIntake > 30:
            water_glasses = int(request.waterIntake / 250) # Assuming 250ml per glass representation

        # Construct model features map in correct snake_case
        features = {
            'sleep_hours': request.sleepHours,
            'working_hours': request.workingHours,
            'mood_score': request.moodScore,
            'stress_level': request.stressLevel,
            'energy_level': request.energyLevel,
            'water_intake': water_glasses,
            'daily_steps': request.dailySteps,
            'exercise_minutes': request.exerciseMinutes,
            'consecutive_working_days': request.consecutiveWorkingDays
        }

        prediction_result = pipeline.predict(features)
        
        return {
            "success": True,
            "message": "Burnout prediction calculated successfully",
            "data": {
                **prediction_result,
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
        }
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Inference calculations failed: {str(e)}"
        )
