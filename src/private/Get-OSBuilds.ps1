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
        $OutofBand,
        [Parameter()]
        [string]
        $StaticDataFile
    )

    switch -Wildcard ($Product) {
        'Windows 10' {
            $uri = 'https://learn.microsoft.com/en-us/windows/release-health/release-information'
            $uriUpdateHistory = @(
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-8127c2c6-6edf-4fdf-8b9f-0f7be1ef3562'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-93345c32-4ae1-6d1c-f885-6c0b718adf3b'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-2ad7900f-882c-1dfc-f9d7-82b7ca162010'
                'https://support.microsoft.com/en-us/topic/windows-10-and-windows-server-2016-update-history-4acfbc84-a290-1b54-536a-1c0430e9f3fd'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-83aa43c0-82e0-92d8-1580-10642c9ed612'
                'https://support.microsoft.com/en-us/topic/windows-10-and-windows-server-update-history-8e779ac1-e840-d3b8-524e-91037bf7645a'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-0d8c2da6-3dba-66e4-2ef2-059192bf7869'
                'https://support.microsoft.com/en-us/topic/windows-10-and-windows-server-2019-update-history-725fc2e1-4443-6831-a5ca-51ff5cbcb059'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-e6058e7c-4116-38f1-b984-4fcacfba5e5d'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-53c270dc-954f-41f7-7ced-488578904dfe'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-24ea91f4-36e7-d8fd-0ddb-d79d9d0cdbda'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-7dd3071a-3906-fa2c-c342-f7f86728a6e3'
            )  
        }
        'Windows 11' {
            $uri = 'https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information'
            $uriUpdateHistory = @(
                'https://support.microsoft.com/en-us/topic/windows-11-version-23h2-update-history-59875222-b990-4bd9-932f-91a5954de434'
                'https://support.microsoft.com/en-us/topic/windows-11-version-21h2-update-history-a19cd327-b57f-44b9-84e0-26ced7109ba9'
            ) 
        }
        'Windows Server*' {
            $uri = 'https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info'
            $uriUpdateHistory = @(
                'https://support.microsoft.com/en-us/topic/windows-server-version-23h2-update-history-68c851ff-825a-4dbc-857b-51c5aa0ab248'
                'https://support.microsoft.com/en-us/topic/windows-10-and-windows-server-2019-update-history-725fc2e1-4443-6831-a5ca-51ff5cbcb059'
                'https://support.microsoft.com/en-us/topic/windows-10-and-windows-server-2016-update-history-4acfbc84-a290-1b54-536a-1c0430e9f3fd'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-e6058e7c-4116-38f1-b984-4fcacfba5e5d'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-53c270dc-954f-41f7-7ced-488578904dfe'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-24ea91f4-36e7-d8fd-0ddb-d79d9d0cdbda'
                'https://support.microsoft.com/en-us/topic/windows-10-update-history-7dd3071a-3906-fa2c-c342-f7f86728a6e3'
            )
        }

        Default {}
    }
    $htmlContent = Invoke-RestMethod $uri -ErrorAction Stop 
    $updateHistory = $uriUpdateHistory | ForEach-Object { Invoke-WebRequest -Uri $_ -UseBasicParsing -ErrorAction stop; Start-Sleep -Milliseconds 500 }
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
        # Initialize the update type
        $type = "Standard"

        try {
            # Find the matching link based on the build number
            $matchingLink = $using:updateHistory.Links | Where-Object { $_.outerHTML -match $kbArticle } | Select-Object -First 1 -ExpandProperty outerHTML

            # Check the update type based on the link text
            if ($matchingLink -match "(?i)preview") {
                $type = "Preview"
            }
            elseif ($matchingLink -match "(?i)out-of-band") {
                $type = "Out-of-band"
            }
            if ([string]::IsNullOrEmpty($matchingLink)) {
                $type = "Unknown"
            }
        }
        catch {
            Write-Error "Failed to parse the update type: $_"
            exit
        }
        Write-Verbose "Update Type: $type"
        
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
    # Import static release data for builds that are not mapped properly
    if (Test-Path $StaticDataFile) {
        $StaticData = Get-Content -Path $StaticDataFile | ConvertFrom-Json -ErrorAction Stop
        # Map static data
        $resultsf = $resultsf | ForEach-Object { 
            $Item = $_
            $MappedData = $StaticData | Where-Object { $_.Build -eq $Item.Build }
            if ($MappedData.Count -eq 1) {
                return $MappedData
            }
            if ($MappedData.Count -eq 0) {
                return $Item
            }
            if ($MappedData.Count -gt 1) {
                throw "Invalid mapped data set"
            }
        }  
    }
    
    if ($Newest) {
        $resultsf = $resultsf | Select-Object -Last 1
    }
    
    return $resultsf
}