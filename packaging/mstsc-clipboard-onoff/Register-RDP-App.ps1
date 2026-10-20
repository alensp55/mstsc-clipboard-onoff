param(
    [switch]$SkipSettings
)

$ErrorActionPreference = 'Stop'

$applicationId = 'MstscClipboardOnOff'
$applicationName = 'MSTSC Clipboard On/Off'
$progId = 'MstscClipboardOnOff.RdpFile'
$executable = Join-Path $PSScriptRoot 'mstscex.exe'
$classesRoot = 'HKCU:\Software\Classes'
$progIdRoot = Join-Path $classesRoot $progId
$applicationRoot = Join-Path $classesRoot 'Applications\mstscex.exe'
$capabilitiesRoot = "HKCU:\Software\$applicationId\Capabilities"
$openCommand = "`"$executable`" `"%1`""

if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw "mstscex.exe was not found next to this script: $executable"
}

New-Item -Path $progIdRoot -Force | Out-Null
Set-Item -Path $progIdRoot -Value 'Remote Desktop Connection (Clipboard On/Off)'

New-Item -Path "$progIdRoot\DefaultIcon" -Force | Out-Null
Set-Item -Path "$progIdRoot\DefaultIcon" -Value "`"$executable`",0"

New-Item -Path "$progIdRoot\shell\open\command" -Force | Out-Null
Set-Item -Path "$progIdRoot\shell\open\command" -Value $openCommand

New-Item -Path "$applicationRoot\shell\open\command" -Force | Out-Null
Set-Item -Path "$applicationRoot\shell\open\command" -Value $openCommand

New-Item -Path "$classesRoot\.rdp\OpenWithProgids" -Force | Out-Null
& "$env:SystemRoot\System32\reg.exe" add 'HKCU\Software\Classes\.rdp\OpenWithProgids' `
    /v $progId /t REG_NONE /f | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "Failed to add $progId to the .rdp OpenWithProgids list."
}

New-Item -Path "$capabilitiesRoot\FileAssociations" -Force | Out-Null
New-ItemProperty -Path $capabilitiesRoot -Name 'ApplicationName' -Value $applicationName -Force | Out-Null
New-ItemProperty -Path $capabilitiesRoot -Name 'ApplicationDescription' `
    -Value 'Microsoft Remote Desktop launcher with runtime clipboard synchronization control.' -Force | Out-Null
New-ItemProperty -Path "$capabilitiesRoot\FileAssociations" -Name '.rdp' -Value $progId -Force | Out-Null

New-Item -Path 'HKCU:\Software\RegisteredApplications' -Force | Out-Null
New-ItemProperty -Path 'HKCU:\Software\RegisteredApplications' -Name $applicationId `
    -Value "Software\$applicationId\Capabilities" -Force | Out-Null

& (Join-Path $PSScriptRoot 'Add-RdpEditSendTo.ps1')

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
    Start-Process 'ms-settings:defaultapps?registeredAppUser=MstscClipboardOnOff'
}

Write-Host "$applicationName is registered for .rdp files."

if (-not $SkipSettings) {
    Write-Host 'In Windows Settings, select the application for the .rdp extension.'
}
