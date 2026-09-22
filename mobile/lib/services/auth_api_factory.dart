import '../config/app_config.dart';
import 'auth_api.dart';
import 'auth_session_store.dart';
import 'backend_auth_api.dart';

AuthApi createAuthApi() {
  return BackendAuthApi(baseUrl: AppConfig.backendBaseUrl);
}

AuthSessionStore createAuthSessionStore() {
  return InMemoryAuthSessionStore();
}
