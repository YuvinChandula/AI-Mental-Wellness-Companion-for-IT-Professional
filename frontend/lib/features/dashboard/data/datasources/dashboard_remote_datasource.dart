import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/demo/demo_user.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/dashboard_data.dart';
import '../models/weather_model.dart';

abstract class DashboardRemoteDataSource {
  Future<WeatherModel> getWeather(double lat, double lon);
  Future<DashboardData> getDashboardData(String userId);
  Future<ActivitySummary> getActivitySummary(String userId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<WeatherModel> getWeather(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty ||
        apiKey == 'mock_weather_key_for_testing' ||
        apiKey.startsWith('mock') ||
        apiKey.contains('your_openweather_api_key')) {
      // Delay slightly to simulate network request latency
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return const WeatherModel(
        temperature: 28.5,
        condition: 'Clouds',
        humidity: 78,
        locationName: 'Colombo',
        description: 'scattered clouds',
        iconCode: '03d',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: <String, dynamic>{
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric',
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return WeatherModel.fromJson(response.data!);
      } else {
        return const WeatherModel(
          temperature: 28.5,
          condition: 'Clouds',
          humidity: 78,
          locationName: 'Colombo',
          description: 'scattered clouds',
          iconCode: '03d',
        );
      }
    } catch (_) {
      return const WeatherModel(
        temperature: 28.5,
        condition: 'Clouds',
        humidity: 78,
        locationName: 'Colombo',
        description: 'scattered clouds',
        iconCode: '03d',
      );
    }
  }

  @override
  Future<DashboardData> getDashboardData(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    
    final bool isDemoUser = userId == DemoUser.uid || userId == 'demo-user-001' || userId == 'demo_user';
    if (!isDemoUser) {
      return const DashboardData(
        wellnessScore: 0,
        wellnessExplanation: 'Welcome! Log your daily mood and activity metrics to track your wellness score.',
        moodEmoji: '🙂',
        moodTrend: 'New User',
        lastMoodEntry: 'No entries yet',
        burnoutRiskLevel: 'Low',
        burnoutPercentage: 0.0,
        recommendationText: 'Log your first daily check-in to generate personalized AI recommendations.',
        recommendationCategory: 'Getting Started',
        quoteText: 'The secret of getting ahead is getting started.',
        quoteAuthor: 'Mark Twain',
        recentMoods: <Map<String, dynamic>>[],
        weeklyMoods: <double>[0, 0, 0, 0, 0, 0, 0],
        weeklySleepHours: <double>[0, 0, 0, 0, 0, 0, 0],
        weeklyWaterIntake: <double>[0, 0, 0, 0, 0, 0, 0],
        weeklyExercise: <double>[0, 0, 0, 0, 0, 0, 0],
      );
    }

    return const DashboardData(
      wellnessScore: 82,
      wellnessExplanation: 'Your sleep and activity levels are excellent today, but you logged a slightly lower mood this morning. Consider taking a quick walk.',
      moodEmoji: '😐',
      moodTrend: 'Stable',
      lastMoodEntry: '3 hours ago',
      burnoutRiskLevel: 'Moderate',
      burnoutPercentage: 42.0,
      recommendationText: 'Schedule a 10-minute focus break and drink a glass of water.',
      recommendationCategory: 'Mindfulness',
      quoteText: 'It is not stress that kills us, it is our reaction to it.',
      quoteAuthor: 'Hans Selye',
      recentMoods: <Map<String, dynamic>>[
        {'emoji': '😊', 'time': 'Yesterday, 6:00 PM', 'label': 'Calm'},
        {'emoji': '😐', 'time': 'Today, 8:15 AM', 'label': 'Neutral'},
        {'emoji': '😴', 'time': 'Today, 11:30 PM', 'label': 'Tired'},
      ],
      weeklyMoods: <double>[4.0, 3.8, 4.2, 3.5, 4.0, 3.0, 3.5], // Mon to Sun
      weeklySleepHours: <double>[7.5, 8.0, 6.5, 7.0, 8.2, 5.8, 6.9],
      weeklyWaterIntake: <double>[2.1, 1.8, 2.5, 2.0, 2.2, 1.5, 1.9],
      weeklyExercise: <double>[30, 25, 45, 0, 15, 60, 20],
    );
  }

  @override
  Future<ActivitySummary> getActivitySummary(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final bool isDemoUser = userId == DemoUser.uid || userId == 'demo-user-001' || userId == 'demo_user';
    if (!isDemoUser) {
      return const ActivitySummary(
        steps: 0,
        stepsGoal: 10000,
        waterIntakeMl: 0,
        waterIntakeGoal: 2500,
        sleepHours: 0.0,
        sleepHoursGoal: 8.0,
        exerciseMinutes: 0,
        exerciseMinutesGoal: 45,
      );
    }

    return const ActivitySummary(
      steps: 6420,
      stepsGoal: 10000,
      waterIntakeMl: 1200,
      waterIntakeGoal: 2500,
      sleepHours: 6.8,
      sleepHoursGoal: 8.0,
      exerciseMinutes: 25,
      exerciseMinutesGoal: 45,
    );
  }
}
