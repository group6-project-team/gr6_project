using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Tests.Services
{
    public class RealTripPreviewServiceTests
    {
        [Fact]
        public async Task GeneratePreviewAsync_UsesCandidateSource_AndReturnsEnrichedResponse()
        {
            // Arrange
            var candidateSource = new StubCandidateSource
            {
                Candidates = new List<PlaceCandidateRequest>
                {
                    new()
                    {
                        Id = "fixture-001",
                        DestinationId = "istanbul",
                        Name = "Fixture Place",
                        CategoryIds = new List<string> { "historic_site" },
                        Latitude = 41.0,
                        Longitude = 29.0
                    }
                }
            };

            var planningService = new StubPlanningService
            {
                Result = new FastApiPlanResponse
                {
                    Days = new List<FastApiPlanningDayResponse>
                    {
                        new()
                        {
                            Day = 1,
                            PlaceIds = new List<string> { "fixture-001" }
                        }
                    },
                    Warnings = new List<FastApiPlanningWarningResponse>()
                }
            };

            var service = new RealTripPreviewService(
                planningService,
                candidateSource);

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 1,
                Interests = new List<string>()
            };

            // Act
            var result = await service.GeneratePreviewAsync(
                request,
                "request-123",
                CancellationToken.None);

            // Assert
            Assert.Equal("istanbul", candidateSource.CapturedDestinationId);

            Assert.Single(result.Days);
            Assert.Single(result.Days[0].Places);

            var place = result.Days[0].Places[0];

            Assert.Equal("fixture-001", place.Id);
            Assert.Equal("Fixture Place", place.Name);
            Assert.Contains("historic_site", place.CategoryIds);
        }

        [Fact]
        public async Task GeneratePreviewAsync_DoesNotInjectFallbackCandidates_WhenSourceReturnsEmpty()
        {
            // Arrange
            var candidateSource = new StubCandidateSource
            {
                Candidates = new List<PlaceCandidateRequest>()
            };

            var planningService = new StubPlanningService
            {
                Result = new FastApiPlanResponse
                {
                    Days = new List<FastApiPlanningDayResponse>
                    {
                        new()
                        {
                            Day = 1,
                            PlaceIds = new List<string>()
                        }
                    },
                    Warnings = new List<FastApiPlanningWarningResponse>()
                }
            };

            var service = new RealTripPreviewService(
                planningService,
                candidateSource);

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 1,
                Interests = new List<string>()
            };

            // Act
            var result = await service.GeneratePreviewAsync(
                request,
                "request-456",
                CancellationToken.None);

            // Assert
            Assert.Empty(planningService.CapturedRequest!.CandidatePlaces);
            Assert.Single(result.Days);
            Assert.Empty(result.Days[0].Places);
        }

        [Fact]
        public async Task GeneratePreviewAsync_MapsHistoryInterestToHistoricSite()
        {
            // Arrange
            var candidateSource = new StubCandidateSource
            {
                Candidates = new List<PlaceCandidateRequest>()
            };

            var planningService = new StubPlanningService
            {
                Result = new FastApiPlanResponse
                {
                    Days = new List<FastApiPlanningDayResponse>
            {
                new()
                {
                    Day = 1,
                    PlaceIds = new List<string>()
                }
            },
                    Warnings = new List<FastApiPlanningWarningResponse>()
                }
            };

            var service = new RealTripPreviewService(
                planningService,
                candidateSource);

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 1,
                Interests = new List<string>
        {
            "history"
        }
            };

            // Act
            await service.GeneratePreviewAsync(
                request,
                "request-history",
                CancellationToken.None);

            // Assert
            Assert.Equal(
                new List<string> { "historic_site" },
                planningService.CapturedRequest!.Interests);
        }

        [Fact]
        public async Task GeneratePreviewAsync_MapsLandmarkInterestToMonument()
        {
            // Arrange
            var candidateSource = new StubCandidateSource
            {
                Candidates = new List<PlaceCandidateRequest>()
            };

            var planningService = new StubPlanningService
            {
                Result = new FastApiPlanResponse
                {
                    Days = new List<FastApiPlanningDayResponse>
            {
                new()
                {
                    Day = 1,
                    PlaceIds = new List<string>()
                }
            },
                    Warnings = new List<FastApiPlanningWarningResponse>()
                }
            };

            var service = new RealTripPreviewService(
                planningService,
                candidateSource);

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 1,
                Interests = new List<string>
        {
            "landmark"
        }
            };

            // Act
            await service.GeneratePreviewAsync(
                request,
                "request-landmark",
                CancellationToken.None);

            // Assert
            Assert.Equal(
                new List<string> { "monument" },
                planningService.CapturedRequest!.Interests);
        }

        [Fact]
        public async Task GeneratePreviewAsync_PreservesEmptyInterests()
        {
            // Arrange
            var candidateSource = new StubCandidateSource
            {
                Candidates = new List<PlaceCandidateRequest>()
            };

            var planningService = new StubPlanningService
            {
                Result = new FastApiPlanResponse
                {
                    Days = new List<FastApiPlanningDayResponse>
            {
                new()
                {
                    Day = 1,
                    PlaceIds = new List<string>()
                }
            },
                    Warnings = new List<FastApiPlanningWarningResponse>()
                }
            };

            var service = new RealTripPreviewService(
                planningService,
                candidateSource);

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 1,
                Interests = new List<string>()
            };

            // Act
            await service.GeneratePreviewAsync(
                request,
                "request-empty",
                CancellationToken.None);

            // Assert
            Assert.Empty(planningService.CapturedRequest!.Interests);
        }

        private sealed class StubCandidateSource : ICandidateSource
        {
            public List<PlaceCandidateRequest> Candidates { get; set; } = new();

            public string? CapturedDestinationId { get; private set; }

            public Task<List<PlaceCandidateRequest>> GetCandidatesAsync(
                string destinationId,
                CancellationToken cancellationToken)
            {
                CapturedDestinationId = destinationId;

                return Task.FromResult(Candidates);
            }
        }

        private sealed class StubPlanningService : IPlanningService
        {
            public FastApiPlanResponse Result { get; set; } = new();

            public FastApiPlanRequest? CapturedRequest { get; private set; }

            public Task<FastApiPlanResponse> PlanAsync(
                FastApiPlanRequest request,
                string requestId,
                CancellationToken cancellationToken)
            {
                CapturedRequest = request;

                return Task.FromResult(Result);
            }
        }
    }
}