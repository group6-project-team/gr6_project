using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Services.Interfaces;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.DTOs.Responses;

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

            SavedTripResponse result;
            try
            {
                result = await _savedTripService.SaveAsync(userId, request);
            }
            catch (SavedTripQuotaExceededException)
            {
                return Conflict(new { message = "Saved trips limit reached (50)." });
            }

            return CreatedAtAction(
                nameof(GetById),
                new { id = result.Id },
                result);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(
      [FromQuery] int page = 1,
      [FromQuery] int pageSize = 20)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (page < 1 || pageSize < 1 || pageSize > 50 || ((long)page - 1) * pageSize > int.MaxValue)
                return BadRequest(new { message = "Invalid pagination parameters." });

            var result = await _savedTripService.GetAllAsync(
                userId,
                page,
                pageSize);

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
