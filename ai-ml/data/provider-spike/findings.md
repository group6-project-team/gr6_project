# Geoapify Places Data Spike — Findings

## Task Information

- **Owner:** Asma Yahya Faris Bzoor

- **Track:** AI/Data

- **Branch:** `spike/places-provider`

- **Status:** Iteration 1 Complete — Evidence Merged in PR #2; Iteration 2 canonical mapping and fixture normalization in progress

---

## Objective

This Data Spike evaluates whether Geoapify provides useful and reliable place data for recommendation and trip planning.

The goal is to collect initial evidence from a small sample across at least two representative destinations.

---
## Source Inventory

The current provider-spike evidence contains:

- `fatih-istanbul-tourism-sights.txt` — primary Fatih sample, 20 returned records.
- `rome-tourism-sights.txt` — primary Rome sample, 20 returned records.
- `rome-tourism-sights-page1-limit10.txt` — separate `limit=10` experiment used to verify result limiting behavior; it is not automatically counted as 10 additional unique evidence records.
- `rome-tourism-sights-request.txt` — sanitized request context for the Rome experiment.

For Iteration 2 evidence accounting, the primary evidence base remains 20 Fatih records and 20 Rome records. The `limit=10` experiment is retained as supporting pagination/limit evidence only unless individual records are separately verified as additional unique evidence.

## Destinations Checked

### Destination 1

- **Name:** Fatih, Istanbul, Turkey

- **Provider:** Geoapify Places API

- **Query / Request:** `tourism.sights`

- **Sample Size:** 20 places

- **Collection Date:** 2026-09-13

- **Sanitized Request Context:** Geoapify Places API request for `tourism.sights` within the selected Fatih destination scope, with sensitive credentials omitted.

- **Purpose:** Inspect tourism-related place data and field coverage in a dense historic area.

### Destination 2

- **Name:** Rome, Roma Capitale, Italy

- **Provider:** Geoapify Places API

- **Query / Request:** `tourism.sights`

- **Sample Size:** 20 places

- **Collection Date:** 2026-09-13

- **Sanitized Request Context:** Geoapify Places API request for `tourism.sights` within the selected Rome destination scope, with sensitive credentials omitted.

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

---

### Destination 1 — Fatih, Istanbul

**Query scope:** tourism sights within Fatih, Istanbul

**Sample size:** 20 returned places

Observed from the API response:

- `place_id` was available for the returned places.

- `place_id` should be treated as a Geoapify/source-specific identity rather than a universal place identifier.

- The current evidence does not guarantee that every physical place always corresponds to exactly one permanent Geoapify record.

- `name`, `latitude`, `longitude`, and `categories` were consistently available in the inspected sample.

- Category data was detailed and included values such as:

  - `tourism.sights`

  - `tourism.sights.memorial`

  - `tourism.sights.memorial.monument`

  - `tourism.sights.archaeological_site`

  - `tourism.sights.square`

  - `tourism.sights.building`

- Geoapify categories should not be copied directly into canonical `categoryIds`; they first require canonical normalization.

- Image data was available for some places through `wiki_and_media.image`, but not for every result.

- `wiki_and_media.image` is the image field observed in the inspected Fatih evidence and should not be treated as Geoapify's only possible image source.

- No consistent `rating` field was observed in this sample.

- No consistent `price` field was observed in this sample.

- No clear free-text `description` field was observed in this sample.

- A duplicate-like case was observed for **Atik Ali Paşa Medresesi**:

  the same name appeared in two nearby records with different `place_id` values and slightly different category structures.

- This duplicate-like case reinforces that `place_id` is Geoapify/source-specific identity and should not be interpreted as a universal one-record-per-physical-place identifier.

- The response included detailed location metadata such as city, town, suburb, street, postcode, and formatted address.

- The underlying datasource shown in the response was OpenStreetMap.

---

### Destination 2 — Rome, Italy

**Query scope:** tourism sights within Rome, Italy

**Sample size:** 20 returned places

