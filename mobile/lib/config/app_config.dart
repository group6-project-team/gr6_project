/// Switch between mock data and the real ASP.NET Backend here.
class AppConfig {
  /// `false` = call only the public ASP.NET API (Stage 1 default).
  /// `true` = local mock for tests / explicit offline demo. Never used as a
  /// silent fallback after a real request fails.
  static const bool useMockApi = false;

  /// Public ASP.NET base URL only. Never FastAPI or Places.
  ///
  /// Android emulator → host machine: `http://10.0.2.2:5185`
  /// Windows / iOS simulator: `http://localhost:5185`
  /// Physical phone: `http://YOUR_LAN_IP:5185`
  ///
  /// Ask Mohammad to run the Backend `http` launch profile on port 5185.
  static const String backendBaseUrl = 'http://10.0.2.2:5185';

  static const Duration requestTimeout = Duration(seconds: 15);
}
