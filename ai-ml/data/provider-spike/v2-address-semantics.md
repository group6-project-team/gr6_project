# V2 Optional Address Semantics

**Owner:** Asma Yahya Faris Bzoor ? AI/Data & Provider Semantics
**Baseline:** `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`

## Truth source

V2 may expose an optional `address` only from Geoapify:

`properties.formatted`

No address may be fabricated from `address_line1`, `address_line2`, street, suburb, postcode, city, or other provider fields when `formatted` is absent or unusable.

## Address truth predicate

An address is truthfully exposable only when all of the following are true:

1. `properties.formatted` exists.
2. The value is a string.
3. Leading and trailing whitespace is removed.
4. The trimmed value is not empty.
5. The value passes the approved text-safety/sanitization policy.
6. The trimmed value does not exceed the approved maximum address length.

If any predicate fails, `address` must be absent/null. There is no fallback reconstruction from other provider fields.

## Length decision

The inspected 20-record snapshot has:

- minimum trimmed length: 35
- maximum trimmed length: 107
- values above 256: 0
- values above 512: 0

These observations do **not** authorize Asma to choose a production maximum.

`MAX_ADDRESS_LENGTH` remains dependent on the approved P0/product contract. Until that value is frozen, evidence must describe the rule symbolically:

`len(trim(formatted)) <= MAX_ADDRESS_LENGTH`

An input with length `MAX_ADDRESS_LENGTH + 1` must produce no address.

## Absence behavior

The following produce no address:

- missing `formatted`
- null `formatted`
- non-string `formatted`
- whitespace-only `formatted`
- value failing the approved text-safety policy
- value exceeding `MAX_ADDRESS_LENGTH`

No placeholder such as `Unknown`, `N/A`, or reconstructed address may be emitted.

## Sanitization boundary

The provider string is data, not markup.

The evidence contract requires surrounding whitespace removal and requires unsafe/malformed text not to be exposed verbatim.

Exact implementation mechanics for escaping/rejection belong to the owning Backend/UI contracts; this evidence does not invent a new production sanitizer.

## Snapshot evidence

In the current bounded Fatih sample:

- `formatted` string: 20/20
- blank after trim: 0/20
- control-character cases observed: 0/20
- HTML/script-like cases observed: 0/20

Therefore positive feasibility is demonstrated, while negative behavior is covered by sanitized synthetic fixtures rather than claims about observed provider failures.

## Fixture expectations

See:

`ai-ml/data/provider-spike/fixtures/v2-address-cases.json`

The fixtures contain no credentials and no unnecessary raw provider payload.
