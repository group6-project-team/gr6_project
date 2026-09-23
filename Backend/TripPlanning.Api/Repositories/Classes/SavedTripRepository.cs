using Microsoft.EntityFrameworkCore;
using TripPlanning.Api.Data;
using TripPlanning.Api.Models;
using TripPlanning.Api.Repositories.Interfaces;

namespace TripPlanning.Api.Repositories.Classes
{
    public class SavedTripRepository : ISavedTripRepository
    {
        private readonly AppDbContext _context;

        public SavedTripRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<SavedTrip> AddAsync(SavedTrip savedTrip)
        {
            await _context.SavedTrips.AddAsync(savedTrip);
            return savedTrip;
        }

        public async Task<List<SavedTrip>> GetByUserIdAsync(string userId, int skip, int take)
        {
            return await _context.SavedTrips
                .AsNoTracking()
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.CreatedAt)
                .Skip(skip)
                .Take(take)
                .ToListAsync();
        }

        public async Task<SavedTrip?> GetByIdAndUserIdAsync(int id, string userId)
        {
            return await _context.SavedTrips
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId);
        }

        public void Remove(SavedTrip savedTrip)
        {
            _context.SavedTrips.Remove(savedTrip);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}