# Places Provider Data Spike — Field Mapping

## Purpose

This document records the draft mapping between fields returned by the Places Provider and the fields needed by the trip-planning system.

All mappings in this file are preliminary and may change after more provider evidence is collected.

---

## Draft Field Mapping

| Provider Field | Canonical Field | Status | Notes |
|---|---|---|---|
| `place_id` | `id` | Observed | Available in both inspected destination samples |
| `name` | `name` | Observed | Available in inspected samples |
| `lat` | `latitude` | Observed | Available in inspected samples |
| `lon` | `longitude` | Observed | Available in inspected samples |
| `categories` | `categoryIds` | Observed | Multiple hierarchical categories may be returned |
| `description` | `description` | Optional / Inconsistent | Present for some Rome places, missing from many others |
| `image` / `wiki_and_media.image` | `image` | Optional / Inconsistent | Present for some places, missing from many inspected results |
| Not observed consistently | `rating` | Unconfirmed | No consistent rating field observed in current samples |
| Not observed consistently | `price` | Unconfirmed | No reliable price field observed; budget support remains unconfirmed |

---

## Draft Category Mapping

| Provider Category | Canonical Category | Status | Notes |
|---|---|---|---|
| `tourism.sights` | `sightseeing` | Draft | General sightseeing place |
| `tourism.sights.memorial` | `historical` | Draft | Memorial or commemorative place |
| `tourism.sights.memorial.monument` | `historical` | Draft | Monument |
| `tourism.sights.archaeological_site` | `historical` | Draft | Archaeological / heritage site |
| `tourism.sights.ruins` | `historical` | Draft | Historic ruins |
| `tourism.sights.square` | `sightseeing` | Draft | Public square with tourism relevance |
| `tourism.sights.building` | `historical` | Draft | Historic or notable building |

---

## Unmapped Places

**Status: Draft**

Places with provider categories that do not map directly to the current canonical categories should not be accepted automatically.

They may be retained as **general candidates** when they:

- have a valid `place_id`;
- have a usable name;
- have valid coordinates;
- are clearly relevant to a trip or tourist activity;
- are not duplicate or near-duplicate records.

Structurally valid places that are clearly irrelevant for trip planning should be excluded.

This rule remains provisional because the current spike covers only two destination samples and a limited category scope.

---

## Notes

- This is not the final taxonomy.
- This task does not finalize all destinations or interests.
- Price-related mapping remains unconfirmed unless the provider exposes reliable price semantics.