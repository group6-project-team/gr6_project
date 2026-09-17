using System.Text.Json.Serialization;

namespace TripPlanning.Api.DTOs.Responses
{
    public class FastApiPlanningDayResponse
    {
        [JsonRequired]
        public int Day { get; set; }

        [JsonRequired]
        public List<string>? PlaceIds { get; set; }
    }
}