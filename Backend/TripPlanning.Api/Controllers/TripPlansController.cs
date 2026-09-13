using Microsoft.AspNetCore.Mvc;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Controllers
{
    [ApiController]
    [Route("trip-plans")]
    public class TripPlansController : ControllerBase
    {
        private readonly IFakeTripPreviewService _tripPreviewService;

        public TripPlansController(IFakeTripPreviewService tripPreviewService)
        {
            _tripPreviewService = tripPreviewService;
        }

        [HttpPost("preview")]
        [ProducesResponseType(typeof(TripPlanPreviewResponse), StatusCodes.Status200OK)]
        public ActionResult<TripPlanPreviewResponse> Preview(
    [FromBody] TripPlanPreviewRequest request)
        {
            var result = _tripPreviewService.GeneratePreview(request);

            return Ok(result);
        }
    }
}