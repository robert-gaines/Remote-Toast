function GenerateLogfile
{
    $currentUser = $env:USERNAME

    $updateDirectory = Get-Location

    $year     = (Get-Date).Year
    $month    = (Get-Date).Month
    $day      = (Get-Date).Day
    $hours    = (Get-Date).TimeOfDay.Hours
    $minutes  = (Get-Date).TimeOfDay.Minutes
    $seconds  = (Get-Date).TimeOfDay.Seconds
    $tod      = "_"+[string]$year+'_'+[string]$month+'_'+[string]$day+"_"+[string]$hours+'_'+[string]$minutes+'_'+[string]$seconds+".log"
    $ts       = [string]$year+'-'+[string]$month+'-'+[string]$day+"-"+[string]$hours+':'+[string]$minutes+':'+[string]$seconds
    $fileName = "toast_endpoint_log"+$tod
    $logPath  = "C:\Users\$currentUser\Desktop\$fileName"
    $logFile = New-Item -Type File -Path $logPath | Out-Null

    Write-Host -ForegroundColor Magenta "[*] Log file created at: $logPath ... " ; Start-Sleep -Seconds 1

    return $logPath
}

$test = GenerateLogFile

Get-ChildItem C:\users\$env:USERNAME\Desktop\