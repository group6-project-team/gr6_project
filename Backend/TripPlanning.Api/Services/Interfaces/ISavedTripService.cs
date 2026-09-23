using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Services.Interfaces
{
    public interface ISavedTripService
    {
        Task<SavedTripResponse> SaveAsync(string userId, SaveTripRequest request);

        Task<List<SavedTripResponse>> GetAllAsync( string userId, int page, int pageSize);

        Task<SavedTripResponse?> GetByIdAsync(int id, string userId);

        Task<bool> DeleteAsync(int id, string userId);
    }
}