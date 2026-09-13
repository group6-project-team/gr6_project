namespace TripPlanning.Api.DTOs.Responses
{
    public class PlaceResponse
    {
        public string Id { get; set; } = string.Empty;

        public string Name { get; set; } = string.Empty;

        public List<string> CategoryIds { get; set; } = new();

        public string? Description { get; set; }

        public string? ImageUrl { get; set; }

        public string? Address { get; set; }
    }
}