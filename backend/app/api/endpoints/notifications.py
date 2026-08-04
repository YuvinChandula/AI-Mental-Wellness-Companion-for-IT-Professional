from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from ...core.security import get_current_user_id
from ...core.notification_engine import RuleBasedNotificationEngine

router = APIRouter()

# In-memory mock database store keyed by user_id
NOTIFICATIONS_DB: Dict[str, List[Dict[str, Any]]] = {}
PREFERENCES_DB: Dict[str, Dict[str, Any]] = {}
HISTORY_DB: Dict[str, List[Dict[str, Any]]] = {}

# --- SCHEMAS ---

class NotificationItem(BaseModel):
    notificationId: str
    title: str
    message: str
    type: str
    priority: str
    scheduledTime: str
    sentTime: str
    status: str
    isRead: bool
    source: str
    createdAt: str

class PreferencesInput(BaseModel):
    pushEnabled: bool = True
    emailEnabled: bool = False
    dailyReminders: bool = True
    weeklySummaries: bool = True
    aiSuggestions: bool = True
    motivationMessages: bool = True
    goalReminders: bool = True
    soundEnabled: bool = True
    vibrationEnabled: bool = True
    wakeUpTime: str = "08:00"
    sleepTime: str = "22:00"
    waterFrequencyHours: int = 2
    quietHoursStart: str = "22:00"
    quietHoursEnd: str = "07:00"
    timezone: str = "UTC"

class EvaluationInput(BaseModel):
    sleepHours: float
    workingHours: float
    moodScore: int
    stressLevel: int
    energyLevel: int
    waterIntake: int
    dailySteps: int
    exerciseMinutes: int
    burnoutRisk: str = "Low"

# --- HELPER SEEDS ---

def seed_default_notifications(user_id: str):
    timestamp = datetime.utcnow().isoformat() + "Z"
    NOTIFICATIONS_DB[user_id] = [
        {
            "notificationId": "seed_01",
            "userId": user_id,
            "title": "Welcome to MindSync Alerts",
            "message": "Start your wellness journey today. Log your mood, track exercise, and check AI recommendations.",
            "type": "wellness",
            "priority": "low",
            "scheduledTime": timestamp,
            "sentTime": timestamp,
            "status": "sent",
            "isRead": False,
            "source": "backend_engine",
            "createdAt": timestamp
        },
        {
            "notificationId": "seed_02",
            "userId": user_id,
            "title": "Hydration Reminder",
            "message": "It has been 2 hours since your last drink. Grab a glass of water to keep coding focus sharp.",
            "type": "water",
            "priority": "medium",
            "scheduledTime": timestamp,
            "sentTime": timestamp,
            "status": "sent",
            "isRead": False,
            "source": "backend_engine",
            "createdAt": timestamp
        }
    ]

# --- ENDPOINTS ---

@router.get("/notifications")
def get_notifications(
    user_id: str = Depends(get_current_user_id)
):
    if user_id not in NOTIFICATIONS_DB:
        seed_default_notifications(user_id)
        
    return {
        "success": True,
        "data": NOTIFICATIONS_DB[user_id]
    }

@router.post("/notifications/{notificationId}/read")
def mark_as_read(
    notificationId: str,
    user_id: str = Depends(get_current_user_id)
):
    if user_id not in NOTIFICATIONS_DB:
        raise HTTPException(status_code=404, detail="No notifications found for this user.")
        
    updated = False
    for notif in NOTIFICATIONS_DB[user_id]:
        if notif["notificationId"] == notificationId:
            notif["isRead"] = True
            notif["sentTime"] = datetime.utcnow().isoformat() + "Z"
            updated = True
            break
            
    if not updated:
        raise HTTPException(status_code=404, detail="Notification not found.")
        
    return {
        "success": True,
        "message": "Notification marked as read successfully"
    }

@router.delete("/notifications/{notificationId}")
def delete_notification(
    notificationId: str,
    user_id: str = Depends(get_current_user_id)
):
    if user_id not in NOTIFICATIONS_DB:
        raise HTTPException(status_code=404, detail="No notifications found for this user.")
        
    initial_len = len(NOTIFICATIONS_DB[user_id])
    NOTIFICATIONS_DB[user_id] = [n for n in NOTIFICATIONS_DB[user_id] if n["notificationId"] != notificationId]
    
    if len(NOTIFICATIONS_DB[user_id]) == initial_len:
        raise HTTPException(status_code=404, detail="Notification not found.")
        
    return {
        "success": True,
        "message": "Notification deleted successfully"
    }

@router.post("/notifications/preferences")
def update_preferences(
    preferences: PreferencesInput,
    user_id: str = Depends(get_current_user_id)
):
    PREFERENCES_DB[user_id] = preferences.dict()
    return {
        "success": True,
        "message": "Notification preferences updated successfully",
        "data": PREFERENCES_DB[user_id]
    }

@router.get("/notifications/preferences")
def get_preferences(
    user_id: str = Depends(get_current_user_id)
):
    if user_id not in PREFERENCES_DB:
        PREFERENCES_DB[user_id] = PreferencesInput().dict()
        
    return {
        "success": True,
        "data": PREFERENCES_DB[user_id]
    }

@router.post("/notifications/sync")
def sync_notification_history(
    history: List[NotificationItem],
    user_id: str = Depends(get_current_user_id)
):
    if user_id not in HISTORY_DB:
        HISTORY_DB[user_id] = []
        
    for item in history:
        HISTORY_DB[user_id].append(item.dict())
        
    return {
        "success": True,
        "message": f"Successfully synchronized {len(history)} notification records"
    }

@router.post("/notifications/trigger-evaluation")
def trigger_evaluation(
    metrics: EvaluationInput,
    user_id: str = Depends(get_current_user_id)
):
    engine = RuleBasedNotificationEngine()
    metrics_map = {
        "sleep_hours": metrics.sleepHours,
        "working_hours": metrics.workingHours,
        "mood_score": metrics.moodScore,
        "stress_level": metrics.stressLevel,
        "energy_level": metrics.energyLevel,
        "water_intake": metrics.waterIntake,
        "exercise_minutes": metrics.exerciseMinutes,
    }
    
    new_alerts = engine.evaluate_rules(metrics_map, metrics.burnoutRisk)
    
    if user_id not in NOTIFICATIONS_DB:
        NOTIFICATIONS_DB[user_id] = []
        
    for alert in new_alerts:
        alert["userId"] = user_id
        NOTIFICATIONS_DB[user_id].insert(0, alert) # Prepend fresh alerts
        
    return {
        "success": True,
        "message": f"Evaluation compiled. Generated {len(new_alerts)} fresh notifications.",
        "data": new_alerts
    }
