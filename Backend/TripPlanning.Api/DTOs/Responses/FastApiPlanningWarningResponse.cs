using System.Text.Json.Serialization;

namespace TripPlanning.Api.DTOs.Responses
{
    public class FastApiPlanningWarningResponse
    {
        [JsonRequired]
        public string? Code { get; set; }

        [JsonRequired]
        public string? Message { get; set; }
    }
}