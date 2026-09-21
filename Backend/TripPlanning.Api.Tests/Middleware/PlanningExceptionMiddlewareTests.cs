using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using System.Net;
using System.Text.Json;
using TripPlanning.Api.Exceptions;
using TripPlanning.Api.Middleware;
using TripPlanning.Api.Services.Classes;

namespace TripPlanning.Api.Tests.Middleware
{
    public class PlanningExceptionMiddlewareTests
    {
        [Fact]
        public async Task InvokeAsync_Returns503_WhenPlanningServiceIsUnavailable()
        {
            // Arrange
            var context = new DefaultHttpContext();
            context.Response.Body = new MemoryStream();

            RequestDelegate next = _ =>
                throw new PlanningServiceUnavailableException(
                    "Planning service is unavailable.");

            var middleware = new PlanningExceptionMiddleware(next);

            // Act
            await middleware.InvokeAsync(context);

            // Assert
            Assert.Equal(
                (int)HttpStatusCode.ServiceUnavailable,
                context.Response.StatusCode);

            context.Response.Body.Position = 0;

            using var document =
                await JsonDocument.ParseAsync(context.Response.Body);

            var root = document.RootElement;

            Assert.Equal(
                "PLANNING_SERVICE_UNAVAILABLE",
                root.GetProperty("code").GetString());

            Assert.Equal(
                "The planning service is currently unavailable.",
                root.GetProperty("message").GetString());
        }

        [Fact]
        public async Task InvokeAsync_Returns500_WhenPlanningFails()
        {
            // Arrange
            var context = new DefaultHttpContext();
            context.Response.Body = new MemoryStream();

            RequestDelegate next = _ =>
                throw new PlanningFailedException(
                    "Planning service returned an invalid result.");

            var middleware = new PlanningExceptionMiddleware(next);

            // Act
            await middleware.InvokeAsync(context);

            // Assert
            Assert.Equal(
                (int)HttpStatusCode.InternalServerError,
                context.Response.StatusCode);

            context.Response.Body.Position = 0;

            using var document =
                await JsonDocument.ParseAsync(context.Response.Body);

            var root = document.RootElement;

            Assert.Equal(
                "PLANNING_FAILED",
                root.GetProperty("code").GetString());

            Assert.Equal(
                "The planning service returned an invalid result.",
                root.GetProperty("message").GetString());
        }

        [Fact]
        public async Task InvokeAsync_ReturnsControlled503_ForGeoapifyHttpFailure()
        {
            var client = new GeoapifyClient(
                new HttpClient(new FailingGeoapifyHandler())
                {
                    BaseAddress = new Uri("https://api.geoapify.com/")
                },
                new ConfigurationManager
                {
                    ["GEOAPIFY_API_KEY"] = "test-key"
                },
                NullLogger<GeoapifyClient>.Instance);
            var context = new DefaultHttpContext();
            context.Response.Body = new MemoryStream();
            RequestDelegate next = async _ =>
            {
                using var document = await client.GetPlacesAsync(
                    "istanbul",
                    CancellationToken.None);
            };
            var middleware = new PlanningExceptionMiddleware(next);

            await middleware.InvokeAsync(context);

            Assert.Equal(
                (int)HttpStatusCode.ServiceUnavailable,
                context.Response.StatusCode);
            context.Response.Body.Position = 0;
            using var document =
                await JsonDocument.ParseAsync(context.Response.Body);
            Assert.Equal(
                "PLANNING_SERVICE_UNAVAILABLE",
                document.RootElement.GetProperty("code").GetString());
        }

        private sealed class FailingGeoapifyHandler : HttpMessageHandler
        {
            protected override Task<HttpResponseMessage> SendAsync(
                HttpRequestMessage request,
                CancellationToken cancellationToken)
            {
                return Task.FromResult(
                    new HttpResponseMessage(HttpStatusCode.BadGateway));
            }
        }
    }
}
