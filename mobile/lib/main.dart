import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/trip_api.dart';
import 'services/trip_api_factory.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_canvas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TripPlannerApp(api: createTripApi()));
}

class TripPlannerApp extends StatelessWidget {
  const TripPlannerApp({
    super.key,
    required this.api,
    this.skipIntro = false,
    this.splashDuration = const Duration(milliseconds: 7000),
  });

  final TripApi api;
  final bool skipIntro;
  final Duration splashDuration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triply',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) => PhoneCanvas(child: child ?? const SizedBox.shrink()),
      home: skipIntro
          ? MainShell(api: api)
          : SplashScreen(api: api, displayDuration: splashDuration),
    );
  }
}
