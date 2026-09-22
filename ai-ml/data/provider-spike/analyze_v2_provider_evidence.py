import json
import math
import re
from collections import Counter
from pathlib import Path


RAW = Path(__file__).resolve().parents[3] / "Backend" / "TripPlanning.Api.Tests" / "Evidence" / "Stage3" / "geoapify-raw-response-latest-main.json"
NORMALIZED = Path(__file__).resolve().parents[3] / "Backend" / "TripPlanning.Api.Tests" / "Evidence" / "Stage3" / "geoapify-normalized-candidates-latest-main.json"

TARGET_METADATA = (
    "rating",
    "opening",
    "hours",
    "price",
    "website",
    "wiki",
    "media",
)


def load_json(path: Path):
    raw = path.read_bytes()

    for encoding in ("utf-8-sig", "utf-16", "utf-8"):
        try:
            return json.loads(raw.decode(encoding))
        except (UnicodeDecodeError, json.JSONDecodeError):
            continue

    raise RuntimeError(f"Could not decode JSON file: {path}")


def get_any(obj, *names):
    for name in names:
        if name in obj:
            return obj[name]
    return None


def nested_paths(obj, path=""):
    found = set()

    if isinstance(obj, dict):
        for key, value in obj.items():
            current = f"{path}.{key}" if path else key
            low = current.lower()

            if any(target in low for target in TARGET_METADATA):
                found.add(current)

            found.update(nested_paths(value, current))

    elif isinstance(obj, list):
        for value in obj:
            found.update(nested_paths(value, path + "[]"))

    return found


def canonical_categories(properties):
    categories = set(properties.get("categories") or [])

    if "tourism.sights.memorial.tumulus" in categories:
        return []

    result = set()

    if (
        "tourism.sights.archaeological_site" in categories
        or "tourism.sights.memorial" in categories
        or "tourism.sights.ruines" in categories
    ):
        result.add("historic_site")

    if "tourism.sights.memorial.monument" in categories:
        result.add("historic_site")
        result.add("monument")

    if (
        "tourism.sights.building" in categories
        and "building.historic" in categories
    ):
        result.add("historic_site")

    return sorted(result)


def valid_membership(properties):
    return (
        str(properties.get("country_code", "")).strip().lower() == "tr"
        and str(properties.get("city", "")).strip().lower() == "istanbul"
        and str(properties.get("town", "")).strip().lower() == "fatih"
    )


def valid_coordinates(properties):
    lat = properties.get("lat")
    lon = properties.get("lon")

    return (
        isinstance(lat, (int, float))
        and isinstance(lon, (int, float))
        and math.isfinite(lat)
        and math.isfinite(lon)
        and -90 <= lat <= 90
        and -180 <= lon <= 180
    )


raw_data = load_json(RAW)
normalized_data = load_json(NORMALIZED)

features = raw_data["features"]
normalized = (
    normalized_data
    if isinstance(normalized_data, list)
    else normalized_data.get("candidates", [])
)

print("=== SNAPSHOT COUNTS ===")
print("raw:", len(features))
print("normalized:", len(normalized))
print()

print("=== RAW NONBLANK FIELD PREVALENCE ===")
raw_counts = Counter()

for feature in features:
    properties = feature.get("properties", {})

    for key, value in properties.items():
        if value not in (None, "", [], {}):
            raw_counts[key] += 1

for key, count in sorted(raw_counts.items(), key=lambda item: (-item[1], item[0])):
    print(f"{key}: {count}/{len(features)}")

print()
print("=== NORMALIZED FIELD PREVALENCE ===")
normalized_counts = Counter()

for candidate in normalized:
    for key, value in candidate.items():
        if value not in (None, "", [], {}):
            normalized_counts[key] += 1

for key, count in sorted(normalized_counts.items(), key=lambda item: (-item[1], item[0])):
    print(f"{key}: {count}/{len(normalized)}")

print()
print("=== TARGET METADATA PATHS ===")
path_counts = Counter()

for feature in features:
    properties = feature.get("properties", {})

    for path in nested_paths(properties):
        path_counts[path] += 1

if not path_counts:
    print("NONE")
else:
    for path, count in sorted(path_counts.items()):
        print(f"{path}: {count}/{len(features)}")

print()
print("=== FORMATTED FIELD AUDIT ===")
formatted = [
    feature.get("properties", {}).get("formatted")
    for feature in features
]

formatted_strings = [
    value for value in formatted
    if isinstance(value, str)
]

trimmed = [value.strip() for value in formatted_strings]

print("string formatted:", len(formatted_strings))
print("blank after trim:", sum(not value for value in trimmed))
print("min trimmed length:", min(map(len, trimmed)) if trimmed else "N/A")
print("max trimmed length:", max(map(len, trimmed)) if trimmed else "N/A")
print(">256 chars:", sum(len(value) > 256 for value in trimmed))
print(">512 chars:", sum(len(value) > 512 for value in trimmed))
print(
    "control chars:",
    sum(
        bool(re.search(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]", value))
        for value in trimmed
    ),
)
print(
    "html/script-like:",
    sum(
        bool(re.search(r"<\s*/?\s*(script|iframe|img|svg|html)\b", value, re.I))
        for value in trimmed
    ),
)

print()
print("=== MEMBERSHIP / COORDINATE AUDIT ===")
print(
    "membership failures:",
    sum(
        not valid_membership(feature.get("properties", {}))
        for feature in features
    ),
)
print(
    "coordinate failures:",
    sum(
        not valid_coordinates(feature.get("properties", {}))
        for feature in features
    ),
)

print()
print("=== RAW TO NORMALIZED RECONCILIATION ===")
normalized_by_id = {}

for candidate in normalized:
    candidate_id = get_any(candidate, "Id", "id")

    if candidate_id:
        normalized_by_id[candidate_id] = candidate

mismatches = []

for feature in features:
    properties = feature.get("properties", {})
    place_id = properties.get("place_id")
    candidate_id = f"geoapify:{place_id}" if place_id else None

    expected_categories = canonical_categories(properties)
    expected_accept = (
        bool(expected_categories)
        and valid_membership(properties)
        and valid_coordinates(properties)
    )

    actual = normalized_by_id.get(candidate_id)
    actual_accept = actual is not None
    actual_categories = (
        sorted(get_any(actual, "CategoryIds", "categoryIds") or [])
        if actual
        else []
    )

    if (
        expected_accept != actual_accept
        or (actual and actual_categories != expected_categories)
    ):
        mismatches.append(
            {
                "name": properties.get("name"),
                "expected_accept": expected_accept,
                "actual_accept": actual_accept,
                "expected_categories": expected_categories,
                "actual_categories": actual_categories,
            }
        )

print("mismatches:", len(mismatches))

for mismatch in mismatches:
    print(mismatch)
