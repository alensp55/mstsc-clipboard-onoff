$ErrorActionPreference = 'Stop'

$sendToDirectory = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Microsoft\Windows\SendTo'
$shortcutNames = @('Edit RDP.lnk', 'Изменить RDP.lnk')
$mstscPath = Join-Path $env:SystemRoot 'System32\mstsc.exe'
$wshShell = New-Object -ComObject WScript.Shell

try {
    foreach ($shortcutName in $shortcutNames) {
        $shortcutPath = Join-Path $sendToDirectory $shortcutName

        if (-not (Test-Path -LiteralPath $shortcutPath -PathType Leaf)) {
            continue
        }

        $shortcut = $wshShell.CreateShortcut($shortcutPath)

        try {
            if ($shortcut.TargetPath -ieq $mstscPath -and $shortcut.Arguments -eq '-edit') {
                Remove-Item -LiteralPath $shortcutPath -Force
                Write-Host "Removed: $shortcutPath"
            }
            else {
                Write-Warning "Unrelated shortcut left unchanged: $shortcutPath"
            }
        }
        finally {
            [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($shortcut)
        }
    }
}
finally {
    [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($wshShell)
}
