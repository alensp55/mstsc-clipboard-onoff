param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [string]$BuildDirectory,
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if ([string]::IsNullOrWhiteSpace($BuildDirectory)) {
    $BuildDirectory = Join-Path $repositoryRoot 'build-x64'
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repositoryRoot 'dist\mstsc-clipboard-onoff'
}

$binaryDirectory = Join-Path $BuildDirectory $Configuration
$packageSource = Join-Path $repositoryRoot 'packaging\mstsc-clipboard-onoff'
$exampleSource = Join-Path $repositoryRoot 'examples\clipboard-private.rdp'
$imageDirectory = Join-Path $repositoryRoot 'docs\images'
$imageFiles = @(
    (Join-Path $imageDirectory 'clipboard-toggle-menu-en.png'),
    (Join-Path $imageDirectory 'clipboard-toggle-menu-ru.png')
)
$files = @(
    (Join-Path $binaryDirectory 'mstscex.exe'),
    (Join-Path $binaryDirectory 'MsRdpEx.dll'),
    (Join-Path $repositoryRoot 'LICENSE'),
    (Join-Path $repositoryRoot 'README.md'),
    (Join-Path $repositoryRoot 'README.ru.md')
)

foreach ($file in $files + $imageFiles + $exampleSource) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required file was not found: $file"
    }
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $OutputDirectory 'docs\images') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $OutputDirectory 'examples') -Force | Out-Null

foreach ($file in $files) {
    Copy-Item -LiteralPath $file -Destination $OutputDirectory -Force
}

foreach ($file in $imageFiles) {
    Copy-Item -LiteralPath $file -Destination (Join-Path $OutputDirectory 'docs\images') -Force
}

Copy-Item -LiteralPath $exampleSource -Destination (Join-Path $OutputDirectory 'examples') -Force

Get-ChildItem -LiteralPath $packageSource -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $OutputDirectory -Force
}

Write-Host "Package created: $OutputDirectory"
