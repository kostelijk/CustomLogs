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

$logFileName = "TestLog-$(Get-Date -format yyyyMMddhhmm).log"
do
{
    $count++
    $randomContent = New-Guid
    $logRecord = "$(Get-Date -format s)Z : $computerName  :$(Get-Random -Maximum 10):Record number $count with random content $randomContent"
    Write-Host $logRecord
    $logRecord | Out-File "$logFolder\\$logFileName" -Encoding utf8 -Append
    Start-Sleep $sleepSeconds
}
while ($true)