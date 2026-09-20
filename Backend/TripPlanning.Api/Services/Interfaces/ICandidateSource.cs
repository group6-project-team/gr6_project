using TripPlanning.Api.DTOs.Requests;

namespace TripPlanning.Api.Services.Interfaces
{
    public interface ICandidateSource
    {
        Task<List<PlaceCandidateRequest>> GetCandidatesAsync(
            string destinationId,
            CancellationToken cancellationToken);
    }
}