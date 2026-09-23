using TripPlanning.Api.Models;

namespace TripPlanning.Api.Repositories.Interfaces
{
    public interface ISavedTripRepository
    {
        Task<SavedTrip> AddAsync(SavedTrip savedTrip);

     Task<List<SavedTrip>> GetByUserIdAsync(string userId, int skip, int take);
        Task<SavedTrip?> GetByIdAndUserIdAsync(int id, string userId);

        void Remove(SavedTrip savedTrip);

        Task SaveChangesAsync();
    }
}