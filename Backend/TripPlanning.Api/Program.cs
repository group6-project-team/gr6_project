
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using TripPlanning.Api.Data;
using TripPlanning.Api.Middleware;
using TripPlanning.Api.Models;
using TripPlanning.Api.Services.Classes;
using TripPlanning.Api.Services.Interfaces;
using TripPlanning.Api.Validators;

namespace TripPlanning.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();

            builder.Services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlServer(
                    builder.Configuration.GetConnectionString("DefaultConnection"));
            });

            builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
                .AddEntityFrameworkStores<AppDbContext>()
                .AddDefaultTokenProviders();

            builder.Services
                .AddAuthentication(options =>
                {
                    options.DefaultAuthenticateScheme =
                        JwtBearerDefaults.AuthenticationScheme;

                    options.DefaultChallengeScheme =
                        JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    var jwtKey = builder.Configuration["Jwt:Key"];
                    var issuer = builder.Configuration["Jwt:Issuer"];
                    var audience = builder.Configuration["Jwt:Audience"];

                    options.TokenValidationParameters =
                        new TokenValidationParameters
                        {
                            ValidateIssuer = true,
                            ValidateAudience = true,
                            ValidateLifetime = true,
                            ValidateIssuerSigningKey = true,

                            ValidIssuer = issuer,
                            ValidAudience = audience,

                            IssuerSigningKey =
                                new SymmetricSecurityKey(
                                    Encoding.UTF8.GetBytes(jwtKey!))
                        };
                });

            builder.Services.AddFluentValidationAutoValidation();

            builder.Services.AddValidatorsFromAssemblyContaining<TripPlanPreviewRequestValidator>();

            builder.Services.AddScoped<IFakeTripPreviewService, FakeTripPreviewService>();
            builder.Services.AddScoped<IPlanningResultValidator, PlanningResultValidator>();
            builder.Services.AddScoped<IPlanningService, PlanningService>();
            builder.Services.AddScoped<IRealTripPreviewService, RealTripPreviewService>();
            builder.Services.AddScoped<IAuthService, AuthService>();

            var candidateSourceMode =
                builder.Configuration["CANDIDATE_SOURCE_MODE"]
                ?? builder.Configuration["CandidateSource:Mode"];

            if (string.Equals(
                candidateSourceMode,
                "Fixture",
                StringComparison.OrdinalIgnoreCase))
            {
                builder.Services.AddScoped<ICandidateSource, FixtureCandidateSource>();
            }
            else if (string.Equals(
                candidateSourceMode,
                "Geoapify",
                StringComparison.OrdinalIgnoreCase))
            {
                builder.Services.AddScoped<ICandidateSource, GeoapifyCandidateSource>();
            }
            else
            {
                throw new InvalidOperationException(
                    $"Unsupported or missing candidate source mode: '{candidateSourceMode}'. " +
                    "Configure CANDIDATE_SOURCE_MODE explicitly.");
            }
            builder.Services.AddHttpClient<IFastApiPlanningClient, FastApiPlanningClient>((serviceProvider, client) =>
            {
                var configuration = serviceProvider.GetRequiredService<IConfiguration>();

                var baseUrl =
                    configuration["AI_SERVICE_BASE_URL"]
                    ?? configuration["AIService:BaseUrl"];

                var timeoutValue =
                    configuration["AI_SERVICE_TIMEOUT"];

                var timeoutSeconds = int.TryParse(timeoutValue, out var configuredTimeout)
                    ? configuredTimeout
                    : configuration.GetValue<int>("AIService:TimeoutSeconds");

                client.BaseAddress = new Uri(baseUrl!);
                client.Timeout = TimeSpan.FromSeconds(timeoutSeconds);
            });

            builder.Services
                .AddHttpClient<IGeoapifyClient, GeoapifyClient>((serviceProvider, client) =>
                {
                    var configuration = serviceProvider.GetRequiredService<IConfiguration>();

                    var baseUrl =
                        configuration["GEOAPIFY_BASE_URL"]
                        ?? configuration["Geoapify:BaseUrl"];

                    var timeoutValue =
                        configuration["GEOAPIFY_TIMEOUT"];

                    var timeoutSeconds = int.TryParse(timeoutValue, out var configuredTimeout)
                        ? configuredTimeout
                        : configuration.GetValue<int>("Geoapify:TimeoutSeconds");

                    client.BaseAddress = new Uri(baseUrl!);
                    client.Timeout = TimeSpan.FromSeconds(timeoutSeconds);
                })
                // Geoapify requires the API key in the query string. Disable
                // HttpClientFactory URI logging for this client; the client
                // emits its own sanitized diagnostics.
                .RemoveAllLoggers();

            // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
            builder.Services.AddOpenApi();

            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            var app = builder.Build();

            app.UseMiddleware<RequestIdMiddleware>();
            app.UseMiddleware<PlanningExceptionMiddleware>();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}
