<#
.SYNOPSIS
    Retrieves information about various Windows OS builds based on specified parameters.
.DESCRIPTION
    The Get-OSBuilds function queries the Microsoft release information for Windows 10, Windows 11, and Windows Server.
    It extracts build information such as servicing options, availability dates, release types, and KB articles.
    You can filter the results based on product, build number, and build type (preview or out-of-band).
.PARAMETER Product
    Specifies the Windows product to query. Valid values are 'Windows 10', 'Windows 11', and 'Windows Server'.
.PARAMETER Build
    Specifies the build number to filter results. Valid values are: 10240, 10586, 14393, 15063, 15254, 16299, 17134, 17763, 18362, 18363, 19041, 19042, 19043, 19044, 19045, 20348, 22000, 22621, 22631, 25398, 26100.
.PARAMETER Newest
    If specified, returns only the newest build information available.
.PARAMETER Preview
    If specified, includes preview builds in the results.
.PARAMETER OutofBand
    If specified, includes out-of-band builds in the results.
.NOTES
    This function requires an internet connection to query Microsoft release information.
    It is not supported on Linux.
.LINK
    https://learn.microsoft.com/en-us/windows/release-health/release-information
.EXAMPLE
    Get-OSBuilds -Product 'Windows 10' -Newest -Verbose
    Retrieves and displays the newest Windows 10 build information with verbose output.

.EXAMPLE
    Get-OSBuilds -Product 'Windows Server' -Build 20348 -OutofBand
    Retrieves and displays Windows Server build 20348 including out-of-band updates.
#>

