using System.Net;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using TripPlanning.Api.Exceptions;
using TripPlanning.Api.Services.Classes;

namespace TripPlanning.Api.Tests.Services
{
    public class GeoapifyClientTests
    {
        private sealed class StubHttpMessageHandler : HttpMessageHandler
        {
            private readonly Func<
                HttpRequestMessage,
                CancellationToken,
                Task<HttpResponseMessage>> _handler;

            public StubHttpMessageHandler(
                Func<
                    HttpRequestMessage,
                    CancellationToken,
                    Task<HttpResponseMessage>> handler)
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
        public async Task GetPlacesAsync_ReturnsJsonDocument_WhenResponseIsSuccessful()
        {
            // Arrange
            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                {
                    var response = new HttpResponseMessage(HttpStatusCode.OK)
                    {
                        Content = new StringContent(
                            """
                            {
                              "features": [
                                {
                                  "properties": {
                                    "place_id": "test-place-id"
                                  }
                                }
                              ]
                            }
                            """)
                    };

                    return Task.FromResult(response);
                });

            var client = CreateClient(handler);

            // Act
            using var document = await client.GetPlacesAsync(
                "istanbul",
                CancellationToken.None);

            // Assert
            var features = document.RootElement.GetProperty("features");

            Assert.Single(features.EnumerateArray());
        }

        [Fact]
        public async Task GetPlacesAsync_UsesExpectedFatihBoundedRequest()
        {
            // Arrange
            Uri? capturedUri = null;

            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                {
                    capturedUri = request.RequestUri;

                    return Task.FromResult(
                        new HttpResponseMessage(HttpStatusCode.OK)
                        {
                            Content = new StringContent(
                                """
                                {
                                  "features": []
                                }
                                """)
                        });
                });

            var client = CreateClient(handler);

            // Act
            using var document = await client.GetPlacesAsync(
                "istanbul",
                CancellationToken.None);

            // Assert
            Assert.NotNull(capturedUri);

            var uri = capturedUri!.ToString();

            Assert.Contains(
                "categories=tourism.sights",
                uri);

            Assert.Contains(
                "filter=place:510de9a683abf23c40598128f3ea77824440f00101f901d8f21a0000000000c002089203054661746968",
                uri);

            Assert.Contains(
                "limit=20",
                uri);

            Assert.Contains(
                "lang=en",
                uri);

            Assert.Contains(
                "apiKey=test-api-key",
                uri);
        }

        [Fact]
        public async Task GetPlacesAsync_Throws_WhenApiKeyIsMissing()
        {
            // Arrange
            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                    Task.FromResult(
                        new HttpResponseMessage(HttpStatusCode.OK)));

            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("https://api.geoapify.com/")
            };

            var configuration = new ConfigurationManager();

            var client = new GeoapifyClient(
                httpClient,
                configuration,
                NullLogger<GeoapifyClient>.Instance);

            // Act & Assert
            await Assert.ThrowsAsync<PlanningFailedException>(
                () => client.GetPlacesAsync(
                    "istanbul",
                    CancellationToken.None));
        }

        [Fact]
        public async Task GetPlacesAsync_Throws_ForUnsupportedDestination()
        {
            // Arrange
            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                    Task.FromResult(
                        new HttpResponseMessage(HttpStatusCode.OK)));

            var client = CreateClient(handler);

            // Act & Assert
            await Assert.ThrowsAsync<PlanningFailedException>(
                () => client.GetPlacesAsync(
                    "rome",
                    CancellationToken.None));
        }

        [Fact]
        public async Task GetPlacesAsync_ThrowsControlledUnavailableError_WhenProviderReturnsError()
        {
            // Arrange
            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                    Task.FromResult(
                        new HttpResponseMessage(
                            HttpStatusCode.InternalServerError)));

            var client = CreateClient(handler);

            // Act & Assert
            await Assert.ThrowsAsync<PlanningServiceUnavailableException>(
                () => client.GetPlacesAsync(
                    "istanbul",
                    CancellationToken.None));
        }

        [Fact]
        public async Task GetPlacesAsync_ThrowsControlledPlanningError_WhenResponseIsMalformed()
        {
            // Arrange
            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                    Task.FromResult(
                        new HttpResponseMessage(HttpStatusCode.OK)
                        {
                            Content = new StringContent(
                                "{ invalid json")
                        }));

            var client = CreateClient(handler);

            // Act & Assert
            await Assert.ThrowsAsync<PlanningFailedException>(
                () => client.GetPlacesAsync(
                    "istanbul",
                    CancellationToken.None));
        }

        [Fact]
        public async Task GetPlacesAsync_DoesNotWriteApiKeyToApplicationLogs()
        {
            const string apiKey = "secret-key-that-must-not-be-logged";
            var logger = new CapturingLogger<GeoapifyClient>();
            var handler = new StubHttpMessageHandler(
                (request, cancellationToken) =>
                    throw new HttpRequestException(
                        $"Provider failure for {request.RequestUri}"));
            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri("https://api.geoapify.com/")
            };
            var configuration = new ConfigurationManager
            {
                ["GEOAPIFY_API_KEY"] = apiKey
            };
            var client = new GeoapifyClient(
                httpClient,
                configuration,
                logger);

            await Assert.ThrowsAsync<PlanningServiceUnavailableException>(
                () => client.GetPlacesAsync(
                    "istanbul",
                    CancellationToken.None));

            Assert.DoesNotContain(
                logger.Messages,
                message => message.Contains(apiKey, StringComparison.Ordinal));
        }

        private static GeoapifyClient CreateClient(
            HttpMessageHandler handler)
        {
            var httpClient = new HttpClient(handler)
            {
                BaseAddress = new Uri(
                    "https://api.geoapify.com/")
            };

            var configuration = new ConfigurationManager
            {
                ["GEOAPIFY_API_KEY"] = "test-api-key"
            };

            return new GeoapifyClient(
                httpClient,
                configuration,
                NullLogger<GeoapifyClient>.Instance);
        }

        private sealed class CapturingLogger<T> : ILogger<T>
        {
            public List<string> Messages { get; } = new();

            public IDisposable? BeginScope<TState>(TState state)
                where TState : notnull => null;

            public bool IsEnabled(LogLevel logLevel) => true;

            public void Log<TState>(
                LogLevel logLevel,
                EventId eventId,
                TState state,
                Exception? exception,
                Func<TState, Exception?, string> formatter)
            {
                Messages.Add(formatter(state, exception));
            }
        }
    }
}
