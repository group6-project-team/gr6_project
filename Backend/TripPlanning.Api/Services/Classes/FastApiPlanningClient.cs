using System.Net.Http.Json;
using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Exceptions;
using TripPlanning.Api.Services.Interfaces;
using TripPlanning.Api.Validators;

namespace TripPlanning.Api.Services.Classes
{
    public class FastApiPlanningClient : IFastApiPlanningClient
    {
        private readonly HttpClient _httpClient;
        private readonly IPlanningResultValidator _planningResultValidator;
        private readonly ILogger<FastApiPlanningClient> _logger;

        public FastApiPlanningClient(
            HttpClient httpClient,
            IPlanningResultValidator planningResultValidator,
            ILogger<FastApiPlanningClient> logger)
        {
            _httpClient = httpClient;
            _planningResultValidator = planningResultValidator;
            _logger = logger;
        }

        public async Task<FastApiPlanResponse> PlanAsync(
            FastApiPlanRequest request,
            string requestId,
            CancellationToken cancellationToken)
        {
            try
            {
                using var httpRequest = new HttpRequestMessage(HttpMethod.Post, "plan")
                {
                    Content = JsonContent.Create(request)
                };

                httpRequest.Headers.Add("X-Request-ID", requestId);

                using var response = await _httpClient.SendAsync(
                    httpRequest,
                    cancellationToken);

                if (response.StatusCode == System.Net.HttpStatusCode.ServiceUnavailable)
                {
                    _logger.LogWarning(
                        "Planning service returned 503. RequestId: {RequestId}",
                        requestId);

                    throw new PlanningServiceUnavailableException(
                        "Planning service is unavailable.");
                }

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError(
                        "Planning service returned unsuccessful status {StatusCode}. RequestId: {RequestId}",
                        (int)response.StatusCode,
                        requestId);

                    throw new PlanningFailedException(
                        "Planning service returned an unsuccessful response.");
                }

                var result = await response.Content.ReadFromJsonAsync<FastApiPlanResponse>(
                    cancellationToken: cancellationToken);

                if (result is null ||
                    !_planningResultValidator.IsValid(request, result))
                {
                    _logger.LogError(
                        "Planning service returned an invalid planning result. RequestId: {RequestId}",
                        requestId);

                    throw new PlanningFailedException(
                        "Planning service returned an invalid planning result.");
                }

                _logger.LogInformation(
                    "Planning request completed successfully. RequestId: {RequestId}",
                    requestId);

                return result;
            }
            catch (OperationCanceledException ex)
                when (!cancellationToken.IsCancellationRequested)
            {
                _logger.LogWarning(
                    ex,
                    "Planning service request timed out. RequestId: {RequestId}",
                    requestId);

                throw new PlanningServiceUnavailableException(
                    "Planning service request timed out.",
                    ex);
            }
            catch (HttpRequestException ex)
            {
                _logger.LogWarning(
                    ex,
                    "Planning service connection failed. RequestId: {RequestId}",
                    requestId);

                throw new PlanningServiceUnavailableException(
                    "Planning service is unavailable.",
                    ex);
            }
            catch (JsonException ex)
            {
                _logger.LogError(
                    ex,
                    "Planning service returned malformed JSON. RequestId: {RequestId}",
                    requestId);

                throw new PlanningFailedException(
                    "Planning service returned a malformed response.",
                    ex);
            }
        }
    }
}