// core/app_config/app_config_service.dart

import '../atomic_state/result.dart';
import '../http/http_client.dart';
import 'adapters/app_config_adapter.dart';
import 'domain/app_config.dart';

/// Fetches the app configuration from the backend.
/// Arrow syntax only — no try/catch, no async/await.
/// Result<T> and error handling are managed by APIRequest + ResponseInterceptor.
class AppConfigService extends APIRequest {
  Future<Result<AppConfig>> fetchConfig() => authGet('/v4/profile-config', AppConfigAdapter.fromJson);
}
