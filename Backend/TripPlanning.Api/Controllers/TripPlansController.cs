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
        private readonly IRealTripPreviewService _tripPreviewService;

        public TripPlansController(
            IRealTripPreviewService tripPreviewService)
        {
            _tripPreviewService = tripPreviewService;
        }

        [HttpPost("preview")]
        [ProducesResponseType(
            typeof(TripPlanPreviewResponse),
            StatusCodes.Status200OK)]
        [ProducesResponseType(
            typeof(PlanningErrorResponse),
            StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(
            typeof(PlanningErrorResponse),
            StatusCodes.Status503ServiceUnavailable)]
        public async Task<ActionResult<TripPlanPreviewResponse>> Preview(
            [FromBody] TripPlanPreviewRequest request,
            CancellationToken cancellationToken)
        {
            var requestId =
                HttpContext.Items["X-Request-ID"]?.ToString()
                ?? HttpContext.TraceIdentifier;

            var result = await _tripPreviewService.GeneratePreviewAsync(
                request,
                requestId,
                cancellationToken);

            return Ok(result);
        }
    }
}