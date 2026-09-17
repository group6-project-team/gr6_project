using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class PlanningService : IPlanningService
    {
        private readonly IFastApiPlanningClient _fastApiPlanningClient;

        public PlanningService(
            IFastApiPlanningClient fastApiPlanningClient)
        {
            _fastApiPlanningClient = fastApiPlanningClient;
        }

        public async Task<FastApiPlanResponse> PlanAsync(
            FastApiPlanRequest request,
            string requestId,
            CancellationToken cancellationToken)
        {
            return await _fastApiPlanningClient.PlanAsync(
                request,
                requestId,
                cancellationToken);
        }
    }
}