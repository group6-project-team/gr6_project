using FluentValidation;
using TripPlanning.Api.Data;
using TripPlanning.Api.DTOs.Requests;

namespace TripPlanning.Api.Validators
{
    public class TripPlanPreviewRequestValidator
        : AbstractValidator<TripPlanPreviewRequest>
    {
        public TripPlanPreviewRequestValidator()
        {
            RuleFor(x => x.DestinationId)
                .NotEmpty()
                .WithMessage("Destination is required.")
                .Must(destinationId =>
                    destinationId is null ||
                    FakeTripData.SupportedDestinations.Contains(destinationId))
                .WithMessage("The selected destination is not supported.");

            RuleFor(x => x.Days)
                .NotNull()
                .WithMessage("Days is required.")
                .Must(days =>
                    days is null ||
                    (days >= 1 && days <= 14))
                .WithMessage("Days must be between 1 and 14.");

            RuleFor(x => x.Interests)
                .Must(interests =>
                    interests is null ||
                    interests.All(interest =>
                        !string.IsNullOrWhiteSpace(interest) &&
                        FakeTripData.SupportedInterests.Contains(interest)))
                .WithMessage("One or more interests are not supported.");
        }
    }
}