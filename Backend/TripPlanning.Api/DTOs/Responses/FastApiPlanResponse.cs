namespace TripPlanning.Api.DTOs.Responses
{
    public class FastApiPlanResponse
    {
        public List<FastApiPlanningDayResponse> Days { get; set; } = new();

        public List<FastApiPlanningWarningResponse> Warnings { get; set; } = new();
    }
}