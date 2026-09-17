using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class RealTripPreviewService : IRealTripPreviewService
    {
        private readonly IPlanningService _planningService;

        public RealTripPreviewService(
            IPlanningService planningService)
        {
            _planningService = planningService;
        }

        public async Task<TripPlanPreviewResponse> GeneratePreviewAsync(
            TripPlanPreviewRequest request,
            string requestId,
            CancellationToken cancellationToken)
        {
            var candidatePlaces = CreateStage2ACandidates(
                request.DestinationId!);

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

        private static List<PlaceCandidateRequest> CreateStage2ACandidates(
            string destinationId)
        {
            if (destinationId == "istanbul")
            {
                return new List<PlaceCandidateRequest>
                {
                    new()
                    {
                        Id = "ist-001",
                        DestinationId = "istanbul",
                        Name = "Hagia Sophia",
                        CategoryIds = new List<string>
                        {
                            "historic_site",
                            "museum"
                        },
                        Latitude = 41.0086,
                        Longitude = 28.9802
                    },
                    new()
                    {
                        Id = "ist-002",
                        DestinationId = "istanbul",
                        Name = "Topkapi Palace",
                        CategoryIds = new List<string>
                        {
                            "historic_site",
                            "museum"
                        },
                        Latitude = 41.0115,
                        Longitude = 28.9833
                    },
                    new()
                    {
                        Id = "ist-003",
                        DestinationId = "istanbul",
                        Name = "Blue Mosque",
                        CategoryIds = new List<string>
                        {
                            "historic_site",
                            "monument"
                        },
                        Latitude = 41.0054,
                        Longitude = 28.9768
                    },
                    new()
                    {
                        Id = "ist-004",
                        DestinationId = "istanbul",
                        Name = "Grand Bazaar",
                        CategoryIds = new List<string>
                        {
                            "market",
                            "culture"
                        },
                        Latitude = 41.0106,
                        Longitude = 28.9681
                    },
                    new()
                    {
                        Id = "ist-005",
                        DestinationId = "istanbul",
                        Name = "Galata Tower",
                        CategoryIds = new List<string>
                        {
                            "monument",
                            "viewpoint"
                        },
                        Latitude = 41.0256,
                        Longitude = 28.9744
                    },
                    new()
                    {
                        Id = "ist-006",
                        DestinationId = "istanbul",
                        Name = "Istanbul Archaeological Museums",
                        CategoryIds = new List<string>
                        {
                            "museum",
                            "history"
                        },
                        Latitude = 41.0117,
                        Longitude = 28.9813
                    },
                    new()
                    {
                        Id = "ist-007",
                        DestinationId = "istanbul",
                        Name = "Basilica Cistern",
                        CategoryIds = new List<string>
                        {
                            "historic_site"
                        },
                        Latitude = 41.0084,
                        Longitude = 28.9778
                    },
                    new()
                    {
                        Id = "ist-008",
                        DestinationId = "istanbul",
                        Name = "Dolmabahce Palace",
                        CategoryIds = new List<string>
                        {
                            "historic_site",
                            "museum"
                        },
                        Latitude = 41.0392,
                        Longitude = 29.0005
                    },
                    new()
                    {
                        Id = "ist-009",
                        DestinationId = "istanbul",
                        Name = "Spice Bazaar",
                        CategoryIds = new List<string>
                        {
                            "market",
                            "food"
                        },
                        Latitude = 41.0165,
                        Longitude = 28.9705
                    }
                };
            }

            if (destinationId == "rome")
            {
                return new List<PlaceCandidateRequest>
                {
                    new()
                    {
                        Id = "rom-001",
                        DestinationId = "rome",
                        Name = "Colosseum",
                        CategoryIds = new List<string>
                        {
                            "historic_site",
                            "monument"
                        },
                        Latitude = 41.8902,
                        Longitude = 12.4922
                    },
                    new()
                    {
                        Id = "rom-002",
                        DestinationId = "rome",
                        Name = "Roman Forum",
                        CategoryIds = new List<string>
                        {
                            "historic_site"
                        },
                        Latitude = 41.8925,
                        Longitude = 12.4853
                    }
                };
            }

            return new List<PlaceCandidateRequest>();
        }
    }
}