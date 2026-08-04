import 'dart:async';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      return await dataSource.signIn(email, password);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserEntity?> register(String fullName, String email, String password) async {
    try {
      return await dataSource.register(fullName, email, password);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dataSource.logout();
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await dataSource.resetPassword(email);
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      await dataSource.verifyEmail();
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await dataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity?> refreshUser() async {
    try {
      return await dataSource.refreshUser();
    } catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Stream<UserEntity?> get authStream {
    return dataSource.authStream.map((UserEntity? user) => user);
  }

  Exception _mapException(dynamic e) {
    if (e is ServerException) return e;
    return ServerException(message: e.toString());
  }
}
