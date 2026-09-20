import '../config/app_config.dart';
import 'backend_trip_api.dart';
import 'trip_api.dart';

/// Builds the public ASP.NET client. Mock implementations live under test/.
TripApi createTripApi() {
  return BackendTripApi(
    baseUrl: AppConfig.backendBaseUrl,
    timeout: AppConfig.requestTimeout,
  );
}
