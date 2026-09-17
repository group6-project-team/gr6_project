using System.Net;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Exceptions;

namespace TripPlanning.Api.Middleware
{
    public class PlanningExceptionMiddleware
    {
        private readonly RequestDelegate _next;

        public PlanningExceptionMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (PlanningServiceUnavailableException)
            {
                await WriteErrorResponseAsync(
                    context,
                    HttpStatusCode.ServiceUnavailable,
                    "PLANNING_SERVICE_UNAVAILABLE",
                    "The planning service is currently unavailable.");
            }
            catch (PlanningFailedException)
            {
                await WriteErrorResponseAsync(
                    context,
                    HttpStatusCode.InternalServerError,
                    "PLANNING_FAILED",
                    "The planning service returned an invalid result.");
            }
        }

        private static async Task WriteErrorResponseAsync(
            HttpContext context,
            HttpStatusCode statusCode,
            string code,
            string message)
        {
            context.Response.StatusCode = (int)statusCode;

            var response = new PlanningErrorResponse
            {
                Code = code,
                Message = message
            };

            await context.Response.WriteAsJsonAsync(response);
        }
    }
}
