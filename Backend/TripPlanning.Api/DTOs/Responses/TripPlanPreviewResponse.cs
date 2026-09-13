namespace TripPlanning.Api.DTOs.Responses
{
    public class TripPlanPreviewResponse
    {
        public string DestinationId { get; set; } = string.Empty;

        public List<TripDayResponse> Days { get; set; } = new();

        public List<PlanningWarningResponse> Warnings { get; set; } = new();
    }
}