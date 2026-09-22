using Microsoft.AspNetCore.Identity;

namespace TripPlanning.Api.Models
{
    public class ApplicationUser : IdentityUser
    {
        public string Name { get; set; } = string.Empty;
    }
}