using TripPlanning.Api.Data;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class FakeTripPreviewService : IFakeTripPreviewService
    {
        public TripPlanPreviewResponse GeneratePreview(TripPlanPreviewRequest request)
        {
            int requestedDays = request.Days!.Value;

            var availablePlaces = FakeTripData.PlacesByDestination[request.DestinationId!];

            int candidateCount = availablePlaces.Count;

            int selectedCount = Math.Min(candidateCount, 3 * requestedDays);

            var selectedPlaces = availablePlaces
                .Take(selectedCount)
                .ToList();

            int baseCapacity = selectedCount / requestedDays;
            int extraPlaces = selectedCount % requestedDays;

            var days = new List<TripDayResponse>();

            int placeIndex = 0;

            for (int dayNumber = 1; dayNumber <= requestedDays; dayNumber++)
            {
                int dayCapacity = baseCapacity;

                if (dayNumber <= extraPlaces)
                {
                    dayCapacity++;
                }

                var dayPlaces = new List<PlaceResponse>();

                for (int i = 0; i < dayCapacity; i++)
                {
                    dayPlaces.Add(selectedPlaces[placeIndex]);
                    placeIndex++;
                }

                days.Add(new TripDayResponse
                {
                    DayNumber = dayNumber,
                    Places = dayPlaces
                });
            }

            var warnings = new List<PlanningWarningResponse>();

            if (selectedCount == 0)
            {
                warnings.Add(new PlanningWarningResponse
                {
                    Code = "NO_PLACES_AVAILABLE",
                    Message = "No places are available for the selected destination."
                });
            }
            else if (selectedCount < requestedDays)
            {
                warnings.Add(new PlanningWarningResponse
                {
                    Code = "PARTIAL_ITINERARY",
                    Message = "There are not enough places to cover every requested day."
                });
            }

            return new TripPlanPreviewResponse
            {
                DestinationId = request.DestinationId!,
                Days = days,
                Warnings = warnings
            };
        }
    }
}