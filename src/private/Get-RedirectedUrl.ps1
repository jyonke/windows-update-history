<#
.SYNOPSIS
    Retrieves the final URL after all redirects for a given URL.
.DESCRIPTION
    The Get-RedirectedUrl function takes a URL and follows any HTTP redirects to retrieve the final destination URL.
    It can optionally take a referer URL and handle unescaped URLs.

.PARAMETER url
    The initial URL to follow for redirects. This parameter is mandatory.
.PARAMETER referer
    An optional referer URL to include in the request headers.
.PARAMETER NoEscape
    If specified, returns the raw redirected URL without escaping special characters. This can also be specified using the aliases 'DisableEscape' or 'RawUrl'.

.NOTES
    This function is useful for resolving shortened or redirected URLs to their final destination.
    It requires an internet connection to function properly.

.EXAMPLE
    Get-RedirectedUrl -url "http://short.url/abc"
    Retrieves and returns the final URL after following redirects from the given shortened URL.

.EXAMPLE
    Get-RedirectedUrl -url "http://example.com" -referer "http://referer.com"
    Retrieves and returns the final URL after following redirects, including a referer URL in the request.

.EXAMPLE
    Get-RedirectedUrl -url "http://example.com" -NoEscape
    Retrieves and returns the final URL without escaping special characters.
#>

function Get-RedirectedUrl {
    [CmdletBinding()]    
    param(
        [Parameter(Mandatory = $true)]
        [uri]$url,
        [uri]$referer,
        [Alias('DisableEscape', 'RawUrl')]
        [switch]$NoEscape
    )

    $req = [System.Net.WebRequest]::CreateDefault($url)
    if ($referer) {
        $req.Referer = $referer

    }
    $resp = $req.GetResponse()

    if ($resp -and $resp.ResponseUri.OriginalString -ne $url) {
        Write-Verbose "Found redirected url '$($resp.ResponseUri)"
        if ($NoEscape -or $($resp.ResponseUri.OriginalString) -match '\%\d+' ) {
            $result = $resp.ResponseUri.OriginalString
        }
        else {
            $result = [uri]::EscapeUriString($resp.ResponseUri.OriginalString)
        }
    }
    else {
        Write-Warning "No redirected url was found, returning given url."
        $result = $url
    }

    $resp.Dispose()

    return $result
}