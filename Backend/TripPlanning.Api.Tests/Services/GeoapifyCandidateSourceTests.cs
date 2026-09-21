using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Exceptions;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Tests.Services
{
    public class GeoapifyCandidateSourceTests
    {
        [Fact]
        public async Task GetCandidatesAsync_MapsRuinesToHistoricSite()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "tourism",
                        "tourism.sights",
                        "tourism.sights.ruines"
                    })
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            var candidate = Assert.Single(candidates);

            Assert.Equal("geoapify:test-place-id", candidate.Id);
            Assert.Equal("istanbul", candidate.DestinationId);
            Assert.Contains("historic_site", candidate.CategoryIds);
        }

        [Fact]
        public async Task GetCandidatesAsync_MapsMemorialMonumentToHistoricSiteAndMonument()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "tourism.sights.memorial",
                        "tourism.sights.memorial.monument"
                    })
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            var candidate = Assert.Single(candidates);

            Assert.Contains("historic_site", candidate.CategoryIds);
            Assert.Contains("monument", candidate.CategoryIds);
        }

        [Fact]
        public async Task GetCandidatesAsync_RejectsMemorialTumulus()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "tourism.sights.memorial",
                        "tourism.sights.memorial.tumulus"
                    })
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_RejectsGenericBuildingWithoutHistoricEvidence()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "building",
                        "tourism.sights.building"
                    })
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_AcceptsHistoricBuildingWithCorroboratingEvidence()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "building",
                        "building.historic",
                        "tourism.sights.building"
                    })
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            var candidate = Assert.Single(candidates);

            Assert.Contains("historic_site", candidate.CategoryIds);
        }

        [Fact]
        public async Task GetCandidatesAsync_RejectsWrongTown()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "tourism.sights.ruines"
                    },
                    town: "Beyoglu")
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_RejectsMissingMembershipSignal()
        {
            var client = new StubGeoapifyClient
            {
                Json = """
                {
                  "features": [
                    {
                      "properties": {
                        "place_id": "test-place-id",
                        "name": "Test Place",
                        "country_code": "tr",
                        "city": "Istanbul",
                        "lat": 41.0,
                        "lon": 28.9,
                        "categories": [
                          "tourism.sights.ruines"
                        ]
                      }
                    }
                  ]
                }
                """
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_RejectsInvalidCoordinates()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "tourism.sights.ruines"
                    },
                    latitude: 100)
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_RejectsUnmappedCategories()
        {
            var client = new StubGeoapifyClient
            {
                Json = CreateResponse(
                    categories: new[]
                    {
                        "tourism",
                        "tourism.sights"
                    })
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_DeduplicatesCanonicalIdsAndKeepsFirstEligibleRecord()
        {
            var client = new StubGeoapifyClient
            {
                Json =
                """
                {
                  "features": [
                    {
                      "properties": {
                        "place_id": "duplicate-id",
                        "name": "First Provider Record",
                        "country_code": "tr",
                        "city": "Istanbul",
                        "town": "Fatih",
                        "lat": 41.0,
                        "lon": 28.9,
                        "categories": ["tourism.sights.ruines"]
                      }
                    },
                    {
                      "properties": {
                        "place_id": "duplicate-id",
                        "name": "Second Provider Record",
                        "country_code": "tr",
                        "city": "Istanbul",
                        "town": "Fatih",
                        "lat": 41.1,
                        "lon": 29.0,
                        "categories": ["tourism.sights.memorial.monument"]
                      }
                    }
                  ]
                }
                """
            };
            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            var candidate = Assert.Single(candidates);
            Assert.Equal("geoapify:duplicate-id", candidate.Id);
            Assert.Equal("First Provider Record", candidate.Name);
            Assert.Equal(new[] { "historic_site" }, candidate.CategoryIds);
        }

        [Fact]
        public async Task GetCandidatesAsync_ThrowsControlledError_ForInvalidProviderPayload()
        {
            var client = new StubGeoapifyClient
            {
                Json = """{ "features": "not-an-array" }"""
            };
            var source = new GeoapifyCandidateSource(client);

            await Assert.ThrowsAsync<PlanningFailedException>(
                () => source.GetCandidatesAsync(
                    "istanbul",
                    CancellationToken.None));
        }

        [Fact]
        public async Task GetCandidatesAsync_Throws_WhenCancellationRequested()
        {
            var client = new StubGeoapifyClient();

            var source = new GeoapifyCandidateSource(client);

            using var cancellationTokenSource =
                new CancellationTokenSource();

            cancellationTokenSource.Cancel();

            await Assert.ThrowsAsync<OperationCanceledException>(() =>
                source.GetCandidatesAsync(
                    "istanbul",
                    cancellationTokenSource.Token));
        }

        [Fact]
        public async Task Evidence_NormalizesRealGeoapifyResponse()
        {
            var evidenceDirectory = Path.GetFullPath(
                Path.Combine(
                    AppContext.BaseDirectory,
                    "..",
                    "..",
                    "..",
                    "Evidence",
                    "Stage3"));

            var rawPath = Path.Combine(
                evidenceDirectory,
                "geoapify-raw-response.json");

            var rawJson = await File.ReadAllTextAsync(rawPath);

            var client = new StubGeoapifyClient
            {
                Json = rawJson
            };

            var source = new GeoapifyCandidateSource(client);

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            var outputPath = Path.Combine(
                evidenceDirectory,
                "geoapify-normalized-candidates.json");

            var json = JsonSerializer.Serialize(
                candidates,
                new JsonSerializerOptions
                {
                    WriteIndented = true
                });

            await File.WriteAllTextAsync(
                outputPath,
                json);

            Assert.NotEmpty(candidates);
        }

        [Fact]
        public async Task Evidence_WritesActualPlanRequestWithCanonicalInterests()
        {
            var evidenceDirectory = Path.GetFullPath(
                Path.Combine(
                    AppContext.BaseDirectory,
                    "..",
                    "..",
                    "..",
                    "Evidence",
                    "Stage3"));

            var normalizedPath = Path.Combine(
                evidenceDirectory,
                "geoapify-normalized-candidates.json");

            var normalizedJson = await File.ReadAllTextAsync(normalizedPath);

            var candidates =
                JsonSerializer.Deserialize<List<PlaceCandidateRequest>>(
                    normalizedJson)!;

            var planningRequest = new FastApiPlanRequest
            {
                DestinationId = "istanbul",
                Days = 3,
                Interests = new List<string>
        {
            "monument"
        },
                CandidatePlaces = candidates
            };

            var outputPath = Path.Combine(
                evidenceDirectory,
                "fastapi-plan-request.json");

            var json = JsonSerializer.Serialize(
                planningRequest,
                new JsonSerializerOptions
                {
                    WriteIndented = true
                });

            await File.WriteAllTextAsync(
                outputPath,
                json);

            Assert.Equal(
                new List<string> { "monument" },
                planningRequest.Interests);

            Assert.NotEmpty(planningRequest.CandidatePlaces);
        }

        private static string CreateResponse(
            string[] categories,
            string countryCode = "tr",
            string city = "Istanbul",
            string town = "Fatih",
            double latitude = 41.0,
            double longitude = 28.9)
        {
            return JsonSerializer.Serialize(new
            {
                features = new[]
                {
                    new
                    {
                        properties = new
                        {
                            place_id = "test-place-id",
                            name = "Test Place",
                            country_code = countryCode,
                            city,
                            town,
                            lat = latitude,
                            lon = longitude,
                            categories
                        }
                    }
                }
            });
        }

        private sealed class StubGeoapifyClient : IGeoapifyClient
        {
            public string Json { get; set; } =
                """
                {
                  "features": []
                }
                """;

            public Task<JsonDocument> GetPlacesAsync(
                string destinationId,
                CancellationToken cancellationToken)
            {
                return Task.FromResult(
                    JsonDocument.Parse(Json));
            }
        }
    }
}
