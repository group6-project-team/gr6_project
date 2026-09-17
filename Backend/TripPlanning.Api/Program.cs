
using FluentValidation;
using FluentValidation.AspNetCore;
using TripPlanning.Api.Middleware;
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

            builder.Services.AddFluentValidationAutoValidation();

            builder.Services.AddValidatorsFromAssemblyContaining<TripPlanPreviewRequestValidator>();

            builder.Services.AddScoped<IFakeTripPreviewService, FakeTripPreviewService>();
            builder.Services.AddScoped<IPlanningResultValidator, PlanningResultValidator>();
            builder.Services.AddScoped<IPlanningService, PlanningService>();
            builder.Services.AddScoped<IRealTripPreviewService, RealTripPreviewService>();
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

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
