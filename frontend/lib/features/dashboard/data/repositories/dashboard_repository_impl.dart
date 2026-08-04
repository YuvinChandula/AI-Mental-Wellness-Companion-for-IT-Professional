import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/activity_summary.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/weather_info.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<WeatherInfo> getWeather(double lat, double lon) async {
    try {
      final weather = await remoteDataSource.getWeather(lat, lon);
      await localDataSource.cacheWeather(weather);
      return weather;
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) return cached;
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) return cached;
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) return cached;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<DashboardData> getDashboardData(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await localDataSource.getCachedDashboardData();
      if (cached != null) return cached;
    }
    try {
      final data = await remoteDataSource.getDashboardData(userId);
      await localDataSource.cacheDashboardData(data);
      return data;
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedDashboardData();
      if (cached != null) return cached;
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedDashboardData();
      if (cached != null) return cached;
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedDashboardData();
      if (cached != null) return cached;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<ActivitySummary> getActivitySummary(String userId) async {
    try {
      final activity = await remoteDataSource.getActivitySummary(userId);
      await localDataSource.cacheActivitySummary(activity);
      return activity;
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedActivitySummary();
      if (cached != null) return cached;
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedActivitySummary();
      if (cached != null) return cached;
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedActivitySummary();
      if (cached != null) return cached;
      throw ServerFailure(message: e.toString());
    }
  }
}
