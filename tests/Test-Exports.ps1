Get-ChildItem -Path (Join-Path (Split-Path $PSScriptRoot) 'exports') *.json | ForEach-Object {
    $jsonContent = Get-Content -Path $_.FullName -Raw
    if (-not $jsonContent) {
        throw "Output JSON file is empty or not found."
    }
    try {
        $parsedJson = $jsonContent | ConvertFrom-Json
    }
    catch {
        throw "Output file $($_.Name) is not valid JSON."
    } 
}