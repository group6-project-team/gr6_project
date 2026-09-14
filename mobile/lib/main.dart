import 'package:flutter/material.dart';

import 'screens/trip_form_screen.dart';
import 'services/trip_api.dart';
import 'services/trip_api_factory.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(TripPlannerApp(api: createTripApi()));
}

class TripPlannerApp extends StatelessWidget {
  const TripPlannerApp({super.key, required this.api});

  final TripApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triply',
      theme: AppTheme.light(),
      home: TripFormScreen(api: api),
    );
  }
}
