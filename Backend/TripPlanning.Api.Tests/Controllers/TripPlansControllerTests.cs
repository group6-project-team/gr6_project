using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TripPlanning.Api.Controllers;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Tests.Controllers
{
    public class TripPlansControllerTests
    {
        private class StubRealTripPreviewService : IRealTripPreviewService
        {
            public TripPlanPreviewRequest? CapturedRequest { get; private set; }

            public string? CapturedRequestId { get; private set; }

            public CancellationToken CapturedCancellationToken { get; private set; }

            public Task<TripPlanPreviewResponse> GeneratePreviewAsync(
                TripPlanPreviewRequest request,
                string requestId,
                CancellationToken cancellationToken)
            {
                CapturedRequest = request;
                CapturedRequestId = requestId;
                CapturedCancellationToken = cancellationToken;

                return Task.FromResult(
                    new TripPlanPreviewResponse
                    {
                        DestinationId = request.DestinationId!,
                        Days = new List<TripDayResponse>
                        {
                            new()
                            {
                                DayNumber = 1,
                                Places = new List<PlaceResponse>()
                            }
                        },
                        Warnings = new List<PlanningWarningResponse>()
                    });
            }
        }

        [Fact]
        public async Task Preview_UsesRealTripPreviewService_AndReturnsOk()
        {
            // Arrange
            var service = new StubRealTripPreviewService();

            var controller = new TripPlansController(service);

            var httpContext = new DefaultHttpContext();

            httpContext.Items["X-Request-ID"] =
                "public-stage2a-test";

            controller.ControllerContext = new ControllerContext
            {
                HttpContext = httpContext
            };

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 1,
                Interests = new List<string>()
            };

            using var cancellationTokenSource =
                new CancellationTokenSource();

            // Act
            var actionResult = await controller.Preview(
                request,
                cancellationTokenSource.Token);

            // Assert
            var okResult =
                Assert.IsType<OkObjectResult>(
                    actionResult.Result);

            var response =
                Assert.IsType<TripPlanPreviewResponse>(
                    okResult.Value);

            Assert.Equal(
                StatusCodes.Status200OK,
                okResult.StatusCode);

            Assert.Same(
                request,
                service.CapturedRequest);

            Assert.Equal(
                "public-stage2a-test",
                service.CapturedRequestId);

            Assert.Equal(
                cancellationTokenSource.Token,
                service.CapturedCancellationToken);

            Assert.Equal(
                "istanbul",
                response.DestinationId);
        }
    }
}