$ErrorActionPreference = 'SilentlyContinue'

Write-Host -ForegroundColor Yellow "[*] Starting Cleanup ..." ; Start-Sleep -Seconds 1

Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\" -Name FAISToastHandler

try
{
    Stop-Process -ProcessName EndpointToastHandler
}
catch
{
    continue
}

$check_directory = Test-Path -Path C:\Users\Public\Documents\FAISToastHandler

if($check_directory)
{
    Write-Host -ForegroundColor Green "[*] Located program directory "

    Remove-Item -Path C:\Users\Public\Documents\FAISToastHandler -Recurse | Out-Null
}

$check_log_dir_server = Test-Path -Path C:\Users\Public\Documents\FAISEndpointToast_Log 

if($check_log_dir_server)
{
    Write-Host -ForegroundColor Green "[*] Located endpoint log directory "

    Remove-Item -Path C:\Users\Public\Documents\FAISEndpointToast_Log -Recurse | Out-Null
}

$check_log_dir_client = Test-Path -Path C:\Users\Public\Documents\FAISToastClient_Log -Recurse | Out-Null

if($check_log_dir_client)
{
    Write-Host -ForegroundColor Green "[*] Located client directory "

    Remove-Item -Path C:\Users\Public\Documents\FAISToastClient_Log -Recurse | Out-Null
}

Write-Host -ForegroundColor Green "[*] Cleanup finished " ; Start-Sleep -Seconds 3 

