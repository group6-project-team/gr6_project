using System.Text.Json;
using TripPlanning.Api.Exceptions;
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
                _logger.LogError(
                    "Geoapify provider configuration is missing its API key.");

                throw new PlanningFailedException(
                    "Geoapify provider configuration is invalid.");
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
                _logger.LogWarning(
                    "Geoapify destination is unsupported. DestinationId: {DestinationId}",
                    destinationId);

                throw new PlanningFailedException(
                    "Geoapify does not support the requested destination.");
            }

            var requestUri =
                $"v2/places?categories=tourism.sights&filter=place:{placeId}&limit=20&lang=en&apiKey={apiKey}";

            try
            {
                using var response = await _httpClient.GetAsync(
                    requestUri,
                    cancellationToken);

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning(
                        "Geoapify returned unsuccessful status {StatusCode}.",
                        (int)response.StatusCode);

                    throw new PlanningServiceUnavailableException(
                        "Geoapify is unavailable.");
                }

                await using var stream = await response.Content.ReadAsStreamAsync(
                    cancellationToken);

                return await JsonDocument.ParseAsync(
                    stream,
                    cancellationToken: cancellationToken);
            }
            catch (OperationCanceledException ex)
                when (!cancellationToken.IsCancellationRequested)
            {
                _logger.LogWarning("Geoapify request timed out.");

                throw new PlanningServiceUnavailableException(
                    "Geoapify request timed out.",
                    ex);
            }
            catch (HttpRequestException ex)
            {
                // Transport exceptions can include the full URI and API key.
                _logger.LogWarning("Geoapify connection failed.");

                throw new PlanningServiceUnavailableException(
                    "Geoapify is unavailable.",
                    ex);
            }
            catch (JsonException ex)
            {
                _logger.LogError("Geoapify returned a malformed response.");

                throw new PlanningFailedException(
                    "Geoapify returned a malformed response.",
                    ex);
            }
        }
    }
}
