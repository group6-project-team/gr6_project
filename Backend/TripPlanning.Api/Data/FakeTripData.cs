using TripPlanning.Api.DTOs.Responses;

namespace TripPlanning.Api.Data
{
    public static class FakeTripData
    {
        public static readonly HashSet<string> SupportedDestinations =
            new()
            {
                "istanbul",
                "rome",
                "aqaba"
            };

        public static readonly HashSet<string> SupportedInterests =
            new()
            {
                "history",
                "culture",
                "art",
                "nature",
                "adventure",
                "food"
            };

        public static readonly Dictionary<string, List<PlaceResponse>> PlacesByDestination =
            new()
            {
                ["istanbul"] = new List<PlaceResponse>
                {
                    new()
                    {
                        Id = "ist-001",
                        Name = "Hagia Sophia",
                        CategoryIds = new List<string> { "historic_site", "museum" },
                        Description = "Historic landmark in Istanbul.",
                        Address = "Sultanahmet, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-002",
                        Name = "Topkapi Palace",
                        CategoryIds = new List<string> { "historic_site", "museum" },
                        Description = "Historic Ottoman palace.",
                        Address = "Fatih, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-003",
                        Name = "Blue Mosque",
                        CategoryIds = new List<string> { "historic_site", "monument" },
                        Description = "Historic mosque in Sultanahmet.",
                        Address = "Sultanahmet, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-004",
                        Name = "Grand Bazaar",
                        CategoryIds = new List<string> { "market", "culture" },
                        Description = "Historic covered market.",
                        Address = "Fatih, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-005",
                        Name = "Galata Tower",
                        CategoryIds = new List<string> { "monument", "viewpoint" },
                        Description = "Historic tower with city views.",
                        Address = "Beyoglu, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-006",
                        Name = "Istanbul Archaeological Museums",
                        CategoryIds = new List<string> { "museum", "history" },
                        Description = "Museum complex with archaeological collections.",
                        Address = "Fatih, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-007",
                        Name = "Basilica Cistern",
                        CategoryIds = new List<string> { "historic_site" },
                        Description = "Historic underground cistern.",
                        Address = "Sultanahmet, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-008",
                        Name = "Dolmabahce Palace",
                        CategoryIds = new List<string> { "historic_site", "museum" },
                        Description = "Historic palace on the Bosphorus.",
                        Address = "Besiktas, Istanbul"
                    },
                    new()
                    {
                        Id = "ist-009",
                        Name = "Spice Bazaar",
                        CategoryIds = new List<string> { "market", "food" },
                        Description = "Traditional market known for spices and food.",
                        Address = "Fatih, Istanbul"
                    }
                },

                ["rome"] = new List<PlaceResponse>
                {
                    new()
                    {
                        Id = "rom-001",
                        Name = "Colosseum",
                        CategoryIds = new List<string> { "historic_site", "monument" },
                        Description = "Historic amphitheatre in Rome.",
                        Address = "Rome, Italy"
                    },
                    new()
                    {
                        Id = "rom-002",
                        Name = "Roman Forum",
                        CategoryIds = new List<string> { "historic_site" },
                        Description = "Ancient Roman archaeological site.",
                        Address = "Rome, Italy"
                    }
                },

                ["aqaba"] = new List<PlaceResponse>()
            };
    }
}