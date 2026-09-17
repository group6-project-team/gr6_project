using System.Net;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.Validators;

namespace TripPlanning.Api.Tests.Services
{
    public class FastApiPlanningClientTests
    {
        private class StubHttpMessageHandler : HttpMessageHandler
        {
            private readonly Func<HttpRequestMessage, CancellationToken, Task<HttpResponseMessage>> _handler;

            public StubHttpMessageHandler(
                Func<HttpRequestMessage, CancellationToken, Task<HttpResponseMessage>> handler)
            {
                _handler = handler;
            }

            protected override Task<HttpResponseMessage> SendAsync(
                HttpRequestMessage request,
                CancellationToken cancellationToken)
            {
                return _handler(request, cancellationToken);
            }
        }

        [Fact]
        public async Task PlanAsync_ThrowsPlanningFailedException_WhenResponseIsMalformed()
        {
            // Arrange
            var handler = new StubHttpMessageHandler((request, cancellationToken) =>
            {
                var response = new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent("{ invalid json")
                };

                return Task.FromResult(response);
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/")
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 1,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            // Act & Assert
            await Assert.ThrowsAsync<TripPlanning.Api.Exceptions.PlanningFailedException>(
                () => client.PlanAsync(
                    request,
                    "test-request-id",
                    CancellationToken.None));
        }

        [Fact]
        public async Task PlanAsync_ThrowsPlanningFailedException_WhenServerReturnsError()
        {
            // Arrange
            var handler = new StubHttpMessageHandler((request, cancellationToken) =>
            {
                var response = new HttpResponseMessage(HttpStatusCode.InternalServerError);

                return Task.FromResult(response);
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/")
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 1,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            // Act & Assert
            await Assert.ThrowsAsync<TripPlanning.Api.Exceptions.PlanningFailedException>(
                () => client.PlanAsync(
                    request,
                    "test-request-id",
                    CancellationToken.None));
        }

        [Fact]
        public async Task PlanAsync_ThrowsPlanningServiceUnavailableException_WhenServiceReturns503()
        {
            // Arrange
            var handler = new StubHttpMessageHandler((request, cancellationToken) =>
            {
                var response = new HttpResponseMessage(HttpStatusCode.ServiceUnavailable);

                return Task.FromResult(response);
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/")
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 1,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            // Act & Assert
            await Assert.ThrowsAsync<TripPlanning.Api.Exceptions.PlanningServiceUnavailableException>(
                () => client.PlanAsync(
                    request,
                    "test-request-id",
                    CancellationToken.None));
        }

        [Fact]
        public async Task PlanAsync_ThrowsPlanningServiceUnavailableException_WhenRequestTimesOut()
        {
            // Arrange
            var handler = new StubHttpMessageHandler(async (request, cancellationToken) =>
            {
                await Task.Delay(
                    TimeSpan.FromSeconds(5),
                    cancellationToken);

                return new HttpResponseMessage(HttpStatusCode.OK);
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/"),
                Timeout = TimeSpan.FromMilliseconds(100)
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 1,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            // Act & Assert
            await Assert.ThrowsAsync<TripPlanning.Api.Exceptions.PlanningServiceUnavailableException>(
                () => client.PlanAsync(
                    request,
                    "test-request-id",
                    CancellationToken.None));
        }

        [Fact]
        public async Task PlanAsync_ThrowsPlanningServiceUnavailableException_WhenConnectionFails()
        {
            // Arrange
            var handler = new StubHttpMessageHandler((request, cancellationToken) =>
            {
                throw new HttpRequestException("Connection failed.");
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/")
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 1,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            // Act & Assert
            await Assert.ThrowsAsync<TripPlanning.Api.Exceptions.PlanningServiceUnavailableException>(
                () => client.PlanAsync(
                    request,
                    "test-request-id",
                    CancellationToken.None));
        }

        [Fact]
        public async Task PlanAsync_PropagatesRequestIdHeader()
        {
            // Arrange
            string? capturedRequestId = null;

            var handler = new StubHttpMessageHandler((request, cancellationToken) =>
            {
                if (request.Headers.TryGetValues("X-Request-ID", out var values))
                {
                    capturedRequestId = values.FirstOrDefault();
                }

                var response = new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(
                        """
                {
                  "days": [
                    {
                      "day": 1,
                      "placeIds": []
                    }
                  ],
                  "warnings": [
                    {
                      "code": "NO_PLACES_AVAILABLE",
                      "message": "No suitable places were found in the current candidate pool."
                    }
                  ]
                }
                """,
                        System.Text.Encoding.UTF8,
                        "application/json")
                };

                return Task.FromResult(response);
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/")
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "aqaba-jo",
                Days = 1,
                Interests = new List<string>(),
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            var requestId = "test-request-123";

            // Act
            await client.PlanAsync(
                request,
                requestId,
                CancellationToken.None);

            // Assert
            Assert.Equal(
                requestId,
                capturedRequestId);
        }

        [Fact]
        public async Task PlanAsync_ThrowsPlanningFailedException_WhenPlanningResultIsSemanticallyInvalid()
        {
            // Arrange
            var handler = new StubHttpMessageHandler((request, cancellationToken) =>
            {
                var response = new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(
                        """
                {
                  "days": [
                    {
                      "day": 1,
                      "placeIds": ["p1", "p999"]
                    }
                  ],
                  "warnings": []
                }
                """,
                        System.Text.Encoding.UTF8,
                        "application/json")
                };

                return Task.FromResult(response);
            });

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("http://localhost/")
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator);

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 1,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new()
            {
                Id = "p1",
                DestinationId = "istanbul-tr",
                Name = "Hagia Sophia",
                CategoryIds = new List<string> { "historic_site" },
                Latitude = 41.0086,
                Longitude = 28.9802
            },
            new()
            {
                Id = "p2",
                DestinationId = "istanbul-tr",
                Name = "Topkapi Palace",
                CategoryIds = new List<string> { "museum" },
                Latitude = 41.0115,
                Longitude = 28.9833
            }
        }
            };

            // Act & Assert
            await Assert.ThrowsAsync<TripPlanning.Api.Exceptions.PlanningFailedException>(
                () => client.PlanAsync(
                    request,
                    "test-request-id",
                    CancellationToken.None));
        }
    }
}