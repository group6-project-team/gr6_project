using System.Text.Json.Serialization;

namespace TripPlanning.Api.DTOs.Responses
{
    public class FastApiPlanResponse
    {
        [JsonRequired]
        public List<FastApiPlanningDayResponse>? Days { get; set; }

        [JsonRequired]
        public List<FastApiPlanningWarningResponse>? Warnings { get; set; }
    }
}