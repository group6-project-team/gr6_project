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

        public FastApiPlanningClient(
            HttpClient httpClient,
            IPlanningResultValidator planningResultValidator)
        {
            _httpClient = httpClient;
            _planningResultValidator = planningResultValidator;
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
                    throw new PlanningServiceUnavailableException(
                        "Planning service is unavailable.");
                }

                if (!response.IsSuccessStatusCode)
                {
                    throw new PlanningFailedException(
                        "Planning service returned an unsuccessful response.");
                }

                var result = await response.Content.ReadFromJsonAsync<FastApiPlanResponse>(
                    cancellationToken: cancellationToken);

                if (result is null ||
                    !_planningResultValidator.IsValid(request, result))
                {
                    throw new PlanningFailedException(
                        "Planning service returned an invalid planning result.");
                }

                return result;
            }
            catch (OperationCanceledException ex)
                when (!cancellationToken.IsCancellationRequested)
            {
                throw new PlanningServiceUnavailableException(
                    "Planning service request timed out.",
                    ex);
            }
            catch (HttpRequestException ex)
            {
                throw new PlanningServiceUnavailableException(
                    "Planning service is unavailable.",
                    ex);
            }
            catch (JsonException ex)
            {
                throw new PlanningFailedException(
                    "Planning service returned a malformed response.",
                    ex);
            }
        }
    }
}