using TripPlanning.Api.DTOs.Requests;

namespace TripPlanning.Api.Data
{
    public static class Stage2APlanningFixture
    {
        public static FastApiPlanRequest CreateNormalRequest()
        {
            return new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string>
                {
                    "historic_site",
                    "museum",
                    "monument"
                },
                CandidatePlaces = new List<PlaceCandidateRequest>
                {
                    new()
                    {
                        Id = "p1",
                        DestinationId = "istanbul-tr",
                        Name = "Hagia Sophia",
                        CategoryIds = new List<string> { "historic_site" },
                        Latitude = 41.0086,
                        Longitude = 28.9802
                    },
                    new()
                    {
                        Id = "p2",
                        DestinationId = "istanbul-tr",
                        Name = "Topkapi Palace",
                        CategoryIds = new List<string> { "museum" },
                        Latitude = 41.0115,
                        Longitude = 28.9833
                    },
                    new()
                    {
                        Id = "p3",
                        DestinationId = "istanbul-tr",
                        Name = "Basilica Cistern",
                        CategoryIds = new List<string> { "historic_site" },
                        Latitude = 41.0084,
                        Longitude = 28.9778
                    },
                    new()
                    {
                        Id = "p4",
                        DestinationId = "istanbul-tr",
                        Name = "Galata Tower",
                        CategoryIds = new List<string> { "viewpoint" },
                        Latitude = 41.0256,
                        Longitude = 28.9744
                    },
                    new()
                    {
                        Id = "p5",
                        DestinationId = "istanbul-tr",
                        Name = "Grand Bazaar",
                        CategoryIds = new List<string> { "market" },
                        Latitude = 41.0106,
                        Longitude = 28.9681
                    },
                    new()
                    {
                        Id = "p6",
                        DestinationId = "istanbul-tr",
                        Name = "Gulhane Park",
                        CategoryIds = new List<string> { "park" },
                        Latitude = 41.0130,
                        Longitude = 28.9810
                    },
                    new()
                    {
                        Id = "p7",
                        DestinationId = "istanbul-tr",
                        Name = "Suleymaniye Mosque",
                        CategoryIds = new List<string> { "monument" },
                        Latitude = 41.0161,
                        Longitude = 28.9639
                    },
                    new()
                    {
                        Id = "p8",
                        DestinationId = "istanbul-tr",
                        Name = "Bosphorus Waterfront",
                        CategoryIds = new List<string> { "waterfront" },
                        Latitude = 41.0390,
                        Longitude = 29.0080
                    }
                }
            };
        }

        public static FastApiPlanRequest CreatePartialRequest()
        {
            return new FastApiPlanRequest
            {
                DestinationId = "istanbul-tr",
                Days = 3,
                Interests = new List<string>
        {
            "historic_site"
        },
                CandidatePlaces = new List<PlaceCandidateRequest>
        {
            new()
            {
                Id = "p1",
                DestinationId = "istanbul-tr",
                Name = "Hagia Sophia",
                CategoryIds = new List<string> { "historic_site" },
                Latitude = 41.0086,
                Longitude = 28.9802
            },
            new()
            {
                Id = "p2",
                DestinationId = "istanbul-tr",
                Name = "Topkapi Palace",
                CategoryIds = new List<string> { "museum" },
                Latitude = 41.0115,
                Longitude = 28.9833
            }
        }
            };
        }

        public static FastApiPlanRequest CreateEmptyRequest()
        {
            return new FastApiPlanRequest
            {
                DestinationId = "aqaba-jo",
                Days = 3,
                Interests = new List<string>
        {
            "historic_site"
        },
                CandidatePlaces = new List<PlaceCandidateRequest>()
            };
        }
    }
}