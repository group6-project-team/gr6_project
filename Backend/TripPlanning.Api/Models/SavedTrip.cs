namespace TripPlanning.Api.Models
{
    public class SavedTrip
    {
        public int Id { get; set; }

        public string UserId { get; set; } = string.Empty;

        public string DestinationId { get; set; } = string.Empty;

        public int RequestedDays { get; set; }

        public string SnapshotJson { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ApplicationUser User { get; set; } = null!;
    }
}