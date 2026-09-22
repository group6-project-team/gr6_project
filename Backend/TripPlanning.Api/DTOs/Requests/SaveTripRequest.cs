using System.Text.Json;

namespace TripPlanning.Api.DTOs.Requests
{
    public class SaveTripRequest
    {
        public string DestinationId { get; set; } = string.Empty;

        public int RequestedDays { get; set; }

        public JsonElement Trip { get; set; }
    }
}