function Get-OSBuilds {
 
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('Windows 10', 'Windows 11', 'Windows Server')]
        [string]
        $Product,
        [Parameter()]
        [ValidateSet(10240, 10586, 14393, 15063 , 15254, 16299, 17134, 17763, 18362, 18363, 19041, 19042, 19043, 19044, 19045, 20348, 22000, 22621, 22631, 25398, 26100)]
        [string]
        $Build,
        [Parameter()]
        [switch]
        $Newest,
        [Parameter()]
        [switch]
        $Preview,
        [Parameter()]
        [switch]
        $OutofBand
    )

    switch -Wildcard ($Product) {
        'Windows 10' {
            $uri = 'https://learn.microsoft.com/en-us/windows/release-health/release-information'
        }
        'Windows 11' {
            $uri = 'https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information'
        }
        'Windows Server*' {
            $uri = 'https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info'
        }

        Default {}
    }
    $htmlContent = Invoke-RestMethod $uri -ErrorAction Stop 

    # Define the regex pattern to match table rows
    $pattern = '<tr>\s*<td>(.*?)</td>\s*<td>(.*?)</td>\s*<td>(.*?)</td>\s*<td><a href="(.*?)"[^>]*>(.*?)</a></td>\s*</tr>'

    # Extract rows from the HTML content using regex
    $matches = [regex]::Matches($htmlContent, $pattern)

    # Process each match and create PSCustomObject
    $results = $matches | ForEach-Object -Parallel {
        # Import private functions
        Get-ChildItem $using:PSScriptRoot *.ps1 | ForEach-Object { . $PSItem.FullName }

        $OSProduct = $using:Product
        $servicingOption = $_.Groups[1].Value -replace '<[^>]*>', '' -replace '\s{2,}', ' '
        $availabilityDate = $_.Groups[2].Value.Trim()
        $ubr = $_.Groups[3].Value.Trim()
        $kbUrl = $_.Groups[4].Value.Trim()
        $kbArticle = $_.Groups[5].Value.Trim() 
        $servicingOptionArray = $servicingOption -split ' • '    
        $MajorBuildNumber = ([version]$ubr).Major
        $MinorBuildNumber = ([version]$ubr).Minor

        Write-Verbose "Processing: $ubr" 
        # Filter Major Builds
        if (($using:Build) -and ([string]$MajorBuildNumber -ne [string]$using:Build)) {
            Write-Verbose "Skipping: $ubr, Filtering $using:Build only"
            return
        }

        # Map Releaseid
        Write-Verbose "Mapping Releaseid from Major Build: $MajorBuildNumber"
        # Server
        if ($OSProduct -match 'Server') {
            switch ($MajorBuildNumber) {
                "14393" { [string]$OSProduct = 'Windows Server 2016' }
                "17763" { [string]$OSProduct = 'Windows Server 2019' }
                "20348" { [string]$OSProduct = 'Windows Server 2022' }
                "25398" { [string]$OSProduct = 'Windows Server' }
                Default {
                    return
                }
            }    
        }
        
        # Win10/11
        switch ($MajorBuildNumber) {
            "10240" { [string]$ReleaseId = '1507' }
            "10586" { [string]$ReleaseId = '1511' }
            "14393" { [string]$ReleaseId = '1607' }
            "15063" { [string]$ReleaseId = '1703' }
            "15254" { return } #Windows 10 Mobile Only
            "16299" { [string]$ReleaseId = '1709' }
            "17134" { [string]$ReleaseId = '1803' }
            "17763" { [string]$ReleaseId = '1809' }
            "18362" { [string]$ReleaseId = '1903' }
            "18363" { [string]$ReleaseId = '1909' }
            "19041" { [string]$ReleaseId = '2004' }
            "19042" { [string]$ReleaseId = '20H2' }
            "19043" { [string]$ReleaseId = '21H1' }
            "19044" { [string]$ReleaseId = '21H2' }
            "19045" { [string]$ReleaseId = '22H2' }
            "20348" { [string]$ReleaseId = '21H2' }
            "22000" { [string]$ReleaseId = '21H2' }
            "22621" { [string]$ReleaseId = '22H2' }
            "22631" { [string]$ReleaseId = '23H2' }
            "25398" { [string]$ReleaseId = '23H2' }
            "26100" { [string]$ReleaseId = '24H2' }
            Default {
                Write-Warning "Build: $($ubr) not mapped"
            }
        }
                        
        # Determine Build Type and Filter
        $KBUrlRedirect = Get-RedirectedUrl $kbUrl
        if ($KBUrlRedirect) {
            Write-Verbose "Found KB URL Redirect: $KBUrlRedirect"
            switch -Wildcard ($KBUrlRedirect) {
                '*preview*' { $type = 'Preview' }
                '*out-of-band*' { $type = 'Out-of-band' }
                Default { $type = 'Standard' }
            }
            Write-Verbose "Update Type: $type"
        }
        else {
            Write-Verbose "Missing KB URL Redirect: $KBUrl"
        }
        if (($using:Preview -ne $true) -and ($type -eq 'Preview')) {
            Write-Verbose "Skipping: $ubr is a Preview Build"
            return
        }
        if (($using:OutofBand -ne $true) -and ($type -eq 'Out-of-band')) {
            Write-Verbose "Skipping: $ubr is an Out-of-Band Build"
            return
        }

        [PSCustomObject]@{
            'Product'          = $OSProduct
            'ServicingOption'  = $servicingOptionArray
            'AvailabilityDate' = $availabilityDate
            'ReleaseType'      = $type
            'RelaseId'         = $ReleaseId
            'Build'            = $ubr
            'KBArticle'        = $kbArticle
            'KBUrl'            = $kbUrl    
            'MajorBuildNumber' = $MajorBuildNumber
            'MinorBuildNumber' = $MinorBuildNumber
        }
    } -ThrottleLimit 8

    # Format, filter and return the results
    $resultsf = $results | Sort-Object -Property Build | Sort-Object -Property 'AvailabilityDate', 'MajorBuildNumber', 'MinorBuildNumber' | Select-Object -Property * -ExcludeProperty 'MajorBuildNumber', 'MinorBuildNumber'
    
    if ($Newest) {
        $resultsf = $resultsf | Select-Object -Last 1
    }
    
    return $resultsf
}