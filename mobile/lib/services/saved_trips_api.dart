import '../models/saved_trip.dart';
import '../models/trip_plan.dart';

abstract class SavedTripsApi {
  Future<SavedTrip> saveTrip({
    required String token,
    required TripPlan plan,
  });

  Future<List<SavedTrip>> listTrips({required String token});

  Future<SavedTrip> getTrip({
    required String token,
    required String id,
  });

  Future<void> deleteTrip({
    required String token,
    required String id,
  });
}
