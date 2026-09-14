namespace TripPlanning.Api.DTOs.Requests
{
    public class TripPlanPreviewRequest
    {
        public string? DestinationId { get; set; }

        public int? Days { get; set; }

        public List<string>? Interests { get; set; }
    }
}