# This script writes a new log entry at the specified interval indefinitely.
# Usage:
# .\GenerateCustomLogs.ps1 [interval to sleep]
#
# Press Ctrl+C to terminate script.
#
# Example:
# .\ GenerateCustomLogs.ps1 5

param (
    [Parameter(Mandatory=$true)][int]$sleepSeconds
)

$logFolder = "c:\\Temp"
if (!(Test-Path -Path $logFolder))
{
    mkdir $logFolder
}

$computerName = $env:COMPUTERNAME

$logFileName = "dbaudit-$(Get-Date -format yyyyMMddhhmm).log"
$db_syslog_sample = Get-Content -Path "$logFolder\\db_syslog_sample.txt"

foreach($logline in $db_syslog_sample){
    $logrecord = $logline.Substring(33,$logline.Length-33)
    $logrecord =  "$(Get-Date -format s).000000+00:00 $($logrecord)"
    Write-Host $logrecord
    $logrecord | Out-File "$logFolder\\$logFileName" -Encoding utf8 -Append
    Start-Sleep (Get-Random $sleepSeconds)
}