Observed from the API response:

- `place_id`, `name`, coordinates, and `categories` were available in the inspected sample.

- `place_id` should be treated as a Geoapify/source-specific identity rather than a universal place identifier.

- Geoapify categories require canonical normalization before being represented as application `categoryIds`.

- Tourism categories included values such as:

  - `tourism.sights`

  - `tourism.sights.archaeological_site`

  - `tourism.sights.memorial`

  - `tourism.sights.memorial.monument`

  - `tourism.sights.ruines`

- `tourism.sights.building` should not be treated as a general rule for `historical`; historical classification requires an additional supporting historical or heritage signal.

- A `description` field appeared for some places, but not consistently across the sample.

- Additional optional metadata such as `website` appeared for some places.

- No `wiki_and_media.image` field was observed in the inspected Rome sample.

- In the broader inspected evidence, where image data was observed, it appeared through `wiki_and_media.image`. This should not be generalized as Geoapify's only possible image source.

- No consistent `rating` field was observed in this sample.

- No consistent `price` field was observed in this sample.

- The response contained detailed location metadata such as city, suburb, street, postcode, and formatted address.

- The underlying datasource shown in the response was OpenStreetMap.

- Some returned places were located within the broader `Roma Capitale` boundary but had a different city value such as `Formello`.

- This indicates that the selected place boundary may be broader than the central city area and should be considered when defining supported destination scope.

---

## Initial Findings

Based on the two inspected destination samples:

- Core planning fields such as `place_id`, `name`, coordinates, and categories were available and appear suitable for basic recommendation and planning.

- `place_id` is treated as Geoapify/source-specific identity, not as a universal place identifier.

- The current evidence does not guarantee a permanent one-to-one relationship between one physical place and one Geoapify record.

- Category data is detailed enough to support an initial Geoapify-to-canonical mapping.

- Geoapify categories should first pass through canonical normalization before becoming application `categoryIds`; they should not be copied directly.

- Category mappings remain preliminary and should not be treated as universal rules.

- In particular, `tourism.sights.building` should map to `historical` only when additional historical or heritage evidence supports that classification.

- Optional metadata is inconsistent:

  - `description` appeared only for some places.

  - image data appeared only for some places in the inspected evidence.

  - where image data was observed, it appeared through `wiki_and_media.image`; this should not be treated as Geoapify's only possible image source.

  - website and other optional metadata were not consistently available.

- No reliable `rating` field was observed in the inspected samples.

- No reliable `price` field was observed in the inspected samples.

- Budget-based planning should therefore remain disabled for now.

- Duplicate-like records may occur and require additional deduplication logic.

- Geoapify appears useful for initial place discovery, but more evidence is needed before making final decisions about taxonomy, supported destinations, or budget support.

- Geoapify documentation supports pagination using `limit` and `offset`, but only the `limit` behavior was directly verified in this spike.

---

## Initial Provider Recommendation

**Status:** Proceed with Geoapify for the initial prototype, with limitations.

Based on the current two-destination spike, Geoapify provides the core fields needed for basic recommendation and trip planning, including Geoapify-specific place identifiers, names, coordinates, and useful category information.

However:

- descriptions and images are not consistently available;

- where image data was observed in the inspected evidence, it appeared through `wiki_and_media.image`, but this is not assumed to be Geoapify's only possible image source;

- ratings were not observed consistently;

- reliable price data was not observed;

- duplicate-like records may occur;

- Geoapify categories require canonical normalization before becoming application category IDs;

- some category mappings require supporting evidence and should not be treated as general rules;

- second-page pagination was not directly verified in the current API experiment.

Therefore, Geoapify is suitable for initial place discovery and planning experiments, but it should not be treated as sufficient evidence for enabling budget-based planning or finalizing all supported destinations and taxonomy decisions.

---

## Scope Notes

The following items remain outside the scope of this update and can be addressed in later stages:

- second-page pagination verification;

- final taxonomy decisions;

- final deduplication rules;

- final destination-membership rules.