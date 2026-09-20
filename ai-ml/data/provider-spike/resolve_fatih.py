import getpass
import json
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import urlopen
from urllib.error import HTTPError, URLError

api_key = getpass.getpass("Paste your Geoapify API Key, then Enter: ").strip()
if not api_key:
    raise SystemExit("No key entered. Run the script again.")

endpoint = "https://api.geoapify.com/v1/geocode/search"
params = {
    "text": "Fatih, Istanbul, Turkey",
    "type": "locality",
    "filter": "countrycode:tr",
    "bias": "countrycode:none",
    "lang": "en",
    "limit": 5,
    "format": "json",
}

try:
    url = endpoint + "?" + urlencode({**params, "apiKey": api_key})
    with urlopen(url, timeout=30) as response:
        data = json.load(response)
except HTTPError as error:
    raise SystemExit(f"HTTP {error.code}. Request failed.")
except (URLError, TimeoutError):
    raise SystemExit("Connection failed. Check your internet.")
except (ValueError, UnicodeError):
    raise SystemExit("Unexpected response format.")

timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
evidence = {
    "checked_at_utc": timestamp,
    "status": "Candidate results — boundary review pending",
    "request": {
        "endpoint": endpoint,
        "parameters": {**params, "apiKey": "YOUR_API_KEY"},
    },
    "response": data,
}

output = Path(__file__).resolve().parent / f"fatih-geocoding-{timestamp}.json"
safe_text = json.dumps(evidence, ensure_ascii=False, indent=2)
safe_text = safe_text.replace(api_key, "YOUR_API_KEY")
output.write_text(safe_text, encoding="utf-8")

print("Search completed.")
print("Results:", len(data.get("results", [])))
print("Evidence file:", output)
print("No boundary has been automatically approved.")