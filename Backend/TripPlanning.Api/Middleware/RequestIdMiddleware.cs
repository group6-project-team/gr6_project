namespace TripPlanning.Api.Middleware
{
    public class RequestIdMiddleware
    {
        private const string RequestIdHeader = "X-Request-ID";

        private readonly RequestDelegate _next;

        public RequestIdMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var requestId = context.Request.Headers[RequestIdHeader].FirstOrDefault();

            if (string.IsNullOrWhiteSpace(requestId))
            {
                requestId = Guid.NewGuid().ToString("N");
            }

            context.Items[RequestIdHeader] = requestId;

            context.Response.Headers[RequestIdHeader] = requestId;

            await _next(context);
        }
    }
}