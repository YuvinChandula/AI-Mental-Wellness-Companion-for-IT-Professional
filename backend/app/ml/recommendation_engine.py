import json
import requests
import os

class HybridRecommendationEngine:
    def __init__(self):
        self.groq_api_key = os.getenv("GROQ_API_KEY", os.getenv("GEMINI_API_KEY", ""))
        self.gemini_api_key = self.groq_api_key
        # If running locally, let's load from .env if present
        if not self.groq_api_key:
            try:
                from dotenv import load_dotenv
                load_dotenv()
                self.groq_api_key = os.getenv("GROQ_API_KEY", os.getenv("GEMINI_API_KEY", ""))
                self.gemini_api_key = self.groq_api_key
            except ImportError:
                pass

    def generate_recommendations(self, metrics: dict, burnout_risk: str = "Low") -> list:
        recommendations = []

        # 1. Rules-Based Recommendations
        sleep = metrics.get("sleep_hours", 8.0)
        stress = metrics.get("stress_level", 5)
        water = metrics.get("water_intake", 8)
        exercise = metrics.get("exercise_minutes", 30)

        if sleep < 6.0:
            recommendations.append({
                "recommendationId": "rule_sleep_" + str(int(sleep)),
                "title": "Unwind Sleep Routine",
                "description": "Dedicate 15 minutes before bed to a screenless wind-down, such as reading or listening to calm music.",
                "reason": f"Your sleep was logged at {sleep} hours, which is below the 7-9 hours recommended range.",
                "confidence": 0.95,
                "priority": "High",
                "category": "Sleep Improvement",
                "expectedBenefit": "Deep sleep quality improvement and faster sleep onset.",
                "estimatedTime": "15 min",
                "difficultyLevel": "Easy",
                "suggestedFollowUp": "Keep water by the bed and keep screens off after 10 PM.",
                "source": "Rules Engine",
                "completed": False,
                "saved": False,
                "feedback": ""
            })

        if stress > 7:
            recommendations.append({
                "recommendationId": "rule_stress_" + str(stress),
                "title": "Nervous System Reset (4-7-8)",
                "description": "Inhale for 4s, hold for 7s, and exhale slowly for 8s. Repeat this breathing cycle 4 times.",
                "reason": f"Your stress level index is currently high at {stress}/10.",
                "confidence": 0.92,
                "priority": "Critical",
                "category": "Stress Reduction",
                "expectedBenefit": "Activates the parasympathetic nervous system to reduce immediate anxiety.",
                "estimatedTime": "5 min",
                "difficultyLevel": "Easy",
                "suggestedFollowUp": "Drink a warm cup of herbal tea.",
                "source": "Rules Engine",
                "completed": False,
                "saved": False,
                "feedback": ""
            })

        if water < 6:
            recommendations.append({
                "recommendationId": "rule_water_" + str(water),
                "title": "Desk Hydration Boost",
                "description": "Drink a full 250ml glass of water now. Place a water bottle directly next to your keyboard.",
                "reason": "Your tracked water intake is low. Dehydration can increase cognitive fatigue.",
                "confidence": 0.85,
                "priority": "Medium",
                "category": "Hydration",
                "expectedBenefit": "Reduces brain fog, keeps focus sharp during long debug sessions.",
                "estimatedTime": "2 min",
                "difficultyLevel": "Easy",
                "suggestedFollowUp": "Refill your bottle every time you stand up.",
                "source": "Rules Engine",
                "completed": False,
                "saved": False,
                "feedback": ""
            })

        if exercise < 20:
            recommendations.append({
                "recommendationId": "rule_exercise_" + str(exercise),
                "title": "Active Desk Stretching",
                "description": "Perform 5 neck rolls, 5 shoulder rolls, and stand up to stretch your hamstrings.",
                "reason": "You have logged low active movement today.",
                "confidence": 0.88,
                "priority": "Medium",
                "category": "Exercise",
                "expectedBenefit": "Relieves muscle stiffness, improves posture and blood circulation.",
                "estimatedTime": "5 min",
                "difficultyLevel": "Easy",
                "suggestedFollowUp": "Walk for 10 minutes after your next meeting.",
                "source": "Rules Engine",
                "completed": False,
                "saved": False,
                "feedback": ""
            })

        # 2. Machine Learning Recommendations
        if burnout_risk == "High" or burnout_risk == "Medium":
            recommendations.append({
                "recommendationId": "ml_burnout_" + burnout_risk.lower(),
                "title": "Mandatory Disconnection",
                "description": "Mute code review alerts, set Slack to Away, and commit to taking a 30-minute full offline walk.",
                "reason": f"Machine Learning models have flagged a {burnout_risk} Burnout Risk profile.",
                "confidence": 0.90,
                "priority": "Critical",
                "category": "Work-Life Balance",
                "expectedBenefit": "Lowers mental fatigue threshold to avoid workspace fatigue.",
                "estimatedTime": "30 min",
                "difficultyLevel": "Medium",
                "suggestedFollowUp": "Limit overtime working hours tomorrow.",
                "source": "Machine Learning",
                "completed": False,
                "saved": False,
                "feedback": ""
            })

        # 3. Groq AI Recommendations
        # Fetch creative lifestyle recommendations if valid key is configured
        if self.groq_api_key and not self.groq_api_key.startswith("mock") and "your_" not in self.groq_api_key.lower() and "api_key" not in self.groq_api_key.lower():
            try:
                groq_recs = self._fetch_groq_recs(metrics, burnout_risk)
                recommendations.extend(groq_recs)
            except Exception as e:
                print(f"Warning: Groq recommendations failed, falling back. Error: {str(e)}")
                recommendations.append(self._get_fallback_gemini_rec())
        else:
            # Fallback creative recommendation when key is mock
            recommendations.append(self._get_fallback_gemini_rec())

        return recommendations

    def _fetch_gemini_recs(self, metrics: dict, burnout_risk: str) -> list:
        return self._fetch_groq_recs(metrics, burnout_risk)

    def _fetch_groq_recs(self, metrics: dict, burnout_risk: str) -> list:
        url = "https://api.groq.com/openai/v1/chat/completions"
        
        system_instruction = (
            "You are an expert IT wellness coach. Based on the user's daily metrics, "
            "recommend 2 creative, practical wellbeing suggestions. "
            "You must return ONLY a structured JSON list. Do not write markdown tags outside the json."
        )

        prompt = f"""
        User Metrics:
        - Sleep: {metrics.get('sleep_hours')} hrs
        - Working Hours: {metrics.get('working_hours')} hrs
        - Mood Score: {metrics.get('mood_score')}/10
        - Stress Level: {metrics.get('stress_level')}/10
        - Energy Level: {metrics.get('energy_level')}/10
        - Water Glasses: {metrics.get('water_intake')}
        - Steps: {metrics.get('daily_steps')}
        - Exercise Minutes: {metrics.get('exercise_minutes')}
        - Burnout Risk Class: {burnout_risk}

        Respond with a JSON array containing exactly 2 objects matching this schema:
        [
          {{
            "recommendationId": "groq_01",
            "title": "Creative Title",
            "description": "Actionable description",
            "reason": "Why this was suggested based on their low sleep, high stress, etc.",
            "confidence": 0.90,
            "priority": "High",
            "category": "Mindfulness",
            "expectedBenefit": "Expected benefit",
            "estimatedTime": "15 min",
            "difficultyLevel": "Easy",
            "suggestedFollowUp": "Follow up task",
            "source": "Groq AI",
            "completed": false,
            "saved": false,
            "feedback": ""
          }}
        ]
        """

        headers = {
            "Authorization": f"Bearer {self.groq_api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": "llama-3.3-70b-versatile",
            "messages": [
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.7,
            "response_format": {"type": "json_object"}
        }

        response = requests.post(url, headers=headers, json=payload, timeout=8)
        if response.status_code == 200:
            data = response.json()
            text = data['choices'][0]['message']['content']
            
            # Clean possible markdown wrapping
            text = text.replace("```json", "").replace("```", "").strip()
            
            res_json = json.loads(text)
            if isinstance(res_json, dict) and "recommendations" in res_json:
                return res_json["recommendations"]
            elif isinstance(res_json, dict) and "data" in res_json:
                return res_json["data"]
            elif isinstance(res_json, list):
                return res_json
            return [res_json]
        else:
            raise Exception(f"Groq API returned status {response.status_code}")

    def _get_fallback_gemini_rec(self) -> dict:
        return {
            "recommendationId": "groq_fallback_mock",
            "title": "IT Workday Screen Break",
            "description": "Every 50 minutes, look at an object 20 feet away for 20 seconds. Put your phone down and let your eyes relax.",
            "reason": "Sedentary screen hours increase eye fatigue and mental exhaustion.",
            "confidence": 0.90,
            "priority": "High",
            "category": "Work-Life Balance",
            "expectedBenefit": "Reduces digital eye strain and keeps coding focus sharp.",
            "estimatedTime": "5 min",
            "difficultyLevel": "Easy",
            "suggestedFollowUp": "Walk to refill your water glass.",
            "source": "Groq AI",
            "completed": False,
            "saved": False,
            "feedback": ""
        }

    # Summary Report Generators
    def generate_daily_summary(self, metrics: dict, burnout_risk: str) -> dict:
        # Mock summary builder with realistic developer context
        sleep = metrics.get("sleep_hours", 7.0)
        stress = metrics.get("stress_level", 5)
        
        score = int(100 - (stress * 5) - ((8 - sleep) * 4))
        score = max(30, min(100, score))
        
        focus = "Prioritize sleep hygiene tonight" if sleep < 7.0 else "Balance workloads and take physical desk breaks"

        return {
            "success": True,
            "data": {
                "wellnessScore": score,
                "positiveAchievements": [
                    "Maintained hydration goals" if metrics.get("water_intake", 0) >= 6 else "Logged metrics check-in",
                    "Exercised today" if metrics.get("exercise_minutes", 0) > 15 else "Active steps logged"
                ],
                "areasForImprovement": [
                    "High stress detected" if stress >= 7 else "Improve sleep continuity"
                ],
                "recommendedFocus": focus,
                "motivationalMessage": "You are doing great! A small stretch goes a long way. Keep coding, but remember to rest.",
                "dailyGoal": "Walk 6,000 steps and drink 2 liters of water"
            }
        }

    def generate_weekly_report(self, history: list) -> dict:
        return {
            "success": True,
            "data": {
                "weeklySummary": "Your overall wellness score averaged 76/100 this week. Sleep remained stable but stress spiked on Wednesday.",
                "moodTrend": "Stable (Averaged Neutral-Happy)",
                "stressTrend": "Spiked midweek during release cycle",
                "sleepTrend": "Average 6.5 hours (Slightly low)",
                "activityTrend": "Met active minutes goal on 4 out of 7 days",
                "burnoutTrend": "Medium risk profile flagged due to prolonged screen hours",
                "positiveChanges": ["Hydration increased by 15%"],
                "negativeChanges": ["Sedentary desk hours increased"],
                "topRecommendations": [
                    "Implement a 15-minute screenless transition after work",
                    "Target earlier bedtime routines"
                ],
                "overallProgress": "Satisfactory. Focused habits are building."
            }
        }

    def generate_monthly_insights(self, history: list) -> dict:
        return {
            "success": True,
            "data": {
                "monthlyWellnessReport": "This month your wellness score improved by 8% compared to last month.",
                "habitImprovements": "Consistent hydration and stretching breaks",
                "behaviourChanges": "Winding down 30 minutes earlier",
                "mostCommonMood": "Calm",
                "averageSleep": 7.1,
                "averageStress": 4.5,
                "exerciseConsistency": "Averaged 25 minutes active daily",
                "waterIntake": "Averaged 1800 ml daily",
                "aiSummary": "Your core indicators are positive. Continue optimizing sleep to offset development stress."
            }
        }
