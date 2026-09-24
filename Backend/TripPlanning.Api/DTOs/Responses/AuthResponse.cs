namespace TripPlanning.Api.DTOs.Responses
{
    public class AuthResponse
    {
        public bool Success { get; set; }

        public string? Message { get; set; }

        public string? UserId { get; set; }

        public string? Name { get; set; }

        public string? Email { get; set; }

        public List<string> Errors { get; set; } = new();
    }
}