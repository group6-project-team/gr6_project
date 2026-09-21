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
        [switch]$RequireGeoapifyIds
    )

    $requestId = "day3-$Name-$([Guid]::NewGuid().ToString('N').Substring(0, 12))"
    $headers = @{ "X-Request-ID" = $requestId }

    try {
        $parameters = @{
            Uri = $Uri
            Method = $Method
            Headers = $headers
        }
        if ($PSBoundParameters.ContainsKey("Body")) {
            $parameters.ContentType = "application/json"
            $parameters.Body = $Body
        }

        try {
            $response = Invoke-WebRequest @parameters
            $status = [int]$response.StatusCode
            $responseId = [string]$response.Headers["X-Request-ID"]
            $content = [string]$response.Content
        }
        catch {
            if ($null -eq $_.Exception.Response) {
                throw
            }
            $errorResponse = $_.Exception.Response
            $status = [int]$errorResponse.StatusCode
            $responseId = [string]$errorResponse.Headers["X-Request-ID"]
            $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
            try {
                $content = $reader.ReadToEnd()
            }
            finally {
                $reader.Dispose()
            }
        }

        if ($status -notin $ExpectedStatus) {
            throw "$Name returned HTTP $status; expected $($ExpectedStatus -join ', ')"
        }
        if ([string]::IsNullOrWhiteSpace($responseId)) {
            throw "$Name did not return X-Request-ID"
        }
        if ($content -match "apiKey=|api\.geoapify\.com|System\.| at .*\.cs:line |stacktrace") {
            throw "$Name exposed provider or internal diagnostic data"
        }

        if ($RequireGeoapifyIds -and $status -eq 200) {
            $json = $content | ConvertFrom-Json
            $ids = @($json.days | ForEach-Object { $_.places } | ForEach-Object { $_.id })
            if ($ids.Count -eq 0) {
                throw "$Name returned no place IDs; record as empty evidence, not provider proof"
            }
            $badIds = @($ids | Where-Object { $_ -notlike "geoapify:*" })
            if ($badIds.Count -gt 0) {
                throw "$Name returned non-Geoapify place IDs: $($badIds -join ', ')"
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
$checks += Invoke-SanitizedCheck -Name "istanbul-history" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":3,"interests":["history"]}' -ExpectedStatus 200 -RequireGeoapifyIds
$checks += Invoke-SanitizedCheck -Name "istanbul-landmark" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":3,"interests":["landmark"]}' -ExpectedStatus 200 -RequireGeoapifyIds
$checks += Invoke-SanitizedCheck -Name "istanbul-no-interests" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"istanbul","days":3,"interests":[]}' -ExpectedStatus 200 -RequireGeoapifyIds
$checks += Invoke-SanitizedCheck -Name "unsupported-destination" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":"not-supported","days":3,"interests":[]}' -ExpectedStatus 400
$checks += Invoke-SanitizedCheck -Name "malformed-json" -Uri "$backend/trip-plans/preview" -Method POST -Body '{"destinationId":' -ExpectedStatus 400

$checks | ConvertTo-Json -Depth 10
