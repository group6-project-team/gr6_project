namespace TripPlanning.Api.DTOs.Responses
{
    public class FastApiPlanningDayResponse
    {
        public int Day { get; set; }

        public List<string> PlaceIds { get; set; } = new();
    }
}