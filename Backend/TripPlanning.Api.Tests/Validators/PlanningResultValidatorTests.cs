using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.DTOs.Responses;
using TripPlanning.Api.Validators;

namespace TripPlanning.Api.Tests.Validators
{
    public class PlanningResultValidatorTests
    {
        [Fact]
        public void IsValid_ReturnsTrue_WhenPlanningResultIsValid()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
                {
                    new() { Id = "p1" },
                    new() { Id = "p2" },
                    new() { Id = "p3" },
                    new() { Id = "p4" },
                    new() { Id = "p5" },
                    new() { Id = "p6" },
                    new() { Id = "p7" },
                    new() { Id = "p8" }
                }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
                {
                    new()
                    {
                        Day = 1,
                        PlaceIds = new List<string> { "p1", "p2", "p3" }
                    },
                    new()
                    {
                        Day = 2,
                        PlaceIds = new List<string> { "p4", "p5", "p6" }
                    },
                    new()
                    {
                        Day = 3,
                        PlaceIds = new List<string> { "p7", "p8" }
                    }
                },
                Warnings = new List<FastApiPlanningWarningResponse>()
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.True(result);
        }

        [Fact]
        public void IsValid_ReturnsFalse_WhenSelectedIdIsNotInCandidates()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 2,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new() { Id = "p1" },
            new() { Id = "p2" },
            new() { Id = "p3" },
            new() { Id = "p4" }
        }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string> { "p1", "p2" }
            },
            new()
            {
                Day = 2,
                PlaceIds = new List<string> { "p3", "p999" }
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>()
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public void IsValid_ReturnsFalse_WhenSelectedIdsContainDuplicates()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 2,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new() { Id = "p1" },
            new() { Id = "p2" },
            new() { Id = "p3" },
            new() { Id = "p4" }
        }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string> { "p1", "p2" }
            },
            new()
            {
                Day = 2,
                PlaceIds = new List<string> { "p3", "p3" }
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>()
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public void IsValid_ReturnsFalse_WhenDayCapacitiesAreNotBalanced()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new() { Id = "p1" },
            new() { Id = "p2" },
            new() { Id = "p3" },
            new() { Id = "p4" },
            new() { Id = "p5" },
            new() { Id = "p6" },
            new() { Id = "p7" },
            new() { Id = "p8" }
        }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string> { "p1", "p2" }
            },
            new()
            {
                Day = 2,
                PlaceIds = new List<string> { "p3", "p4", "p5" }
            },
            new()
            {
                Day = 3,
                PlaceIds = new List<string> { "p6", "p7", "p8" }
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>()
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public void IsValid_ReturnsFalse_WhenARequestedDayIsMissing()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new() { Id = "p1" },
            new() { Id = "p2" },
            new() { Id = "p3" },
            new() { Id = "p4" },
            new() { Id = "p5" },
            new() { Id = "p6" }
        }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string> { "p1", "p2" }
            },
            new()
            {
                Day = 3,
                PlaceIds = new List<string> { "p3", "p4" }
            },
            new()
            {
                Day = 4,
                PlaceIds = new List<string> { "p5", "p6" }
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>()
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public void IsValid_ReturnsFalse_WhenWarningSemanticsAreIncorrect()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new() { Id = "p1" },
            new() { Id = "p2" }
        }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string> { "p1" }
            },
            new()
            {
                Day = 2,
                PlaceIds = new List<string> { "p2" }
            },
            new()
            {
                Day = 3,
                PlaceIds = new List<string>()
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>
        {
            new()
            {
                Code = "NO_PLACES_AVAILABLE",
                Message = "Wrong warning."
            }
        }
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.False(result);
        }

        [Fact]
        public void IsValid_ReturnsTrue_WhenPartialPlanIsValid()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new() { Id = "p1" },
            new() { Id = "p2" }
        }
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string> { "p1" }
            },
            new()
            {
                Day = 2,
                PlaceIds = new List<string> { "p2" }
            },
            new()
            {
                Day = 3,
                PlaceIds = new List<string>()
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>
        {
            new()
            {
                Code = "PARTIAL_ITINERARY",
                Message = "The current candidate pool does not contain enough places to cover every requested day."
            }
        }
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.True(result);
        }

        [Fact]
        public void IsValid_ReturnsTrue_WhenZeroCandidatePlanIsValid()
        {
            // Arrange
            var validator = new PlanningResultValidator();

            var request = new FastApiPlanRequest
            {
                DestinationId = "aqaba-jo",
                Days = 3,
                Interests = new List<string> { "historic_site" },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };

            var response = new FastApiPlanResponse
            {
                Days = new List<FastApiPlanningDayResponse>
        {
            new()
            {
                Day = 1,
                PlaceIds = new List<string>()
            },
            new()
            {
                Day = 2,
                PlaceIds = new List<string>()
            },
            new()
            {
                Day = 3,
                PlaceIds = new List<string>()
            }
        },
                Warnings = new List<FastApiPlanningWarningResponse>
        {
            new()
            {
                Code = "NO_PLACES_AVAILABLE",
                Message = "No suitable places were found in the current candidate pool."
            }
        }
            };

            // Act
            var result = validator.IsValid(request, response);

            // Assert
            Assert.True(result);
        }
    }
}