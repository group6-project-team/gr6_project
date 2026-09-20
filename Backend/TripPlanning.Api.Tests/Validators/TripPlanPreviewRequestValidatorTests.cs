using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Validators;

namespace TripPlanning.Api.Tests.Validators
{
    public class TripPlanPreviewRequestValidatorTests
    {
        [Fact]
        public async Task ValidateAsync_AcceptsLandmarkInterest()
        {
            var validator = new TripPlanPreviewRequestValidator();

            var request = new TripPlanPreviewRequest
            {
                DestinationId = "istanbul",
                Days = 3,
                Interests = new List<string>
                {
                    "landmark"
                }
            };

            var result = await validator.ValidateAsync(request);

            Assert.True(result.IsValid);
        }
    }
}