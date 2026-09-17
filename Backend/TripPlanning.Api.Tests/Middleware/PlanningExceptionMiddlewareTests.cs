using Microsoft.AspNetCore.Http;
using System.Net;
using System.Text.Json;
using TripPlanning.Api.Exceptions;
using TripPlanning.Api.Middleware;

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
    }
}