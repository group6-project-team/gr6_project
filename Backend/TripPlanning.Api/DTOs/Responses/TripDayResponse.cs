namespace TripPlanning.Api.DTOs.Responses
{
    public class TripDayResponse
    {
        public int DayNumber { get; set; }

        public List<PlaceResponse> Places { get; set; } = new();
    }
}