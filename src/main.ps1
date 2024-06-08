$ExportFolder = Join-Path (Split-Path $PSScriptRoot) 'exports'
if (-not(Test-Path $ExportFolder)) {
    throw "$ExportFolder not found"
    return
}

# Import private functions
Get-ChildItem (Join-Path $PSScriptRoot 'private') *.ps1 | ForEach-Object { . $PSItem.FullName }

# Windows10
$OSBuilds = Get-OSBuilds -Product 'Windows 10' -Preview -OutofBand -Verbose
$OSBuilds | Group-Object -Property RelaseId | ForEach-Object {
    $FileName = "Microsoft_Windows_10_$($_.Name).json"
    $_.Group | ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder $FileName) -Force
} 
$OSBuilds |  ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder 'Microsoft_Windows_10.json') -Force

# Windows11
$OSBuilds = Get-OSBuilds -Product 'Windows 11' -Preview -OutofBand -Verbose
$OSBuilds | Group-Object -Property RelaseId | ForEach-Object {
    $FileName = "Microsoft_Windows_11_$($_.Name).json"
    $_.Group | ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder $FileName) -Force
} 
$OSBuilds |  ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder 'Microsoft_Windows_11.json') -Force

# Windows Server
$OSBuilds = Get-OSBuilds -Product 'Windows Server' -Preview -OutofBand -Verbose
$OSBuilds | Group-Object -Property RelaseId | ForEach-Object {
    $FileName = "Microsoft_Windows_Server_$($_.Name).json"
    $_.Group | ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder $FileName) -Force
} 
$OSBuilds |  ConvertTo-Json | Set-Content -Path (Join-Path $ExportFolder 'Microsoft_Windows_Server.json') -Force
