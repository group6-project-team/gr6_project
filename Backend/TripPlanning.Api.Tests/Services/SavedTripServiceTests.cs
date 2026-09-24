using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Exceptions;
using TripPlanning.Api.Models;
using TripPlanning.Api.Repositories.Interfaces;
using TripPlanning.Api.Services.Classes;

namespace TripPlanning.Api.Tests.Services
{
    public class SavedTripServiceTests
    {
        [Fact]
        public async Task SaveAsync_WhenUserHas49Trips_Allows50thTrip()
        {
            // Arrange
            var repository = new FakeSavedTripRepository(initialCount: 49);
            var service = new SavedTripService(repository);

            var request = CreateRequest();

            // Act
            var result = await service.SaveAsync("user-1", request);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(50, repository.Count);
        }

        [Fact]
        public async Task SaveAsync_WhenUserHas50Trips_Rejects51stTrip()
        {
            // Arrange
            var repository = new FakeSavedTripRepository(initialCount: 50);
            var service = new SavedTripService(repository);

            var request = CreateRequest();

            // Act
            var exception = await Assert.ThrowsAsync<SavedTripQuotaExceededException>(
                () => service.SaveAsync("user-1", request));

            // Assert
            Assert.Equal("Saved trips limit reached.", exception.Message);
            Assert.Equal(50, repository.Count);
        }

        private static SaveTripRequest CreateRequest()
        {
            using var document = JsonDocument.Parse(
                """
                {
                  "destinationId": "istanbul",
                  "requestedDays": 1,
                  "days": [],
                  "warnings": []
                }
                """);

            return new SaveTripRequest
            {
                DestinationId = "istanbul",
                RequestedDays = 1,
                Trip = document.RootElement.Clone()
            };
        }

        private sealed class FakeSavedTripRepository : ISavedTripRepository
        {
            private readonly List<SavedTrip> _savedTrips;

            public int Count => _savedTrips.Count;

            public FakeSavedTripRepository(int initialCount)
            {
                _savedTrips = Enumerable.Range(1, initialCount)
                    .Select(i => new SavedTrip
                    {
                        Id = i,
                        UserId = "user-1",
                        DestinationId = "istanbul",
                        RequestedDays = 1,
                        SnapshotJson = "{}",
                        CreatedAt = DateTime.UtcNow
                    })
                    .ToList();
            }

            public Task<bool> TryAddWithinQuotaAsync(
                SavedTrip savedTrip,
                int maxTrips)
            {
                var currentCount =
                    _savedTrips.Count(x => x.UserId == savedTrip.UserId);

                if (currentCount >= maxTrips)
                    return Task.FromResult(false);

                _savedTrips.Add(savedTrip);

                return Task.FromResult(true);
            }

            public Task<SavedTrip> AddAsync(SavedTrip savedTrip)
            {
                _savedTrips.Add(savedTrip);
                return Task.FromResult(savedTrip);
            }

            public Task<List<SavedTrip>> GetByUserIdAsync(
                string userId,
                int skip,
                int take)
            {
                return Task.FromResult(
                    _savedTrips
                        .Where(x => x.UserId == userId)
                        .Skip(skip)
                        .Take(take)
                        .ToList());
            }

            public Task<SavedTrip?> GetByIdAndUserIdAsync(
                int id,
                string userId)
            {
                return Task.FromResult(
                    _savedTrips.FirstOrDefault(
                        x => x.Id == id && x.UserId == userId));
            }

            public void Remove(SavedTrip savedTrip)
            {
                _savedTrips.Remove(savedTrip);
            }

            public Task SaveChangesAsync()
            {
                return Task.CompletedTask;
            }
        }
    }
}