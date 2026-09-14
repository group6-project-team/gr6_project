# Geoapify Places Data Spike — Supported Place Rules

## Purpose

This document defines the initial draft rules for deciding whether a place returned by Geoapify is suitable for recommendation and trip planning.

These rules are preliminary and may change after reviewing more Geoapify evidence.

---

## Draft Eligibility Rules

A place may be considered a supported planning candidate if:

- It has a valid Geoapify-specific `place_id`.

- It has a non-empty `name`.

- It has valid latitude and longitude coordinates.

- It belongs to a useful place category or can reasonably be treated as a general candidate.

- It is not identified as a duplicate or near-duplicate of another place in the same candidate set.

A valid `place_id` should be treated only as Geoapify/source-specific identity. It is not a universal identifier and does not guarantee a permanent one-to-one relationship with a physical place.

---

## Draft Exclusion Rules

A place may be excluded if:

- The Geoapify-specific `place_id` is missing.

- The name is missing or unusable.

- Coordinates are missing or invalid.

- The place is clearly not useful for a trip-planning activity.

- It is a duplicate record.

- Required structural data is inconsistent or invalid.

Near-duplicate places should be reviewed when they have the same or very similar name and very close coordinates, even if their `place_id` values are different.

Different Geoapify `place_id` values do not necessarily prove that two records represent different physical places.

---

## Unmapped Category Rule

**Status: Draft**

Places with Geoapify categories that do not map directly to the current canonical categories should not be accepted automatically.

Geoapify categories should first pass through canonical normalization before being represented as application `categoryIds`.

They may be kept as **general candidates** only when:

- The place has a valid Geoapify-specific `place_id`.

- It has a usable name.

- It has valid coordinates.

- The place is clearly relevant to a trip or tourist activity.

- It is not a duplicate or near-duplicate of another candidate.

Places that are structurally valid but not useful for trip planning should be excluded.

This rule remains provisional because the current Data Spike covers only two destination samples and a limited category scope.

---

## Price Rule

**Status: Unconfirmed**

Price information must not be used for budget-based planning unless Geoapify shows reliable and consistent price semantics.

Until that is confirmed, budget support remains disabled.

---

## Notes

- A structurally valid place is not automatically a useful trip activity.

- A Geoapify/source-specific `place_id` must not be interpreted as a universal place identifier.

- Different `place_id` values may still refer to duplicate-like or near-duplicate physical places.

- Geoapify categories require canonical normalization before becoming application `categoryIds`.

- These rules are draft rules for the Data Spike only.

- Final supported-place scope, deduplication logic, taxonomy, and destination-membership rules will be decided later using broader evidence.