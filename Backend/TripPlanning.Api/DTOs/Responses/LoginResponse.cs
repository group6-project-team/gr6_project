namespace TripPlanning.Api.DTOs.Responses
{
    public class LoginResponse
    {
        public bool Success { get; set; }

        public string? Message { get; set; }

        public string? Token { get; set; }

        public DateTime? ExpiresAt { get; set; }

        public string? UserId { get; set; }

        public string? Name { get; set; }

        public string? Email { get; set; }
    }
}