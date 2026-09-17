using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Services.Interfaces
{
    public interface IPlanningService
    {
        Task<FastApiPlanResponse> PlanAsync(
            FastApiPlanRequest request,
            string requestId,
            CancellationToken cancellationToken);
    }
}