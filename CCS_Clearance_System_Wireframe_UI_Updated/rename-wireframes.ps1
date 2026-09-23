[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$WireframesPath
)

if ([string]::IsNullOrWhiteSpace($WireframesPath)) {
    $scriptDirectory = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { (Get-Location).Path } else { $PSScriptRoot }
    $WireframesPath = Join-Path $scriptDirectory 'wireframes'
}

$targetNames = @(
    'Clearance - Cashier Dashboard 2.png'
    'Clearance - Cashier Dashboard.png'
    'Clearance - Cashier Section Clearance.png'
    'Clearance - Cashier Settings.png'
    'Clearance - Class Adviser Advisory Section.png'
    'Clearance - Class Adviser Dashboard.png'
    'Clearance - Class Adviser Requirements.png'
    'Clearance - Class Adviser Settings.png'
    'Clearance - Clearance Status.png'
    'Clearance - Dean Dashboard 2.png'
    'Clearance - Dean Dashboard.png'
    'Clearance - Laboratory Dashboard.png'
    'Clearance - Laboratory Requirement Clearance.png'
    'Clearance - Laboratory Section Clearance .png'
    'Clearance - Laboratory Settings.png'
    'Clearance - Library Dashboard.png'
    'Clearance - Library Requirement Clearance.png'
    'Clearance - Library Section Clearance.png'
    'Clearance - Library Settings.png'
    'Clearance - Login Page.png'
    'Clearance - Printable Clearance.png'
    'Clearance - Register Page.png'
    'Clearance - Settings.png'
    'Clearance - Student Dashboard.png'
    'Clearance - Student Developer Services Dashboard.png'
    'Clearance - Student Developer Services Requirements.png'
    'Clearance - Student Developer Services Section.png'
    'Clearance - Student Developer Services Settings .png'
)

if (-not (Test-Path -LiteralPath $WireframesPath -PathType Container)) {
    throw "Wireframes folder not found: $WireframesPath"
}

$sourceFiles = @(Get-ChildItem -LiteralPath $WireframesPath -File | Sort-Object Name)
if ($sourceFiles.Count -ne $targetNames.Count) {
    throw "Expected $($targetNames.Count) files, but found $($sourceFiles.Count) in $WireframesPath. No files were renamed."
}

$duplicateTargets = @($targetNames | Group-Object | Where-Object Count -gt 1)
if ($duplicateTargets.Count -gt 0) {
    throw 'The target list contains duplicate names. No files were renamed.'
}

$operations = for ($index = 0; $index -lt $sourceFiles.Count; $index++) {
    [pscustomobject]@{
        Source = $sourceFiles[$index]
        Target = Join-Path $WireframesPath $targetNames[$index]
    }
}

$operations | ForEach-Object {
    Write-Host ("{0}  ->  {1}" -f $_.Source.Name, (Split-Path $_.Target -Leaf))
}

if ($WhatIfPreference) {
    Write-Host 'Dry run complete. No files were renamed.'
    exit 0
}

if (-not $WhatIfPreference) {
    $confirmation = Read-Host 'Rename these files? Type YES to continue'
    if ($confirmation -cne 'YES') {
        Write-Host 'Cancelled. No files were renamed.'
        exit 0
    }
}

$staged = @()
try {
    foreach ($operation in $operations) {
        $temporaryName = "__wireframe-rename-$([guid]::NewGuid().ToString('N'))$($operation.Source.Extension)"
        $temporaryPath = Join-Path $WireframesPath $temporaryName
        Rename-Item -LiteralPath $operation.Source.FullName -NewName $temporaryName -ErrorAction Stop
        $staged += [pscustomobject]@{ Temporary = $temporaryPath; Target = $operation.Target }
    }

    foreach ($operation in $staged) {
        Rename-Item -LiteralPath $operation.Temporary -NewName (Split-Path $operation.Target -Leaf) -ErrorAction Stop
    }

    Write-Host "Renamed $($operations.Count) wireframes successfully."
}
catch {
    Write-Error $_
    Write-Warning 'The operation stopped. Temporary filenames may remain in the wireframes folder.'
    throw
}
