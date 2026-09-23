using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Controllers
{
    [ApiController]
    [Route("api/saved-trips")]
    [Authorize]
    public class SavedTripsController : ControllerBase
    {
        private readonly ISavedTripService _savedTripService;

        public SavedTripsController(ISavedTripService savedTripService)
        {
            _savedTripService = savedTripService;
        }

        [RequestSizeLimit(1_048_576)]
        [HttpPost]
        public async Task<IActionResult> SaveTrip(SaveTripRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (request.Trip.ValueKind is JsonValueKind.Undefined or JsonValueKind.Null)
            {
                return BadRequest(new
                {
                    message = "Trip snapshot is required."
                });
            }

            var tripJson = request.Trip.GetRawText();

            if (System.Text.Encoding.UTF8.GetByteCount(tripJson) > 1_048_576)
            {
                return BadRequest(new
                {
                    message = "Trip snapshot is too large."
                });
            }

            var result = await _savedTripService.SaveAsync(userId, request);

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                result);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var result = await _savedTripService.GetAllAsync(userId);

            return Ok(result);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var result = await _savedTripService.GetByIdAsync(id, userId);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            var deleted = await _savedTripService.DeleteAsync(id, userId);

            if (!deleted)
                return NotFound();

            return NoContent();
        }
    }
}