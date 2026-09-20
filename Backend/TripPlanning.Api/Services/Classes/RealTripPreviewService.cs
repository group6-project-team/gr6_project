using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class RealTripPreviewService : IRealTripPreviewService
    {
        private readonly IPlanningService _planningService;
        private readonly ICandidateSource _candidateSource;

        public RealTripPreviewService(
            IPlanningService planningService,
            ICandidateSource candidateSource)
        {
            _planningService = planningService;
            _candidateSource = candidateSource;
        }

        public async Task<TripPlanPreviewResponse> GeneratePreviewAsync(
            TripPlanPreviewRequest request,
            string requestId,
            CancellationToken cancellationToken)
        {
            var candidatePlaces = await _candidateSource.GetCandidatesAsync(
                request.DestinationId!,
                cancellationToken);

            var canonicalInterests = new List<string>();

            var planningRequest = new FastApiPlanRequest
            {
                DestinationId = request.DestinationId!,
                Days = request.Days!.Value,
                Interests = canonicalInterests,
                CandidatePlaces = candidatePlaces
            };

            var planningResult = await _planningService.PlanAsync(
                planningRequest,
                requestId,
                cancellationToken);

            var candidateLookup = candidatePlaces
                .ToDictionary(place => place.Id);

            var responseDays = planningResult.Days!
                .Select(day => new TripDayResponse
                {
                    DayNumber = day.Day,
                    Places = day.PlaceIds!
                        .Select(placeId =>
                        {
                            var candidate = candidateLookup[placeId];

                            return new PlaceResponse
                            {
                                Id = candidate.Id,
                                Name = candidate.Name,
                                CategoryIds = candidate.CategoryIds
                            };
                        })
                        .ToList()
                })
                .ToList();

            var responseWarnings = planningResult.Warnings!
                .Select(warning => new PlanningWarningResponse
                {
                    Code = warning.Code!,
                    Message = warning.Message!
                })
                .ToList();

            return new TripPlanPreviewResponse
            {
                DestinationId = request.DestinationId!,
                Days = responseDays,
                Warnings = responseWarnings
            };
        }
    }
}