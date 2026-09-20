
/// Switch between mock data and the real ASP.NET Backend here.
class AppConfig {
/// `false` = call only the public ASP.NET API (release default).
/// Mock implementations live under `test/` and are not bundled in the app.
static const bool useMockApi = false;

/// ASP.NET Backend base URL.
static const String backendBaseUrl =
'https://gr6-tripplanning-api.runasp.net/';

static const Duration requestTimeout = Duration(seconds: 15);
}

