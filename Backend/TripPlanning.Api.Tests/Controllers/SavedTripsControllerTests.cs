using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TripPlanning.Api.Controllers;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Tests.Controllers;

public class SavedTripsControllerTests
{
    [Fact]
    public async Task SaveTrip_WhenQuotaIsExceeded_ReturnsConflict()
    {
        var service = new StubService { QuotaExceeded = true };
        var controller = CreateController(service);
        using var document = JsonDocument.Parse("{}");

        var response = await controller.SaveTrip(new SaveTripRequest { Trip = document.RootElement });

        Assert.IsType<ConflictObjectResult>(response);
        Assert.Equal(1, service.SaveCalls);
    }

    [Theory]
    [InlineData(0, 20)]
    [InlineData(1, 51)]
    [InlineData(int.MaxValue, 20)]
    public async Task GetAll_InvalidOrOverflowingPage_ReturnsBadRequestWithoutQuery(int page, int pageSize)
    {
        var service = new StubService();
        var controller = CreateController(service);

        var response = await controller.GetAll(page, pageSize);

        Assert.IsType<BadRequestObjectResult>(response);
        Assert.Equal(0, service.ListCalls);
    }

    private static SavedTripsController CreateController(ISavedTripService service) => new(service)
    {
        ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(
                    [new Claim(ClaimTypes.NameIdentifier, "test-user")], "test"))
            }
        }
    };

    private sealed class StubService : ISavedTripService
    {
        public bool QuotaExceeded { get; set; }
        public int SaveCalls { get; private set; }
        public int ListCalls { get; private set; }

        public Task<SavedTripResponse> SaveAsync(string userId, SaveTripRequest request)
        {
            SaveCalls++;
            if (QuotaExceeded) throw new SavedTripQuotaExceededException();
            return Task.FromResult(new SavedTripResponse());
        }

        public Task<List<SavedTripResponse>> GetAllAsync(string userId, int page, int pageSize)
        {
            ListCalls++;
            return Task.FromResult(new List<SavedTripResponse>());
        }

        public Task<SavedTripResponse?> GetByIdAsync(int id, string userId) => Task.FromResult<SavedTripResponse?>(null);
        public Task<bool> DeleteAsync(int id, string userId) => Task.FromResult(false);
    }
}
