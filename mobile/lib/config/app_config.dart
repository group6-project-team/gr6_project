/// Switch between mock data and the real ASP.NET Backend here.
///
/// Today's task must work **without** a running Backend, so mock stays on.
/// When Stage 1 starts, set [useMockApi] to false and put Mohammad's URL below.
class AppConfig {
  /// `true` = local fake Backend (no internet, no ASP.NET).
  /// `false` = call only the public ASP.NET API.
  static const bool useMockApi = true;

  /// Public ASP.NET base URL only.
  /// Never put a FastAPI URL or Places provider URL here.
  ///
  /// Android emulator → host machine: `http://10.0.2.2:PORT`
  /// iOS simulator / Windows / Chrome: `http://localhost:PORT`
  /// Physical phone: `http://YOUR_LAN_IP:PORT`
  static const String backendBaseUrl = 'http://10.0.2.2:5080';

  static const Duration requestTimeout = Duration(seconds: 15);
}
