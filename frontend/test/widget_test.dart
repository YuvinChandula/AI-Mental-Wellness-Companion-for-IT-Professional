import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsync_ai/core/routing/app_router.dart';

void main() {
  test('Router initial location verify', () {
    final ProviderContainer container = ProviderContainer();
    final router = container.read(AppRouter.routerProvider);
    expect(router.routeInformationProvider.value.uri.toString(), AppRouter.splash);
  });
}
