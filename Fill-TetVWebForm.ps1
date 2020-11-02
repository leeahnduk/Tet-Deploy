

# =============================================================================
# GLOBAL VARIABLES
# -----------------------------------------------------------------------------

$orch1 = 'http://192.168.30.100'


# =============================================================================
# HEADERS
# -----------------------------------------------------------------------------

$headers = @{"Cache-Control"="max-age=0"; "Origin"="http://192.168.30.100:9000"; "Upgrade-Insecure-Requests"="1"; "Content-Type"="application/x-www-form-urlencoded"; "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"; "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"; "Referer"="http://192.168.30.100:9000/site/new"; "Accept-Encoding"="gzip, deflate"; "Accept-Language"="en-US,en;q=0.9"}

$headers['Origin'] = "$($orch1):9000"
$headers['Referer'] = "$($orch1):9000/site/new"


# =============================================================================
# BUILD THE BODY PORTION OF THE REST CALL
# -----------------------------------------------------------------------------

<#
    The JSON file contains entries like:
    "site_name": "asean"
    
    but the body of the REST call is a string of values that look like:
        site%5Bsite_name%5D=asean

    This has been URL encoded. If we convert it back to ASCII, it looks like:
        site[site_name]=asean

    So for each key:value pair we read from the JSON, file, we have to first
    format it like this:
        site[key]=value
    and then URL-encode it... and then join all of those values with ampersand.
#>


$element = @()
foreach($p in (Get-Content settings.json | ConvertFrom-Json).PSObject.Properties) {
    $convertedKey = [System.Web.HttpUtility]::UrlEncode("site[$($p.Name)]")
    $convertedVal = [System.Web.HttpUtility]::UrlEncode("$($p.Value)")
    $element += "$($convertedKey)=$($convertedVal)"
}

$body = $element -join '&'

# =============================================================================
# INITIATE THE RESPONSE
# -----------------------------------------------------------------------------

$uri = "$($orch1):9000/site"

Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $body
