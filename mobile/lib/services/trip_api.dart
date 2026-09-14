import '../models/trip_options.dart';
import '../models/trip_plan.dart';
import '../models/trip_request.dart';

/// The only door the UI uses to talk to "the Backend".
///
/// The screen never cares whether this is mock data or ASP.NET.
/// That is why mock and real can be swapped without rewriting widgets.
abstract class TripApi {
  Future<TripOptions> getOptions();

  Future<TripPlan> planTrip(TripPlanRequest request);
}
