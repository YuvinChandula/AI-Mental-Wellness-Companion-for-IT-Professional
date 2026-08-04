import '../../features/mood/data/datasources/mood_remote_datasource.dart';
import '../../features/mood/data/models/mood_log_model.dart';
import 'demo_user.dart';

class DemoMoodRemoteDataSource implements MoodRemoteDataSource {
  static final List<MoodLogModel> _entries = <MoodLogModel>[
    MoodLogModel(
      id: 'demo-mood-1',
      userId: DemoUser.uid,
      mood: 'Calm',
      moodScore: 4,
      stressLevel: 2,
      energyLevel: 4,
      sleepHours: 7.5,
      waterIntake: 1800,
      exerciseMinutes: 30,
      notes: 'Good focus day. Finished a sprint task.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MoodLogModel(
      id: 'demo-mood-2',
      userId: DemoUser.uid,
      mood: 'Neutral',
      moodScore: 3,
      stressLevel: 3,
      energyLevel: 3,
      sleepHours: 6.5,
      waterIntake: 1200,
      exerciseMinutes: 15,
      notes: 'Back-to-back meetings. Need a short break.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MoodLogModel(
      id: 'demo-mood-3',
      userId: DemoUser.uid,
      mood: 'Happy',
      moodScore: 5,
      stressLevel: 1,
      energyLevel: 5,
      sleepHours: 8.0,
      waterIntake: 2200,
      exerciseMinutes: 45,
      notes: 'Weekend recharge worked well.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<void> createEntry(MoodLogModel log) async {
    _entries.insert(0, log);
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((MoodLogModel entry) => entry.id == id);
  }

  @override
  Future<MoodLogModel?> getDailyEntry(String userId, DateTime date) async {
    for (final MoodLogModel entry in _entries) {
      if (entry.userId == userId &&
          entry.createdAt.year == date.year &&
          entry.createdAt.month == date.month &&
          entry.createdAt.day == date.day) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<MoodLogModel>> getHistory(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _entries.where((MoodLogModel entry) => entry.userId == userId).toList();
  }

  @override
  Future<void> updateEntry(MoodLogModel log) async {
    final int index = _entries.indexWhere((MoodLogModel entry) => entry.id == log.id);
    if (index >= 0) {
      _entries[index] = log;
    }
  }
}
