using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Exceptions;
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

            if (Encoding.UTF8.GetByteCount(tripJson) > 1_048_576)
            {
                return BadRequest(new
                {
                    message = "Trip snapshot is too large."
                });
            }

            try
            {
                var result = await _savedTripService.SaveAsync(userId, request);

                return CreatedAtAction(
                    nameof(GetById),
                    new { id = result.Id },
                    result);
            }
            catch (SavedTripQuotaExceededException ex)
            {
                return Conflict(new
                {
                    message = ex.Message
                });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(
      [FromQuery] int page = 1,
      [FromQuery] int pageSize = 20)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrWhiteSpace(userId))
                return Unauthorized();

            if (page < 1)
            {
                return BadRequest(new
                {
                    message = "Page must be greater than or equal to 1."
                });
            }

            if (pageSize < 1 || pageSize > 50)
            {
                return BadRequest(new
                {
                    message = "Page size must be between 1 and 50."
                });
            }

            var offset = ((long)page - 1) * pageSize;

            if (offset > int.MaxValue)
            {
                return BadRequest(new
                {
                    message = "Page value is too large."
                });
            }

            var skip = (int)offset;

            var result = await _savedTripService.GetAllAsync(
                userId,
                skip,
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