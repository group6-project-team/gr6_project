using System.Text.Json;

namespace TripPlanning.Api.DTOs.Responses
{
    public class SavedTripResponse
    {
        public int Id { get; set; }

        public string DestinationId { get; set; } = string.Empty;

        public int RequestedDays { get; set; }

        public JsonElement Trip { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}