$ErrorActionPreference = 'Stop'
$ExportFolder = Join-Path (Split-Path $PSScriptRoot) 'exports'
if (-not(Test-Path $ExportFolder)) {
    throw "$ExportFolder not found"
    return
}

# Import private functions
Get-ChildItem (Join-Path $PSScriptRoot 'private') *.ps1 | ForEach-Object { . $PSItem.FullName }

# Windows10
$TimeStamp = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
Write-Output "$TimeStamp`: Gathering Windows 10 Build Details"
$W10StaticDataFile = Join-Path $PSScriptRoot '\private\Microsoft_Windows_10_Static_Builds.json'
$OSBuilds = Get-OSBuilds -Product 'Windows 10' -Preview -OutofBand -StaticDataFile $W10StaticDataFile
$OSBuilds | Group-Object -Property ReleaseId | ForEach-Object {
    $FileName = "Microsoft_Windows_10_$($_.Name).json"
    $_.Group | ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder $FileName) -Force
} 
$OSBuilds |  ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder 'Microsoft_Windows_10.json') -Force

# Windows11
$TimeStamp = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
Write-Output "$TimeStamp`: Gathering Windows 11 Build Details"
$W11StaticDataFile = Join-Path $PSScriptRoot '\private\Microsoft_Windows_11_Static_Builds.json'
$OSBuilds = Get-OSBuilds -Product 'Windows 11' -Preview -OutofBand -StaticDataFile $W11StaticDataFile
$OSBuilds | Group-Object -Property ReleaseId | ForEach-Object {
    $FileName = "Microsoft_Windows_11_$($_.Name).json"
    $_.Group | ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder $FileName) -Force
} 
$OSBuilds |  ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder 'Microsoft_Windows_11.json') -Force

# Windows Server
$TimeStamp = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
Write-Output "$TimeStamp`: Gathering Windows Server Build Details"
$ServerStaticDataFile = Join-Path $PSScriptRoot '\private\Microsoft_Windows_Server_Static_Builds.json'
$OSBuilds = Get-OSBuilds -Product 'Windows Server' -Preview -OutofBand -StaticDataFile $ServerStaticDataFile
$OSBuilds | Group-Object -Property ReleaseId | ForEach-Object {
    $FileName = "Microsoft_Windows_Server_$($_.Name).json"
    $_.Group | ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder $FileName) -Force
} 
$OSBuilds |  ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder 'Microsoft_Windows_Server.json') -Force
