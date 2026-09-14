# Geoapify Places Data Spike — Field Mapping

## Purpose

This document records the draft mapping between fields returned by Geoapify and the fields needed by the trip-planning system.

All mappings in this file are preliminary and may change after more Geoapify evidence is collected.

The current mapping is based only on the inspected Fatih and Rome samples and should not be treated as a complete description of the Geoapify schema.

---

## Evidence Context

The mappings below are based on the currently inspected Fatih and Rome samples.

### Fatih Sample

- **Destination:** Fatih

- **Collection Date:** 2026-09-13

- **Sanitized Request Context:** Geoapify Places API request for `tourism.sights` within the selected Fatih destination scope, with sensitive credentials omitted.

### Rome Sample

- **Destination:** Rome

- **Collection Date:** 2026-09-13

- **Sanitized Request Context:** Geoapify Places API request for `tourism.sights` within the selected Rome destination scope, with sensitive credentials omitted.

Only non-sensitive request information should be documented here. API keys, tokens, secrets, or other credentials must not be included.

---

## Draft Field Mapping

| Geoapify Field | Canonical Field | Status | Notes |
|---|---|---|---|
| `place_id` | `id` | Observed | Geoapify-specific identity observed in both inspected destination samples. It is not a universal place identifier and does not guarantee that every physical place corresponds permanently to exactly one Geoapify record. |
| `name` | `name` | Observed | Available in inspected samples. |
| `lat` | `latitude` | Observed | Available in inspected samples. |
| `lon` | `longitude` | Observed | Available in inspected samples. |
| `categories` | `categoryIds` | Observed / Normalized | Geoapify categories are not copied directly into `categoryIds`. They first pass through canonical category normalization, and the resulting canonical categories are then represented as `categoryIds`. Multiple hierarchical Geoapify categories may be returned. |
| `description` | `description` | Optional / Inconsistent | Present for some inspected places and missing from many other results. |
| `wiki_and_media.image` | `image` | Optional / Inconsistent | Image data was not available consistently. In the inspected evidence where an image was observed, it appeared through `wiki_and_media.image`. This should not be assumed to be Geoapify's only possible image source. |
| Not observed consistently | `rating` | Unconfirmed | No consistent rating field was observed in the current samples. |
| Not observed consistently | `price` | Unconfirmed | No reliable price field was observed; budget support therefore remains unconfirmed. |

---

## Category Normalization Flow

Geoapify categories should not be copied directly into the application's canonical category identifiers.

The intended flow is:

`Geoapify Category → Canonical Normalization → categoryIds`

This keeps Geoapify-specific taxonomy separate from the application's internal taxonomy and allows the mapping rules to evolve independently as more evidence is collected.

---

## Draft Category Mapping

| Geoapify Category | Canonical Category | Status | Notes |
|---|---|---|---|
| `tourism.sights` | `sightseeing` | Draft | General sightseeing place. |
| `tourism.sights.memorial` | `historical` | Draft | Memorial or commemorative place. |
| `tourism.sights.memorial.monument` | `historical` | Draft | Monument. |
| `tourism.sights.archaeological_site` | `historical` | Draft | Archaeological or heritage site. |
| `tourism.sights.ruines` | `historical` | Draft | Historic ruins. |
| `tourism.sights.square` | `sightseeing` | Draft | Public square with tourism relevance. |
| `tourism.sights.building` | `historical` | Conditional / Draft | Map to `historical` only when an additional historical or heritage signal supports that interpretation. Otherwise, do not apply this mapping automatically. |

---

## Unmapped Places

**Status: Draft**

Places with Geoapify categories that do not map directly to the current canonical categories should not be accepted automatically.

They may be retained as **general candidates** when they:

- have a valid Geoapify-specific `place_id`;

- have a usable name;

- have valid coordinates;

- are clearly relevant to a trip or tourist activity;

- are not duplicate or near-duplicate records.

Structurally valid places that are clearly irrelevant for trip planning should be excluded.

This rule remains provisional because the current spike covers only two destination samples and a limited category scope.

---

## Evidence Limitations

The current conclusions are based only on the inspected Fatih and Rome samples.

Therefore:

- `place_id` is treated only as Geoapify-specific identity, not as a universal place identifier;

- Geoapify categories require canonical normalization before becoming `categoryIds`;

- category mappings remain draft rules rather than universal assumptions;

- `tourism.sights.building` does not imply `historical` without supporting historical evidence;

- image data was not available consistently, and `wiki_and_media.image` is only the image field observed in the inspected evidence where an image was present; it is not assumed to be Geoapify's only possible image source;

- fields not observed in these samples should not automatically be considered unsupported by Geoapify globally.

---

## Notes

- This is not the final taxonomy.

- This task does not finalize all destinations or interests.

- Price-related mapping remains unconfirmed unless Geoapify exposes reliable price semantics.

- Pagination beyond the currently inspected evidence is outside the scope of this update.

- Final taxonomy, deduplication rules, and destination-membership rules will be handled in later stages.