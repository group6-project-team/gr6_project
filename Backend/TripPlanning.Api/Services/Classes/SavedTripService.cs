using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Models;
using TripPlanning.Api.Repositories.Interfaces;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class SavedTripService : ISavedTripService
    {
        private readonly ISavedTripRepository _savedTripRepository;

        public SavedTripService(ISavedTripRepository savedTripRepository)
        {
            _savedTripRepository = savedTripRepository;
        }

        public async Task<SavedTripResponse> SaveAsync(
            string userId,
            SaveTripRequest request)
        {
            var savedTrip = new SavedTrip
            {
                UserId = userId,
                DestinationId = request.DestinationId,
                RequestedDays = request.RequestedDays,
                SnapshotJson = request.Trip.GetRawText(),
                CreatedAt = DateTime.UtcNow
            };

            await _savedTripRepository.AddAsync(savedTrip);
            await _savedTripRepository.SaveChangesAsync();

            return MapToResponse(savedTrip);
        }

        public async Task<List<SavedTripResponse>> GetAllAsync(string userId, int page, int pageSize)
        {
            var skip = (page - 1) * pageSize;

            var savedTrips =
                await _savedTripRepository.GetByUserIdAsync(
                    userId,
                    skip,
                    pageSize);

            return savedTrips
                .Select(MapToResponse)
                .ToList();
        }

        public async Task<SavedTripResponse?> GetByIdAsync(
            int id,
            string userId)
        {
            var savedTrip =
                await _savedTripRepository.GetByIdAndUserIdAsync(id, userId);

            if (savedTrip == null)
                return null;

            return MapToResponse(savedTrip);
        }

        public async Task<bool> DeleteAsync(
            int id,
            string userId)
        {
            var savedTrip =
                await _savedTripRepository.GetByIdAndUserIdAsync(id, userId);

            if (savedTrip == null)
                return false;

            _savedTripRepository.Remove(savedTrip);
            await _savedTripRepository.SaveChangesAsync();

            return true;
        }

        private static SavedTripResponse MapToResponse(SavedTrip savedTrip)
        {
            using var document =
                JsonDocument.Parse(savedTrip.SnapshotJson);

            return new SavedTripResponse
            {
                Id = savedTrip.Id,
                DestinationId = savedTrip.DestinationId,
                RequestedDays = savedTrip.RequestedDays,
                Trip = document.RootElement.Clone(),
                CreatedAt = savedTrip.CreatedAt
            };
        }
    }
}