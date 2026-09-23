using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Models;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;
        public AuthService(
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration)
        {
            _userManager = userManager;
            _configuration = configuration;
        }

        public async Task<AuthResponse> RegisterAsync(
            RegisterRequest request)
        {
            var existingUser = await _userManager.FindByEmailAsync(
                request.Email);

            if (existingUser is not null)
            {
                return new AuthResponse
                {
                    Success = false,
                    Message = "Email is already registered."
                };
            }

            var user = new ApplicationUser
            {
                Name = request.Name.Trim(),
                Email = request.Email.Trim(),
                UserName = request.Email.Trim()
            };

            var result = await _userManager.CreateAsync(
                user,
                request.Password);

            if (!result.Succeeded)
            {
                return new AuthResponse
                {
                    Success = false,
                    Message = "Registration failed.",
                    Errors = result.Errors
                        .Select(error => error.Description)
                        .ToList()
                };
            }

            return new AuthResponse
            {
                Success = true,
                Message = "User registered successfully.",
                UserId = user.Id,
                Name = user.Name,
                Email = user.Email
            };
        }

        public async Task<LoginResponse> LoginAsync(LoginRequest request)
        {
            var user = await _userManager.FindByEmailAsync(
                request.Email.Trim());

            if (user is null)
            {
                return new LoginResponse
                {
                    Success = false,
                    Message = "Invalid email or password."
                };
            }

            var passwordValid = await _userManager.CheckPasswordAsync(
                user,
                request.Password);

            if (!passwordValid)
            {
                return new LoginResponse
                {
                    Success = false,
                    Message = "Invalid email or password."
                };
            }

            var jwtKey = _configuration["Jwt:Key"];
            var issuer = _configuration["Jwt:Issuer"];
            var audience = _configuration["Jwt:Audience"];

            var expiresMinutes =
                _configuration.GetValue<int>("Jwt:ExpiresMinutes");

            var expiresAt = DateTime.UtcNow.AddMinutes(
                expiresMinutes);

            var claims = new List<Claim>
    {
        new(
            JwtRegisteredClaimNames.Sub,
            user.Id),

        new(
            JwtRegisteredClaimNames.Email,
            user.Email ?? string.Empty),

        new(
            ClaimTypes.NameIdentifier,
            user.Id),

        new(
            ClaimTypes.Name,
            user.Name)
    };

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey!));

            var credentials = new SigningCredentials(
                key,
                SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: expiresAt,
                signingCredentials: credentials);

            var tokenValue =
                new JwtSecurityTokenHandler()
                    .WriteToken(token);

            return new LoginResponse
            {
                Success = true,
                Message = "Login successful.",
                Token = tokenValue,
                ExpiresAt = expiresAt,
                UserId = user.Id,
                Name = user.Name,
                Email = user.Email
            };
        }
    }
}