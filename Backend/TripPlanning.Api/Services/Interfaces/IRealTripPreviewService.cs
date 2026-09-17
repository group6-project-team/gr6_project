using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Services.Interfaces
{
    public interface IRealTripPreviewService
    {
        Task<TripPlanPreviewResponse> GeneratePreviewAsync(
            TripPlanPreviewRequest request,
            string requestId,
            CancellationToken cancellationToken);
    }
}