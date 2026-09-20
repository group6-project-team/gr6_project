using System.Text.Json;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class GeoapifyClient : IGeoapifyClient
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<GeoapifyClient> _logger;

        public GeoapifyClient(
            HttpClient httpClient,
            IConfiguration configuration,
            ILogger<GeoapifyClient> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<JsonDocument> GetPlacesAsync(
            string destinationId,
            CancellationToken cancellationToken)
        {
            var apiKey = _configuration["GEOAPIFY_API_KEY"];

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException(
                    "GEOAPIFY_API_KEY is missing.");
            }

            string placeId;

            if (string.Equals(
                destinationId,
                "istanbul",
                StringComparison.OrdinalIgnoreCase))
            {
                placeId =
                    "510de9a683abf23c40598128f3ea77824440f00101f901d8f21a0000000000c002089203054661746968";
            }
            else
            {
                throw new InvalidOperationException(
                    $"Geoapify destination is not supported: '{destinationId}'.");
            }

            var requestUri =
                $"v2/places?categories=tourism.sights&filter=place:{placeId}&limit=20&lang=en&apiKey={apiKey}";

            using var response = await _httpClient.GetAsync(
                requestUri,
                cancellationToken);

            response.EnsureSuccessStatusCode();

            await using var stream = await response.Content.ReadAsStreamAsync(
                cancellationToken);

            var document = await JsonDocument.ParseAsync(
                stream,
                cancellationToken: cancellationToken);

            return document;
        }
    }
}