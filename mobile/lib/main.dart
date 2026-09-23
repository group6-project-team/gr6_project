import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/auth_api.dart';
import 'services/auth_api_factory.dart';
import 'services/auth_session_store.dart';
import 'services/saved_trips_api.dart';
import 'services/saved_trips_api_factory.dart';
import 'services/trip_api.dart';
import 'services/trip_api_factory.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_canvas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    TripPlannerApp(
      api: createTripApi(),
      authApi: createAuthApi(),
      savedTripsApi: createSavedTripsApi(),
      sessionStore: createAuthSessionStore(),
    ),
  );
}

class TripPlannerApp extends StatelessWidget {
  const TripPlannerApp({
    super.key,
    required this.api,
    required this.authApi,
    required this.savedTripsApi,
    this.sessionStore,
    this.skipIntro = false,
    this.splashDuration = const Duration(milliseconds: 7000),
  });

  final TripApi api;
  final AuthApi authApi;
  final SavedTripsApi savedTripsApi;
  final AuthSessionStore? sessionStore;
  final bool skipIntro;
  final Duration splashDuration;

  @override
  Widget build(BuildContext context) {
    final store = sessionStore ?? InMemoryAuthSessionStore();
    return MaterialApp(
      title: 'Triply',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) => PhoneCanvas(child: child ?? const SizedBox.shrink()),
      home: skipIntro
          ? MainShell(
              api: api,
              authApi: authApi,
              savedTripsApi: savedTripsApi,
              sessionStore: store,
              initialTab: 1,
            )
          : SplashScreen(
              api: api,
              authApi: authApi,
              savedTripsApi: savedTripsApi,
              sessionStore: store,
              displayDuration: splashDuration,
            ),
    );
  }
}
