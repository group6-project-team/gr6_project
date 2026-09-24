import 'package:mobile/models/saved_trip.dart';
import 'package:mobile/models/trip_plan.dart';
import 'package:mobile/services/saved_trips_api.dart';

class FakeSavedTripsApi implements SavedTripsApi {
  final List<SavedTrip> trips = [];
  int _nextId = 1;

  @override
  Future<SavedTrip> saveTrip({
    required String token,
    required TripPlan plan,
  }) async {
    final saved = SavedTrip(
      id: '${_nextId++}',
      destinationId: plan.destinationId,
      requestedDays: plan.requestedDays,
      createdAt: DateTime.now(),
      trip: plan,
    );
    trips.insert(0, saved);
    return saved;
  }

  @override
  Future<List<SavedTrip>> listTrips({required String token}) async {
    return List<SavedTrip>.from(trips);
  }

  @override
  Future<SavedTrip> getTrip({
    required String token,
    required String id,
  }) async {
    return trips.firstWhere((trip) => trip.id == id);
  }

  @override
  Future<void> deleteTrip({
    required String token,
    required String id,
  }) async {
    trips.removeWhere((trip) => trip.id == id);
  }
}
