using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Validators
{
    public interface IPlanningResultValidator
    {
        bool IsValid(
            FastApiPlanRequest request,
            FastApiPlanResponse response);
    }
}