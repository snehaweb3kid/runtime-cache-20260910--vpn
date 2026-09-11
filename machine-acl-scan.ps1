$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$base = ([ADSI]"LDAP://RootDSE").defaultNamingContext
$root = [ADSI]("LDAP://" + $base)

$machineName = $env:COMPUTERNAME + "$"
$m = New-Object DirectoryServices.DirectorySearcher($root)
$m.Filter = "(&(objectCategory=computer)(sAMAccountName=$machineName))"
$m.PropertiesToLoad.AddRange(@("objectSid", "distinguishedName"))
$machine = $m.FindOne()
if (-not $machine) {
    Write-Output "MACHINE_LOOKUP_FAILED=$machineName"
    exit 1
}

$machineSid = New-Object Security.Principal.SecurityIdentifier(
    ([byte[]]$machine.Properties.item("objectSid")[0]), 0
)
Write-Output "MACHINE_SID=$machineSid"

$s = New-Object DirectoryServices.DirectorySearcher($root)
$s.PageSize = 500
$s.Filter = "(&(|(objectCategory=user)(objectCategory=group)(objectCategory=computer)(objectCategory=organizationalUnit)(objectCategory=container))(nTSecurityDescriptor=*))"
$s.PropertiesToLoad.AddRange(@("sAMAccountName", "distinguishedName", "nTSecurityDescriptor"))

foreach ($entry in $s.FindAll()) {
    $raw = $entry.Properties.item("nTSecurityDescriptor")[0]
    if (-not $raw) {
        continue
    }
    $acl = New-Object DirectoryServices.ActiveDirectorySecurity
    $acl.SetSecurityDescriptorBinaryForm([byte[]]$raw)
    foreach ($rule in $acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
        if ($rule.IdentityReference.Value -ne $machineSid.Value) {
            continue
        }
        $target = [string]$entry.Properties.item("sAMAccountName")[0]
        if (-not $target) {
            $target = [string]$entry.Properties.item("distinguishedName")[0]
        }
        Write-Output (
            "ACE=" + $target +
            "|DN=" + [string]$entry.Properties.item("distinguishedName")[0] +
            "|RIGHTS=" + $rule.ActiveDirectoryRights +
            "|TYPE=" + $rule.AccessControlType
        )
    }
}
Write-Output "MACHINE_ACL_SCAN_DONE"
