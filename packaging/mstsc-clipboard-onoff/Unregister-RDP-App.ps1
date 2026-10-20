param(
    [switch]$SkipSettings
)

$ErrorActionPreference = 'Stop'

$applicationId = 'MstscClipboardOnOff'
$progId = 'MstscClipboardOnOff.RdpFile'
$executable = Join-Path $PSScriptRoot 'mstscex.exe'
$applicationRoot = 'HKCU:\Software\Classes\Applications\mstscex.exe'
$registeredOpenCommand = "`"$executable`" `"%1`""

Remove-Item -LiteralPath "HKCU:\Software\Classes\$progId" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "HKCU:\Software\$applicationId" -Recurse -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -LiteralPath 'HKCU:\Software\Classes\.rdp\OpenWithProgids' -Name $progId `
    -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -LiteralPath 'HKCU:\Software\RegisteredApplications' -Name $applicationId `
    -Force -ErrorAction SilentlyContinue

$currentOpenCommand = $null

try {
    $currentOpenCommand = (Get-Item -LiteralPath "$applicationRoot\shell\open\command").GetValue('')
}
catch {
}

if ($currentOpenCommand -eq $registeredOpenCommand) {
    Remove-Item -LiteralPath $applicationRoot -Recurse -Force -ErrorAction SilentlyContinue
}

& (Join-Path $PSScriptRoot 'Remove-RdpEditSendTo.ps1')

if (-not ('AssociationRefresh' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class AssociationRefresh
{
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(uint eventId, uint flags, IntPtr item1, IntPtr item2);
}
'@
}

[AssociationRefresh]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)

if (-not $SkipSettings) {
    Start-Process 'ms-settings:defaultapps'
}

Write-Host 'MSTSC Clipboard On/Off registration was removed.'

if (-not $SkipSettings) {
    Write-Host 'If it was the default .rdp handler, choose another application in Windows Settings.'
}
