$ErrorActionPreference = 'Stop'

$sendToDirectory = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Microsoft\Windows\SendTo'
$shortcutName = if ([Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -eq 'ru') {
    'Изменить RDP.lnk'
}
else {
    'Edit RDP.lnk'
}
$shortcutPath = Join-Path $sendToDirectory $shortcutName
$mstscPath = Join-Path $env:SystemRoot 'System32\mstsc.exe'
$wshShell = $null
$shortcut = $null

New-Item -ItemType Directory -Path $sendToDirectory -Force | Out-Null

try {
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $mstscPath
    $shortcut.Arguments = '-edit'
    $shortcut.WorkingDirectory = Split-Path -Parent $mstscPath
    $shortcut.IconLocation = "$mstscPath,0"
    $shortcut.Description = 'Open the selected RDP file in the Microsoft settings editor'
    $shortcut.Save()
}
finally {
    if ($shortcut) {
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($shortcut)
    }

    if ($wshShell) {
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($wshShell)
    }
}

Write-Host "Created: $shortcutPath"
