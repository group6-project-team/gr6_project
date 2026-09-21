using System.Text.Json;
using TripPlanning.Api.DTOs.Requests;
using TripPlanning.Api.Services.Interfaces;

namespace TripPlanning.Api.Services.Classes
{
    public class GeoapifyCandidateSource : ICandidateSource
    {
        private readonly IGeoapifyClient _geoapifyClient;

        public GeoapifyCandidateSource(
            IGeoapifyClient geoapifyClient)
        {
            _geoapifyClient = geoapifyClient;
        }

        public async Task<List<PlaceCandidateRequest>> GetCandidatesAsync(
            string destinationId,
            CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();

            using var document = await _geoapifyClient.GetPlacesAsync(
                destinationId,
                cancellationToken);

            var root = document.RootElement;

            if (!root.TryGetProperty("features", out var features) ||
                features.ValueKind != JsonValueKind.Array)
            {
                return new List<PlaceCandidateRequest>();
            }

            var candidates = new List<PlaceCandidateRequest>();
            var seenCandidateIds = new HashSet<string>(
                StringComparer.OrdinalIgnoreCase);

            foreach (var feature in features.EnumerateArray())
            {
                if (!feature.TryGetProperty("properties", out var properties))
                {
                    continue;
                }

                if (!properties.TryGetProperty("place_id", out var placeIdElement))
                {
                    continue;
                }

                if (!properties.TryGetProperty("name", out var nameElement))
                {
                    continue;
                }

                if (!properties.TryGetProperty("lat", out var latElement))
                {
                    continue;
                }

                if (!properties.TryGetProperty("lon", out var lonElement))
                {
                    continue;
                }

                var placeId = placeIdElement.GetString();
                var name = nameElement.GetString();

                if (string.IsNullOrWhiteSpace(placeId) ||
                    string.IsNullOrWhiteSpace(name))
                {
                    continue;
                }

                if (!latElement.TryGetDouble(out var latitude) ||
                    !lonElement.TryGetDouble(out var longitude))
                {
                    continue;
                }

                if (!IsValidFatihMembership(
                    properties,
                    latitude,
                    longitude))
                {
                    continue;
                }

                var categoryIds = GetCanonicalCategoryIds(properties);

                if (categoryIds.Count == 0)
                {
                    continue;
                }

                var candidateId = $"geoapify:{placeId}";

                // Preserve provider order and keep the first eligible record.
                if (!seenCandidateIds.Add(candidateId))
                {
                    continue;
                }

                candidates.Add(new PlaceCandidateRequest
                {
                    Id = candidateId,
                    DestinationId = destinationId,
                    Name = name,
                    CategoryIds = categoryIds,
                    Latitude = latitude,
                    Longitude = longitude
                });
            }

            return candidates;
        }

        private static List<string> GetCanonicalCategoryIds(
            JsonElement properties)
        {
            if (!properties.TryGetProperty("categories", out var categoriesElement) ||
                categoriesElement.ValueKind != JsonValueKind.Array)
            {
                return new List<string>();
            }

            var providerCategories = categoriesElement
                .EnumerateArray()
                .Where(category => category.ValueKind == JsonValueKind.String)
                .Select(category => category.GetString())
                .Where(category => !string.IsNullOrWhiteSpace(category))
                .Select(category => category!)
                .ToHashSet(StringComparer.OrdinalIgnoreCase);

            if (providerCategories.Contains(
                "tourism.sights.memorial.tumulus"))
            {
                return new List<string>();
            }

            var canonicalCategories = new HashSet<string>(
                StringComparer.OrdinalIgnoreCase);

            if (providerCategories.Contains(
                    "tourism.sights.archaeological_site") ||
                providerCategories.Contains(
                    "tourism.sights.memorial") ||
                providerCategories.Contains(
                    "tourism.sights.ruines"))
            {
                canonicalCategories.Add("historic_site");
            }

            if (providerCategories.Contains(
                "tourism.sights.memorial.monument"))
            {
                canonicalCategories.Add("historic_site");
                canonicalCategories.Add("monument");
            }

            if (providerCategories.Contains("tourism.sights.building") &&
                providerCategories.Contains("building.historic"))
            {
                canonicalCategories.Add("historic_site");
            }

            return canonicalCategories.ToList();
        }

        private static bool IsValidFatihMembership(
            JsonElement properties,
            double latitude,
            double longitude)
        {
            if (!double.IsFinite(latitude) ||
                !double.IsFinite(longitude) ||
                latitude < -90 ||
                latitude > 90 ||
                longitude < -180 ||
                longitude > 180)
            {
                return false;
            }

            if (!properties.TryGetProperty("country_code", out var countryElement) ||
                !properties.TryGetProperty("city", out var cityElement) ||
                !properties.TryGetProperty("town", out var townElement))
            {
                return false;
            }

            var countryCode = countryElement.GetString()?.Trim();
            var city = cityElement.GetString()?.Trim();
            var town = townElement.GetString()?.Trim();

            return string.Equals(
                       countryCode,
                       "tr",
                       StringComparison.OrdinalIgnoreCase) &&
                   string.Equals(
                       city,
                       "Istanbul",
                       StringComparison.OrdinalIgnoreCase) &&
                   string.Equals(
                       town,
                       "Fatih",
                       StringComparison.OrdinalIgnoreCase);
        }
    }
}
