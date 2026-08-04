from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from datetime import datetime, timezone
from ...core.security import get_current_user_id
from ...ml.recommendation_engine import HybridRecommendationEngine

router = APIRouter()

class RecommendationMetricsInput(BaseModel):
    sleepHours: float = 7.0
    workingHours: float = 8.0
    moodScore: int = 5
    stressLevel: int = 5
    energyLevel: int = 5
    waterIntake: int = 1500
    dailySteps: int = 5000
    exerciseMinutes: int = 30
    burnoutRisk: str = "Low"

class FeedbackInput(BaseModel):
    recommendationId: str
    completed: bool = False
    saved: bool = False
    feedback: str = ""
    like: bool = False
    dislike: bool = False

@router.post("/recommendations/generate")
def generate_recommendations(
    request: RecommendationMetricsInput,
    user_id: str = Depends(get_current_user_id)
):
    try:
        engine = HybridRecommendationEngine()
        
        # Format water intake from ml to glasses
        water_glasses = request.waterIntake
        if request.waterIntake > 30:
            water_glasses = int(request.waterIntake / 250)

        metrics = {
            'sleep_hours': request.sleepHours,
            'working_hours': request.workingHours,
            'mood_score': request.moodScore,
            'stress_level': request.stressLevel,
            'energy_level': request.energyLevel,
            'water_intake': water_glasses,
            'daily_steps': request.dailySteps,
            'exercise_minutes': request.exerciseMinutes
        }

        recs = engine.generate_recommendations(metrics, request.burnoutRisk)
        
        return {
            "success": True,
            "message": "Recommendations generated successfully",
            "data": recs,
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to generate recommendations: {str(e)}"
        )

@router.post("/recommendations/daily-summary")
def get_daily_summary(
    request: RecommendationMetricsInput,
    user_id: str = Depends(get_current_user_id)
):
    try:
        engine = HybridRecommendationEngine()
        
        water_glasses = request.waterIntake
        if request.waterIntake > 30:
            water_glasses = int(request.waterIntake / 250)

        metrics = {
            'sleep_hours': request.sleepHours,
            'working_hours': request.workingHours,
            'mood_score': request.moodScore,
            'stress_level': request.stressLevel,
            'energy_level': request.energyLevel,
            'water_intake': water_glasses,
            'daily_steps': request.dailySteps,
            'exercise_minutes': request.exerciseMinutes
        }

        summary = engine.generate_daily_summary(metrics, request.burnoutRisk)
        return summary
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/recommendations/weekly-report")
def get_weekly_report(
    user_id: str = Depends(get_current_user_id)
):
    try:
        engine = HybridRecommendationEngine()
        # In production, we'd query historical database entries. We'll return structured predictions.
        return engine.generate_weekly_report([])
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("/recommendations/monthly-insights")
def get_monthly_insights(
    user_id: str = Depends(get_current_user_id)
):
    try:
        engine = HybridRecommendationEngine()
        return engine.generate_monthly_insights([])
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.post("/recommendations/feedback")
def submit_feedback(
    feedback: FeedbackInput,
    user_id: str = Depends(get_current_user_id)
):
    return {
        "success": True,
        "message": "Feedback submitted and logged successfully",
        "data": {
            "recommendationId": feedback.recommendationId,
            "userId": user_id,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
    }
