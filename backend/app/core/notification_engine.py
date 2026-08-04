from typing import List, Dict, Any, Optional
from datetime import datetime

class RuleBasedNotificationEngine:
    def evaluate_rules(self, metrics: Dict[str, Any], burnout_risk: str = "Low") -> List[Dict[str, Any]]:
        notifications = []
        
        sleep = metrics.get("sleep_hours", 8.0)
        working_hours = metrics.get("working_hours", 8.0)
        mood = metrics.get("mood_score", 5)
        stress = metrics.get("stress_level", 5)
        water = metrics.get("water_intake", 8)
        exercise = metrics.get("exercise_minutes", 30)

        # Rule 1: High Stress & Low Sleep (Critical Break Alert)
        if stress >= 8 and sleep < 6.0:
            notifications.append({
                "title": "Nervous System Reset",
                "message": "High stress & low sleep detected. Stop coding, step away, and practice a 5-minute deep breathing exercise.",
                "type": "break",
                "priority": "critical"
            })
            
        # Rule 2: High Burnout Risk Alert
        elif burnout_risk == "High":
            notifications.append({
                "title": "Unplug & Recover",
                "message": "Your recent burnout metrics are elevated. Consider winding down early and taking a screen break.",
                "type": "burnout",
                "priority": "critical"
            })
            
        # Rule 3: Sleep Deficiency Alert
        if sleep < 6.0:
            notifications.append({
                "title": "Sleep Recovery Reminder",
                "message": "Your logged sleep was below 6 hours. Set a screen wind-down reminder 30 minutes before sleep tonight.",
                "type": "sleep",
                "priority": "high"
            })

        # Rule 4: Hydration Deficiency Alert
        # Translate ml to glasses if needed
        water_glasses = water
        if water > 30:
            water_glasses = int(water / 250)
            
        if water_glasses < 6:
            notifications.append({
                "title": "Hydration Reminder",
                "message": "Low water intake logged. Grab a glass of water now to stay focused and avoid screen fatigue.",
                "type": "water",
                "priority": "medium"
            })

        # Rule 5: Sedentary / Lack of Exercise Alert
        if exercise < 20:
            notifications.append({
                "title": "Active Movement Stretch",
                "message": "Log some steps! Take a 10-minute active stretch break to offset sedentary keyboard blocks.",
                "type": "exercise",
                "priority": "medium"
            })

        # Rule 6: Low Mood / Motivation Boost
        if mood <= 3:
            notifications.append({
                "title": "Mindful Check-in",
                "message": "You logged a low mood today. Remember: you are not your code. Take a breather or talk to our AI wellness coach.",
                "type": "mood",
                "priority": "high"
            })

        # Base case if no rules triggered: general daily wellness check-in
        if not notifications:
            notifications.append({
                "title": "Daily Wellness Check",
                "message": "Keep up the great work! Balance your coding sessions with short stretches and stay hydrated.",
                "type": "wellness",
                "priority": "low"
            })

        # Inject standard metadata
        timestamp = datetime.utcnow().isoformat() + "Z"
        for i, note in enumerate(notifications):
            note["notificationId"] = f"notif_rule_{int(datetime.utcnow().timestamp())}_{i}"
            note["scheduledTime"] = timestamp
            note["sentTime"] = timestamp
            note["status"] = "sent"
            note["isRead"] = False
            note["source"] = "backend_engine"
            note["createdAt"] = timestamp

        return notifications
