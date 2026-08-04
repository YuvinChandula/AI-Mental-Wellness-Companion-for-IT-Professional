import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/weather_info.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

// Repositories & Data Sources Providers
final Provider<DashboardLocalDataSource> dashboardLocalDataSourceProvider =
    Provider<DashboardLocalDataSource>((Ref ref) {
  return DashboardLocalDataSourceImpl();
});

final Provider<DashboardRemoteDataSource> dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((Ref ref) {
  return DashboardRemoteDataSourceImpl();
});

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((Ref ref) {
  final DashboardRemoteDataSource remote = ref.watch(dashboardRemoteDataSourceProvider);
  final DashboardLocalDataSource local = ref.watch(dashboardLocalDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

// Dashboard Data State Provider
class DashboardNotifier extends StateNotifier<AsyncValue<DashboardData>> {
  final DashboardRepository _repository;
  final Ref _ref;

  DashboardNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadDashboard();
  }

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    final authState = _ref.read(authStateProvider);
    String userId = 'anonymous';
    if (authState is AuthSuccess) {
      userId = authState.user.uid;
    }

    if (forceRefresh) {
      state = const AsyncValue.loading();
    }

    try {
      final data = await _repository.getDashboardData(userId, forceRefresh: forceRefresh);
      if (mounted) {
        state = AsyncValue.data(data);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

final StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardData>> dashboardDataProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardData>>((Ref ref) {
  final DashboardRepository repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository, ref);
});

// Activity Summary State Provider
class ActivityNotifier extends StateNotifier<AsyncValue<ActivitySummary>> {
  final DashboardRepository _repository;
  final Ref _ref;

  ActivityNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    final authState = _ref.read(authStateProvider);
    String userId = 'anonymous';
    if (authState is AuthSuccess) {
      userId = authState.user.uid;
    }

    try {
      final data = await _repository.getActivitySummary(userId);
      if (mounted) {
        state = AsyncValue.data(data);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

final StateNotifierProvider<ActivityNotifier, AsyncValue<ActivitySummary>> activitySummaryProvider =
    StateNotifierProvider<ActivityNotifier, AsyncValue<ActivitySummary>>((Ref ref) {
  final DashboardRepository repository = ref.watch(dashboardRepositoryProvider);
  return ActivityNotifier(repository, ref);
});

// Weather State Provider with Geolocation fetching & fallback coordinates
class WeatherNotifier extends StateNotifier<AsyncValue<WeatherInfo>> {
  final DashboardRepository _repository;

  WeatherNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadWeather();
  }

  Future<void> loadWeather() async {
    state = const AsyncValue.loading();
    try {
      double lat = 6.9271; // Default to Colombo coordinates
      double lon = 79.8612;

      // Try geolocator to fetch current GPS coordinates
      try {
        final Position? position = await _getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lon = position.longitude;
        }
      } catch (_) {
        // Fallback to default coordinates on exception
      }

      final weather = await _repository.getWeather(lat, lon);
      if (mounted) {
        state = AsyncValue.data(weather);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 1),
        onTimeout: () => false,
      );
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 1),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 1),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      );
    } catch (_) {
      return null;
    }
  }
}

final StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherInfo>> weatherStateProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherInfo>>((Ref ref) {
  final DashboardRepository repository = ref.watch(dashboardRepositoryProvider);
  return WeatherNotifier(repository);
});
