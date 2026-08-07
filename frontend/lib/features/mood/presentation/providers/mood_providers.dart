import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/demo/demo_mood_remote_datasource.dart';
import '../../data/datasources/mood_local_datasource.dart';
import '../../data/datasources/mood_remote_datasource.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../reports/presentation/providers/analytics_providers.dart';

// Repository & Data Source Providers
final Provider<MoodLocalDataSource> moodLocalDataSourceProvider =
    Provider<MoodLocalDataSource>((Ref ref) {
  return MoodLocalDataSourceImpl();
});

final Provider<MoodRemoteDataSource> moodRemoteDataSourceProvider =
    Provider<MoodRemoteDataSource>((Ref ref) {
  if (AppConfig.demoMode) {
    return DemoMoodRemoteDataSource();
  }
  return MoodRemoteDataSourceImpl();
});

final Provider<MoodRepository> moodRepositoryProvider = Provider<MoodRepository>((Ref ref) {
  final MoodRemoteDataSource remote = ref.watch(moodRemoteDataSourceProvider);
  final MoodLocalDataSource local = ref.watch(moodLocalDataSourceProvider);
  return MoodRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

// Draft State Provider (Autosave locally)
class DraftNotifier extends StateNotifier<String> {
  final MoodLocalDataSource _localDataSource;
  final Ref _ref;

  DraftNotifier(this._localDataSource, this._ref) : super('') {
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final authState = _ref.read(authStateProvider);
    if (authState is AuthSuccess) {
      final draft = await _localDataSource.getDraft(authState.user.uid);
      state = draft;
    }
  }

  Future<void> updateDraft(String value) async {
    state = value;
    final authState = _ref.read(authStateProvider);
    if (authState is AuthSuccess) {
      await _localDataSource.saveDraft(authState.user.uid, value);
    }
  }

  Future<void> clearDraft() async {
    state = '';
    final authState = _ref.read(authStateProvider);
    if (authState is AuthSuccess) {
      await _localDataSource.clearDraft(authState.user.uid);
    }
  }
}

final StateNotifierProvider<DraftNotifier, String> draftProvider =
    StateNotifierProvider<DraftNotifier, String>((Ref ref) {
  final MoodLocalDataSource local = ref.watch(moodLocalDataSourceProvider);
  return DraftNotifier(local, ref);
});

// Mood History Provider
class MoodHistoryNotifier extends StateNotifier<AsyncValue<List<MoodLog>>> {
  final MoodRepository _repository;
  final Ref _ref;

  MoodHistoryNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadHistory();
    _ref.listen<AuthState>(authStateProvider, (AuthState? previous, AuthState next) {
      if (next is AuthSuccess || next is AuthInitial) {
        loadHistory();
      }
    });
  }

  Future<void> loadHistory() async {
    final authState = _ref.read(authStateProvider);
    final String userId = authState is AuthSuccess ? authState.user.uid : 'demo-user-001';

    try {
      try {
        await _repository.syncOfflineQueue(userId);
      } catch (_) {}
      final history = await _repository.getHistory(userId);
      if (mounted) {
        state = AsyncValue.data(history);
      }
    } catch (e) {
      if (mounted) {
        try {
          final cached = await _repository.getHistory(userId);
          state = AsyncValue.data(cached);
        } catch (_) {
          state = const AsyncValue.data(<MoodLog>[]);
        }
      }
    }
  }

  Future<void> addLog(MoodLog log) async {
    try {
      await _repository.createEntry(log);
      await loadHistory();
      _ref.read(activitySummaryProvider.notifier).loadActivities();
      _ref.read(dashboardDataProvider.notifier).loadDashboard(forceRefresh: true);
      _ref.invalidate(analyticsSummaryStateProvider);
      _ref.invalidate(trendDataStateProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateLog(MoodLog log) async {
    try {
      await _repository.updateEntry(log);
      await loadHistory();
      _ref.read(activitySummaryProvider.notifier).loadActivities();
      _ref.read(dashboardDataProvider.notifier).loadDashboard(forceRefresh: true);
      _ref.invalidate(analyticsSummaryStateProvider);
      _ref.invalidate(trendDataStateProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteLog(String id) async {
    final authState = _ref.read(authStateProvider);
    if (authState is! AuthSuccess) return;
    final userId = authState.user.uid;

    try {
      await _repository.deleteEntry(id, userId);
      await loadHistory();
      _ref.read(activitySummaryProvider.notifier).loadActivities();
      _ref.read(dashboardDataProvider.notifier).loadDashboard(forceRefresh: true);
      _ref.invalidate(analyticsSummaryStateProvider);
      _ref.invalidate(trendDataStateProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final StateNotifierProvider<MoodHistoryNotifier, AsyncValue<List<MoodLog>>> moodHistoryProvider =
    StateNotifierProvider<MoodHistoryNotifier, AsyncValue<List<MoodLog>>>((Ref ref) {
  final MoodRepository repository = ref.watch(moodRepositoryProvider);
  return MoodHistoryNotifier(repository, ref);
});

// Query and Filter State Providers
final StateProvider<String> searchQueryProvider = StateProvider<String>((Ref ref) => '');
final StateProvider<String?> moodFilterProvider = StateProvider<String?>((Ref ref) => null);

// Reactive Filtered History Provider
final Provider<AsyncValue<List<MoodLog>>> filteredMoodHistoryProvider =
    Provider<AsyncValue<List<MoodLog>>>((Ref ref) {
  final historyState = ref.watch(moodHistoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final moodFilter = ref.watch(moodFilterProvider);

  return historyState.whenData((List<MoodLog> logs) {
    return logs.where((MoodLog log) {
      final matchesQuery = query.isEmpty ||
          log.notes.toLowerCase().contains(query) ||
          log.mood.toLowerCase().contains(query);
      final matchesMood = moodFilter == null || log.mood == moodFilter;
      return matchesQuery && matchesMood;
    }).toList();
  });
});
