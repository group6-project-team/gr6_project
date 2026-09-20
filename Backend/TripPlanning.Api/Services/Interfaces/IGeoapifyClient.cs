using System.Text.Json;

namespace TripPlanning.Api.Services.Interfaces
{
    public interface IGeoapifyClient
    {
        Task<JsonDocument> GetPlacesAsync(
            string destinationId,
            CancellationToken cancellationToken);
    }
}