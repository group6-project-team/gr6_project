import '../config/app_config.dart';
import 'backend_saved_trips_api.dart';
import 'saved_trips_api.dart';

SavedTripsApi createSavedTripsApi() {
  return BackendSavedTripsApi(baseUrl: AppConfig.backendBaseUrl);
}
