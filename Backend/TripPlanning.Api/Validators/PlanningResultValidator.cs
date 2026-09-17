using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Validators
{
    public class PlanningResultValidator : IPlanningResultValidator
    {
        public bool IsValid(
            FastApiPlanRequest request,
            FastApiPlanResponse response)
        {
            if (response.Days.Count != request.Days)
            {
                return false;
            }

            var actualDays = response.Days
                .Select(day => day.Day)
                .OrderBy(day => day)
                .ToList();

            var expectedDays = Enumerable
                .Range(1, request.Days)
                .ToList();

            if (!actualDays.SequenceEqual(expectedDays))
            {
                return false;
            }

            int candidateCount = request.CandidatePlaces.Count;

            int expectedSelectedCount = Math.Min(
                candidateCount,
                3 * request.Days);

            int actualSelectedCount = response.Days
                .Sum(day => day.PlaceIds.Count);

            if (actualSelectedCount != expectedSelectedCount)
            {
                return false;
            }

            int baseCapacity =
                expectedSelectedCount / request.Days;

            int extraPlaces =
                expectedSelectedCount % request.Days;

            foreach (var day in response.Days)
            {
                int expectedCapacity =
                    day.Day <= extraPlaces
                        ? baseCapacity + 1
                        : baseCapacity;

                if (day.PlaceIds.Count != expectedCapacity)
                {
                    return false;
                }
            }

            if (response.Days.Any(day => day.PlaceIds.Count > 3))
            {
                return false;
            }

            var candidateIds = request.CandidatePlaces
                .Select(place => place.Id)
                .ToHashSet();

            var selectedIds = response.Days
                .SelectMany(day => day.PlaceIds)
                .ToList();

            if (selectedIds.Any(id => !candidateIds.Contains(id)))
            {
                return false;
            }

            if (selectedIds.Count != selectedIds.Distinct().Count())
            {
                return false;
            }

            var warningCodes = response.Warnings
                .Select(warning => warning.Code)
                .ToList();

            if (expectedSelectedCount == 0)
            {
                if (warningCodes.Count != 1 ||
                    warningCodes[0] != "NO_PLACES_AVAILABLE")
                {
                    return false;
                }
            }
            else if (expectedSelectedCount < request.Days)
            {
                if (warningCodes.Count != 1 ||
                    warningCodes[0] != "PARTIAL_ITINERARY")
                {
                    return false;
                }
            }
            else
            {
                if (warningCodes.Count != 0)
                {
                    return false;
                }
            }

            return true;
        }
    }
}