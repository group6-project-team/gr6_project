using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Services.Interfaces
{
    public interface IFakeTripPreviewService
    {
        TripPlanPreviewResponse GeneratePreview(TripPlanPreviewRequest request);
    }
}