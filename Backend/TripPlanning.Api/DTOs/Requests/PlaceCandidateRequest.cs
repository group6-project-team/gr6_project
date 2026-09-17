namespace TripPlanning.Api.DTOs.Requests
{
    public class PlaceCandidateRequest
    {
        public string Id { get; set; } = string.Empty;

        public string DestinationId { get; set; } = string.Empty;

        public string Name { get; set; } = string.Empty;

        public List<string> CategoryIds { get; set; } = new();

        public double Latitude { get; set; }

        public double Longitude { get; set; }
    }
}