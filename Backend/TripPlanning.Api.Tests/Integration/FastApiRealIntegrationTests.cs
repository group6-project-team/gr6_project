using Microsoft.Extensions.Logging.Abstractions;
using TripPlanning.Api.Tests.Fixtures;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.Validators;

namespace TripPlanning.Api.Tests.Integration
{
    public class FastApiRealIntegrationTests
    {
        [Fact]
        public async Task PlanAsync_ReturnsValidPlanningResult_FromRealFastApi()
        {
            // Arrange
            var httpClient = new HttpClient
            {
                BaseAddress = new Uri("http://127.0.0.1:8000/"),
                Timeout = TimeSpan.FromSeconds(10)
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator,
                NullLogger<FastApiPlanningClient>.Instance);

            var request = Stage2APlanningFixture.CreateNormalRequest();

            // Act
            var result = await client.PlanAsync(
                request,
                "stage2a-real-integration",
                CancellationToken.None);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(3, result.Days.Count);
            Assert.Empty(result.Warnings);
        }

        [Fact]
        public async Task PlanAsync_ReturnsPartialWarning_FromRealFastApi()
        {
            // Arrange
            var httpClient = new HttpClient
            {
                BaseAddress = new Uri("http://127.0.0.1:8000/"),
                Timeout = TimeSpan.FromSeconds(10)
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator,
                NullLogger<FastApiPlanningClient>.Instance);

            var request = Stage2APlanningFixture.CreatePartialRequest();

            // Act
            var result = await client.PlanAsync(
                request,
                "stage2a-real-partial",
                CancellationToken.None);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(3, result.Days.Count);

            Assert.Single(result.Warnings);
            Assert.Equal(
                "PARTIAL_ITINERARY",
                result.Warnings[0].Code);
        }

        [Fact]
        public async Task PlanAsync_ReturnsEmptyWarning_FromRealFastApi()
        {
            // Arrange
            var httpClient = new HttpClient
            {
                BaseAddress = new Uri("http://127.0.0.1:8000/"),
                Timeout = TimeSpan.FromSeconds(10)
            };

            var validator = new PlanningResultValidator();

            var client = new FastApiPlanningClient(
                httpClient,
                validator,
                NullLogger<FastApiPlanningClient>.Instance);

            var request = Stage2APlanningFixture.CreateEmptyRequest();

            // Act
            var result = await client.PlanAsync(
                request,
                "stage2a-real-empty",
                CancellationToken.None);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(3, result.Days.Count);

            Assert.Single(result.Warnings);
            Assert.Equal(
                "NO_PLACES_AVAILABLE",
                result.Warnings[0].Code);
        }
    }
}