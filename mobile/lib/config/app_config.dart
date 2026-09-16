
/// Switch between mock data and the real ASP.NET Backend here.
class AppConfig {
/// `false` = call only the public ASP.NET API (Stage 1 default).
/// `true` = local mock for tests / explicit offline demo. Never used as a
/// silent fallback after a real request fails.
static const bool useMockApi = false;

/// ASP.NET Backend base URL.
static const String backendBaseUrl =
'https://gr6-tripplanning-api.runasp.net/';

static const Duration requestTimeout = Duration(seconds: 15);
}

