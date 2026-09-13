# Places Provider Data Spike — Findings

## Task Information

- **Owner:** Asma Yahya Faris Bzoor
- **Track:** AI/Data
- **Branch:** `spike/places-provider`
- **Status:** In Progress

---

## Objective

This Data Spike evaluates whether the proposed Places Provider provides useful and reliable data for recommendation and trip planning.

The goal is to collect initial evidence from a small sample across at least two representative destinations.

---

## Destinations Checked

### Destination 1

- **Name:** Fatih, Istanbul, Turkey
- **Query / Request:** Geoapify Places API — `tourism.sights`
- **Sample Size:** 20 places
- **Purpose:** Inspect tourism-related place data and field coverage in a dense historic area.

### Destination 2

- **Name:** Rome, Roma Capitale, Italy
- **Query / Request:** Geoapify Places API — `tourism.sights`
- **Sample Size:** 20 places
- **Purpose:** Compare field coverage and tourism-place metadata against the Istanbul sample.

---

## Documentation Claims

According to the official Geoapify documentation:

- Places API responses can include `name`, address information, `lat`, `lon`, `categories`, and `place_id`.
- `place_id` can be used to retrieve additional information through the Place Details API.
- Additional place details may include `description`, `website`, `opening_hours`, contact information, and wiki/media information.
- Optional metadata depends on what information is available for the place and may therefore be missing.
- The Places API supports pagination using `limit` and `offset`.
- `limit` controls the maximum number of results returned per page.
- `offset` specifies the starting result index and can be used with `limit` to retrieve later result pages.

### Documentation Links

- Geoapify Places API: https://apidocs.geoapify.com/docs/places/
- Geoapify Place Details API: https://apidocs.geoapify.com/docs/place-details/
- Geoapify Pagination Guide: https://apidocs.geoapify.com/how-to/place-discovery/paginate-place-results/

---

## Actual API Observations

### Pagination / Result Limit Observation

- The Geoapify Places API request was tested with `limit=10`.
- The API successfully returned 10 place results for the Rome tourism sights query.
- This confirms that the number of returned results can be controlled using the `limit` parameter.
- The tested Geoapify Playground interface did not expose a second-page pagination control such as `offset`.
- Although `offset` is documented by Geoapify, second-page pagination was not directly tested in this spike.
- Therefore, pagination beyond the first limited result set remains unverified from our own API experiment.

### Destination 1 — Fatih, Istanbul

**Query scope:** tourism sights within Fatih, Istanbul

**Sample size:** 20 returned places

Observed from the API response:

- `place_id` was available for the returned places.
- `name`, `latitude`, `longitude`, and `categories` were consistently available in the inspected sample.
- Category data was detailed and included values such as:
  - `tourism.sights`
  - `tourism.sights.memorial`
  - `tourism.sights.memorial.monument`
  - `tourism.sights.archaeological_site`
  - `tourism.sights.square`
  - `tourism.sights.building`
- Image data was available for some places, but not for every result.
- No consistent `rating` field was observed in this sample.
- No consistent `price` field was observed in this sample.
- No clear free-text `description` field was observed in this sample.
- A duplicate-like case was observed for **Atik Ali Paşa Medresesi**:
  the same name appeared in two nearby records with different `place_id` values and slightly different category structures.
- The response included detailed location metadata such as city, town, suburb, street, postcode, and formatted address.
- The underlying datasource shown in the response was OpenStreetMap.

---

### Destination 2 — Rome, Italy

**Query scope:** tourism sights within Rome, Italy

**Sample size:** 20 returned places

Observed from the API response:

- `place_id`, `name`, coordinates, and `categories` were available in the inspected sample.
- Tourism categories included values such as:
  - `tourism.sights`
  - `tourism.sights.archaeological_site`
  - `tourism.sights.memorial`
  - `tourism.sights.memorial.monument`
  - `tourism.sights.ruins`
- A `description` field appeared for some places, but not consistently across the sample.
- Additional optional metadata such as `website`, `opening_hours`, and contact information appeared for some places.
- No consistent `rating` field was observed in this sample.
- No consistent `price` field was observed in this sample.
- The response contained detailed location metadata such as city, suburb, street, postcode, and formatted address.
- The underlying datasource shown in the response was OpenStreetMap.
- Some returned places were located within the broader `Roma Capitale` boundary but had a different city value such as `Riano` or `Formello`. This indicates that the selected place boundary may be broader than the central city area and should be considered when defining supported destination scope.

---

## Initial Findings

Based on the two inspected destination samples:

- Core planning fields such as `place_id`, `name`, coordinates, and categories were available and appear suitable for basic recommendation and planning.
- Category data is detailed enough to support an initial provider-to-canonical mapping.
- Optional metadata is inconsistent:
  - `description` appeared only for some places.
  - image data appeared only for some places.
  - website, opening hours, and contact information appeared only for some places.
- No reliable `rating` field was observed in the inspected samples.
- No reliable `price` field was observed in the inspected samples.
- Budget-based planning should therefore remain disabled for now.
- Duplicate-like records may occur and require additional deduplication logic.
- The provider appears useful for initial place discovery, but more evidence is needed before making final decisions about taxonomy, supported destinations, or budget support.
- Geoapify documentation supports pagination using `limit` and `offset`, but only the `limit` behavior was directly verified in this spike.

---

## Initial Provider Recommendation

**Status:** Proceed with Geoapify for the initial prototype, with limitations.

Based on the current two-destination spike, Geoapify provides the core fields needed for basic recommendation and trip planning, including stable place identifiers, names, coordinates, and useful category information.

However:

- descriptions and images are not consistently available;
- ratings were not observed consistently;
- reliable price data was not observed;
- duplicate-like records may occur;
- second-page pagination was not directly verified in the current API experiment.

Therefore, Geoapify is suitable for initial place discovery and planning experiments, but it should not be treated as sufficient evidence for enabling budget-based planning or finalizing all supported destinations and taxonomy decisions.