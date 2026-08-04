import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int wellnessScore;
  final String wellnessExplanation;
  final String moodEmoji;
  final String moodTrend;
  final String lastMoodEntry;
  final String burnoutRiskLevel;
  final double burnoutPercentage;
  final String recommendationText;
  final String recommendationCategory;
  final String quoteText;
  final String quoteAuthor;
  final List<Map<String, dynamic>> recentMoods;
  final List<double> weeklyMoods;
  final List<double> weeklySleepHours;
  final List<double> weeklyWaterIntake;
  final List<double> weeklyExercise;

  const DashboardData({
    required this.wellnessScore,
    required this.wellnessExplanation,
    required this.moodEmoji,
    required this.moodTrend,
    required this.lastMoodEntry,
    required this.burnoutRiskLevel,
    required this.burnoutPercentage,
    required this.recommendationText,
    required this.recommendationCategory,
    required this.quoteText,
    required this.quoteAuthor,
    required this.recentMoods,
    required this.weeklyMoods,
    required this.weeklySleepHours,
    required this.weeklyWaterIntake,
    required this.weeklyExercise,
  });

  @override
  List<Object?> get props => <Object?>[
        wellnessScore,
        wellnessExplanation,
        moodEmoji,
        moodTrend,
        lastMoodEntry,
        burnoutRiskLevel,
        burnoutPercentage,
        recommendationText,
        recommendationCategory,
        quoteText,
        quoteAuthor,
        recentMoods,
        weeklyMoods,
        weeklySleepHours,
        weeklyWaterIntake,
        weeklyExercise,
      ];

  factory DashboardData.fromMap(Map<String, dynamic> map) {
    return DashboardData(
      wellnessScore: (map['wellnessScore'] as num? ?? 70).toInt(),
      wellnessExplanation: map['wellnessExplanation'] as String? ?? '',
      moodEmoji: map['moodEmoji'] as String? ?? '😊',
      moodTrend: map['moodTrend'] as String? ?? 'Stable',
      lastMoodEntry: map['lastMoodEntry'] as String? ?? 'Not set',
      burnoutRiskLevel: map['burnoutRiskLevel'] as String? ?? 'Low',
      burnoutPercentage: (map['burnoutPercentage'] as num? ?? 0.0).toDouble(),
      recommendationText: map['recommendationText'] as String? ?? '',
      recommendationCategory: map['recommendationCategory'] as String? ?? 'General',
      quoteText: map['quoteText'] as String? ?? 'Rest when you are weary. Refresh and renew yourself.',
      quoteAuthor: map['quoteAuthor'] as String? ?? 'A.P.J. Abdul Kalam',
      recentMoods: (map['recentMoods'] as List<dynamic>?)
              ?.map((dynamic e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const <Map<String, dynamic>>[],
      weeklyMoods: (map['weeklyMoods'] as List<dynamic>?)
              ?.map((dynamic e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      weeklySleepHours: (map['weeklySleepHours'] as List<dynamic>?)
              ?.map((dynamic e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      weeklyWaterIntake: (map['weeklyWaterIntake'] as List<dynamic>?)
              ?.map((dynamic e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      weeklyExercise: (map['weeklyExercise'] as List<dynamic>?)
              ?.map((dynamic e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'wellnessScore': wellnessScore,
      'wellnessExplanation': wellnessExplanation,
      'moodEmoji': moodEmoji,
      'moodTrend': moodTrend,
      'lastMoodEntry': lastMoodEntry,
      'burnoutRiskLevel': burnoutRiskLevel,
      'burnoutPercentage': burnoutPercentage,
      'recommendationText': recommendationText,
      'recommendationCategory': recommendationCategory,
      'quoteText': quoteText,
      'quoteAuthor': quoteAuthor,
      'recentMoods': recentMoods,
      'weeklyMoods': weeklyMoods,
      'weeklySleepHours': weeklySleepHours,
      'weeklyWaterIntake': weeklyWaterIntake,
      'weeklyExercise': weeklyExercise,
    };
  }
}
