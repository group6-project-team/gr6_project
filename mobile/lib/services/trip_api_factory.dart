import '../config/app_config.dart';
import 'backend_trip_api.dart';
import 'mock_trip_api.dart';
import 'trip_api.dart';

/// Builds the API implementation chosen in [AppConfig].
TripApi createTripApi() {
  if (AppConfig.useMockApi) {
    return MockTripApi();
  }
  return BackendTripApi(baseUrl: AppConfig.backendBaseUrl);
}
