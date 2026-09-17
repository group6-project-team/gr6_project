using System.Text.Json.Serialization;

namespace TripPlanning.Api.DTOs.Responses
{
    public class PlanningErrorResponse
    {
        [JsonPropertyName("code")]
        public string Code { get; set; } = string.Empty;

        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;
    }
}