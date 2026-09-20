import getpass
import json
import math
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parent

BOUNDARY_ID = (
    "510de9a683abf23c40598128f3ea77824440"
    "f00101f901d8f21a0000000000c002089203054661746968"
)

boundary_candidate = {
    "status": "Selected for validation; final approval pending",
    "geocoding_evidence_file": "fatih-geocoding-20260917T200719257491Z.json",
    "source_result_index": 2,
    "name": "Fatih",
    "category": "administrative",
    "datasource": "openstreetmap",
    "place_id": BOUNDARY_ID,
    "public_destination_id": "istanbul",
    "supported_scope": "Fatih only",
}

endpoint = "https://api.geoapify.com/v2/places"
params = {
    "categories": "tourism.sights",
    "filter": f"place:{BOUNDARY_ID}",
    "limit": 20,
    "lang": "en",
}

api_key = getpass.getpass("Paste your Geoapify API Key, then Enter: ").strip()
if not api_key:
    raise SystemExit("No key entered. Run the script again.")

try:
    url = endpoint + "?" + urlencode({**params, "apiKey": api_key})
    with urlopen(url, timeout=30) as response:
        http_status = response.status
        data = json.load(response)
except HTTPError as error:
    raise SystemExit(f"HTTP {error.code}. Request failed.")
except (URLError, TimeoutError):
    raise SystemExit("Connection failed. Check your internet.")
except (ValueError, UnicodeError):
    raise SystemExit("Unexpected response format.")

timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
raw_path = ROOT / f"fatih-bounded-response-{timestamp}.json"
report_path = ROOT / f"fatih-membership-review-{timestamp}.json"


def save_json(path, value):
    text = json.dumps(value, ensure_ascii=False, indent=2)
    path.write_text(text.replace(api_key, "YOUR_API_KEY"), encoding="utf-8")


request_evidence = {
    "endpoint": endpoint,
    "parameters": {**params, "apiKey": "YOUR_API_KEY"},
}

save_json(raw_path, {
    "checked_at_utc": timestamp,
    "http_status": http_status,
    "boundary_candidate": boundary_candidate,
    "request": request_evidence,
    "response": data,
})

if (
    not isinstance(data, dict)
    or data.get("type") != "FeatureCollection"
    or not isinstance(data.get("features"), list)
):
    raise SystemExit("Unexpected response structure. Raw evidence saved.")


def normalize(value):
    return value.strip().casefold() if isinstance(value, str) else ""


def valid_number(value, minimum, maximum):
    return (
        isinstance(value, (int, float))
        and not isinstance(value, bool)
        and math.isfinite(value)
        and minimum <= value <= maximum
    )


expected = {"country_code": "tr", "city": "istanbul", "town": "fatih"}
records = []

for index, feature in enumerate(data["features"]):
    properties = feature.get("properties") if isinstance(feature, dict) else {}
    properties = properties if isinstance(properties, dict) else {}

    missing = [
        field for field in expected
        if not normalize(properties.get(field))
    ]
    mismatches = [
        field for field, wanted in expected.items()
        if normalize(properties.get(field))
        and normalize(properties.get(field)) != wanted
    ]

    coordinates_valid = (
        valid_number(properties.get("lat"), -90, 90)
        and valid_number(properties.get("lon"), -180, 180)
    )

    reasons = (
        [f"mismatch:{field}" for field in mismatches]
        + [f"missing_or_unusable:{field}" for field in missing]
    )
    if not coordinates_valid:
        reasons.append("invalid_coordinates")

    if mismatches:
        status = "OUT_OF_SCOPE"
    elif missing:
        status = "UNKNOWN_MEMBERSHIP"
    elif not coordinates_valid:
        status = "INVALID_COORDINATES"
    else:
        status = "MATCH"

    records.append({
        "source_record_index": index,
        "provider_place_id": properties.get("place_id"),
        "name": properties.get("name"),
        "country_code": properties.get("country_code"),
        "city": properties.get("city"),
        "town": properties.get("town"),
        "latitude": properties.get("lat"),
        "longitude": properties.get("lon"),
        "categories": properties.get("categories"),
        "membership_check": status,
        "reasons": reasons,
    })

counts = dict(Counter(record["membership_check"] for record in records))

save_json(report_path, {
    "checked_at_utc": timestamp,
    "status": "Evidence captured; final review pending",
    "http_status": http_status,
    "boundary_candidate": boundary_candidate,
    "request": request_evidence,
    "raw_evidence_file": raw_path.name,
    "record_count": len(records),
    "membership_counts": counts,
    "limitations": [
        "One bounded sample, up to 20 records; not exhaustive coverage.",
        "MATCH checks membership fields and coordinate ranges only.",
        "Full recommendation eligibility still requires separate checks.",
        "Physical-place deduplication is not established by this check.",
        "An empty response does not establish successful membership validation.",
    ],
    "records": records,
})

print("HTTP:", http_status)
print("Records:", len(records))
print("Membership checks:", counts)
print("Raw evidence:", raw_path)
print("Review file:", report_path)
print("Final boundary approval remains pending.")