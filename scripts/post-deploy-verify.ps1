param(
    [string]$BackendBaseUrl = "https://gr6-tripplanning-api.runasp.net/",
    [string]$FastApiBaseUrl = "https://gr6-planning-service.onrender.com/"
)

$ErrorActionPreference = "Stop"

function Invoke-SanitizedCheck {
    param(
        [string]$Name,
        [string]$Uri,
        [string]$Method = "GET",
        [string]$Body,
        [int[]]$ExpectedStatus,
        [switch]$RequireGeoapifyIds,
        [int]$ExpectedDays = 0,
        [string]$ExpectedErrorCode
    )

    $requestId = "day3-$Name-$([Guid]::NewGuid().ToString('N').Substring(0, 12))"
    $headers = @{ "X-Request-ID" = $requestId }

    try {
        $parameters = @{
            Uri = $Uri
            Method = $Method
            Headers = $headers
            SkipHttpErrorCheck = $true
        }
        if ($PSBoundParameters.ContainsKey("Body")) {
            $parameters.ContentType = "application/json"
            $parameters.Body = $Body
        }

        $response = Invoke-WebRequest @parameters
        $status = [int]$response.StatusCode
        $responseId = [string]$response.Headers["X-Request-ID"]
        if ($response.Content -is [byte[]]) {
            $content = [System.Text.Encoding]::UTF8.GetString($response.Content)
        }
        else {
            $content = [string]$response.Content
        }

        if ($status -notin $ExpectedStatus) {
            throw "$Name returned HTTP $status; expected $($ExpectedStatus -join ', ')"
        }
        if ([string]::IsNullOrWhiteSpace($responseId)) {
            throw "$Name did not return X-Request-ID"
        }
        if ($content -match "apiKey=|api\.geoapify\.com|Authorization|Bearer\s+|System\.| at .*\.cs:line |stacktrace|Traceback \(") {
            throw "$Name exposed provider or internal diagnostic data"
        }

        if (-not [string]::IsNullOrWhiteSpace($ExpectedErrorCode)) {
            $errorJson = $content | ConvertFrom-Json
            if ([string]$errorJson.code -ne $ExpectedErrorCode) {
                throw "$Name returned error code '$($errorJson.code)'; expected '$ExpectedErrorCode'"
            }
        }

        if ($RequireGeoapifyIds -and $status -eq 200) {
            $json = $content | ConvertFrom-Json
            $days = @($json.days)
            if ($ExpectedDays -gt 0 -and $days.Count -ne $ExpectedDays) {
                throw "$Name returned $($days.Count) days; expected $ExpectedDays"
            }

            $overfilledDays = @($days | Where-Object { @($_.places).Count -gt 3 })
            if ($overfilledDays.Count -gt 0) {
                throw "$Name returned more than three places in a day"
            }

            $ids = @($days | ForEach-Object { $_.places } | ForEach-Object { $_.id })
            if ($ids.Count -eq 0) {
                throw "$Name returned no place IDs; record as empty evidence, not provider proof"
            }
            $badIds = @($ids | Where-Object { $_ -notlike "geoapify:*" })
            if ($badIds.Count -gt 0) {
                throw "$Name returned non-Geoapify place IDs: $($badIds -join ', ')"
            }
            if (@($ids | Select-Object -Unique).Count -ne $ids.Count) {
                throw "$Name returned duplicate selected canonical IDs"
            }
            if ($null -eq $json.warnings) {
                throw "$Name omitted the warnings field"
            }
        }

        [pscustomobject]@{
            Check = $Name
            Status = $status
            RequestIdSent = $requestId
            RequestIdReturned = $responseId
            Body = $content
        }
    }
    catch {
        throw "Post-deploy check '$Name' failed: $($_.Exception.Message)"
    }
}

$backend = $BackendBaseUrl.TrimEnd("/")
$fastApi = $FastApiBaseUrl.TrimEnd("/")
$checks = @()

$checks += Invoke-SanitizedCheck -Name "fastapi-health" -Uri "$fastApi/health" -ExpectedStatus 200
$checks += Invoke-SanitizedCheck -Name "istanbul-history" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":3,"interests":["history"]}' -ExpectedStatus 200 -RequireGeoapifyIds -ExpectedDays 3
$checks += Invoke-SanitizedCheck -Name "istanbul-landmark" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":3,"interests":["landmark"]}' -ExpectedStatus 200 -RequireGeoapifyIds -ExpectedDays 3
$checks += Invoke-SanitizedCheck -Name "istanbul-no-interests" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":3,"interests":[]}' -ExpectedStatus 200 -RequireGeoapifyIds -ExpectedDays 3
$checks += Invoke-SanitizedCheck -Name "unsupported-rome" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"rome","days":3,"interests":[]}' -ExpectedStatus 500 -ExpectedErrorCode "PLANNING_FAILED"
$checks += Invoke-SanitizedCheck -Name "unsupported-aqaba" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"aqaba","days":3,"interests":[]}' -ExpectedStatus 500 -ExpectedErrorCode "PLANNING_FAILED"
$checks += Invoke-SanitizedCheck -Name "malformed-json" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":' -ExpectedStatus 400
$checks += Invoke-SanitizedCheck -Name "invalid-days" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":0,"interests":[]}' -ExpectedStatus 400

$checks | ConvertTo-Json -Depth 10
