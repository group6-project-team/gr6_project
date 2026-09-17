namespace TripPlanning.Api.DTOs.Requests
{
    public class FastApiPlanRequest
    {
        public string DestinationId { get; set; } = string.Empty;

        public int Days { get; set; }

        public List<string> Interests { get; set; } = new();

        public List<PlaceCandidateRequest> CandidatePlaces { get; set; } = new();
    }
}