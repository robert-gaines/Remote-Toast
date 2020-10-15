<# Endpoint Toast Deployment Script #>


$ErrorActionPreference = 'SilentlyContinue'

function EmbedIcons()
{
    $timeStamp = TimeStamp ; Logger "[*] Icon embedding function called at -> $timeStamp "

    # Write-Host -ForegroundColor Green "[*] Embedding Icons... "

    $scriptDirectory = 'C:\Users\Public\Documents\FAISToastHandler\'

    $testDir = Test-Path -Path $scriptDirectory

    if(-not $testDir)
    {
        $timeStamp = TimeStamp ; Logger "[!] Failed to embed icons at -> $timeStamp | Directory: C:\Users\Public\Documents\FAISToastHandler was not found on $env:COMPUTERNAME "

        return
    }
    elseif($testDir) 
    {
        $timeStamp = TimeStamp ; Logger "[*] Directory C:\Users\Public\Documents\FAISToastHandler was identified on $env:COMPUTERNAME at -> $timeStamp "

        try 
        {
            Copy-Item  -Path '.\standard.ico' -Destination $scriptDirectory | Out-Null
            Copy-Item  -Path '.\info.ico'     -Destination $scriptDirectory | Out-Null
            Copy-Item  -Path '.\alert.ico'    -Destination $scriptDirectory | Out-Null 
            Copy-Item  -Path '.\warning.ico'  -Destination $scriptDirectory | Out-Null  

            $timeStamp = TimeStamp ; Logger "[*] Toast message icons successfully copied to C:\Users\Public\Documents\FAISToastHandler on $env:COMPUTERNAME at -> $timeStamp "
        }
        catch 
        {
            $timeStamp = TimeStamp ; Logger "[*] Toast message icons were not embedded | Icons were in place or otherwise inaccessible -> $timeStamp "

            return
        }
    }
    else 
    {
        return    
    }
}

function EmbedScript($scriptName)
{
    # Write-Host -ForegroundColor Green "[*] Embedding the script "

    $timeStamp = TimeStamp ; Logger "[*] Script embedding function called at -> $timeStamp "

    $scriptDirectoryExists = Test-Path -Path "C:\Users\Public\Documents\FAISToastHandler" | Out-Null

    $scriptFileExists      = Test-Path -Path "C:\Users\Public\Documents\FAISToastHandler\$scriptName" 

    if($scriptDirectoryExists -and $scriptFileExists)
    {
        $timeStamp = TimeStamp ; Logger "[*] Directory C:\Users\Public\Documents\FAISToastHandler already exists on $env:COMPUTERNAME : $timeStamp "

        return
    }
    else
    {
        try
        {
            New-Item -ItemType Directory -Path "C:\Users\Public\Documents\" -Name "FAISToastHandler" | Out-Null

            $timeStamp = TimeStamp ; Logger "[*] Created directory C:\Users\Public\Documents\FAISToastHandler on $env:COMPUTERNAME at -> $timeStamp "

            Copy-Item -Path $scriptName -Destination "C:\Users\Public\Documents\FAISToastHandler\"   | Out-Null 

            $timeStamp = TimeStamp ; Logger "[*] Copied endpoint script to C:\Users\Public\Documents\FAISToastHandler at -> $timeStamp "
        }
        catch
        {
            return
        }
    }
    return
}

function SetScheduledTask()
{
    # Write-Host -ForegroundColor Green "[*] Registering the scheduled task "

    $timeStamp = TimeStamp ; Logger "[*] Scheduled task registration function called at -> $timeStamp "

    try 
    {
        $action = New-ScheduledTaskAction -Execute "powershell.exe C:\Users\Public\Documents\FAISToastHandler\EndpointToastHandler.exe"

        $user = "NT AUTHORITY\SYSTEM"

        $trigger = New-ScheduledTaskTrigger -AtLogOn

        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "FAIS Toast Endpoint" -User $user -Description "Handler for Toast Messages" -RunLevel Highest -Force -ErrorAction SilentlyContinue | Out-Null

        $timeStamp = TimeStamp ; Logger "[*] Scheduled task for endpoint script registered at -> $timeStamp "
    }
    catch 
    {
        $timeStamp = TimeStamp ; Logger "[!] Scheduled task registration for the endpoint failed at -> $timeStamp "

        return
    }  
}

function SetPersistence()
{
   # Write-Host -ForegroundColor Green "[*] Setting Persistence "

   $timeStamp = TimeStamp ; Logger "[*] Set Persistence function called at: $timeStamp "

   $queryPersistence = reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v FAISToastHandler 

   if($queryPersistence.split(' ')[6] -ne "FAISToastHandler")
   {
    try
    {
         reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v FAISToastHandler /t REG_SZ /d "C:\Users\Public\Documents\FAISToastHandler\EndpointToastHandler.exe /noconsole" | Out-Null
 
         $timeStamp = TimeStamp ; Logger "[*] Created autorun entry in the registry for FAIS Toast Endpoint script at: $timeStamp "

         return
    }
    catch
    {
         $timeStamp = TimeStamp ; Logger "[!] Failed to create autorun entry in the registry for the FAIS Toast Endpoint script at: $timeStamp "
 
         return
    }
   }
   else 
   {
        return    
   }
}

function AddFirewallRule()
{
    $timeStamp = TimeStamp ; Logger "[*] Initiated Firewall Rule Addition function at: $timeStamp "

    # Write-Host -ForegroundColor Green "[*] Adding Firewall Rule for Endpoint Handler... "

    try
    {
        New-NetFirewallRule -DisplayName "FAIS-Toast-Endpoint" -Action Allow -Direction Inbound -LocalPort 3247 -Enabled True -Protocol TCP -ErrorAction SilentlyContinue | Out-Null

        # Write-Host -ForegroundColor Green "[*] New Firewall Rule: 'FAIS-Toast-Endpoint' Successfully Added "

        $timeStamp = TimeStamp ; Logger "[*] Host firewall rule: 'FAIS-Toast-Endpoint' successfully added at: $timeStamp "
    }
    catch
    {
        # Write-Host -ForegroundColor Red "[!] Failed to add host firewall rule for the endpoint handler " ; Start-Sleep -Seconds 1

        $timeStamp = TimeStamp ; Logger "[!] Failed to add host firewall rule at: $timeStamp "
    }
}

function GenerateLogfile
{
    # Write-Host -ForegroundColor Green "[*] Generating log file..."

    $year     = (Get-Date).Year
    $month    = (Get-Date).Month
    $day      = (Get-Date).Day
    $hours    = (Get-Date).TimeOfDay.Hours
    $minutes  = (Get-Date).TimeOfDay.Minutes
    $seconds  = (Get-Date).TimeOfDay.Seconds
    $tod      = "_"+[string]$year+'_'+[string]$month+'_'+[string]$day+"_"+[string]$hours+'_'+[string]$minutes+'_'+[string]$seconds+".log"
    $ts       = [string]$year+'-'+[string]$month+'-'+[string]$day+"-"+[string]$hours+':'+[string]$minutes+':'+[string]$seconds
    $fileName = "toast_endpoint_log"+$tod

    <# Create the Log Directory & File #>

    $logPath = "C:\Users\Public\Documents\FAISEndpointToast_Log"

    $logFilePath = "C:\Users\Public\Documents\FAISEndpointToast_Log\$fileName"

    $testLogPath = Test-Path -Path $logPath

    if(-not $testLogPath)
    {
        try
        {
           New-Item -ItemType Directory -Path "C:\Users\Public\Documents\" -Name "FAISEndpointToast_Log" | Out-Null

           try
           {
             New-Item -ItemType File -Path $logFilePath | Out-Null

             return $logFilePath
           }
           catch
           {
             return
           }
        }
        catch
        {
          return
        }
    }
    elseif($testLogPath)
    {
        $logFile = New-Item -Type File -Path $logFilePath | Out-Null

        return $logFilePath
    }
    else
    {
        New-Item -Type File -Path C:\Users\Public\Documents\ -Name $fileName | Out-Null

        $logFilePath = "C:\Users\Public\Documents\$fileName"

        return $logFilePath
    }
}

function TimeStamp
{
    $year     = (Get-Date).Year
    $month    = (Get-Date).Month
    $day      = (Get-Date).Day
    $hours    = (Get-Date).TimeOfDay.Hours
    $minutes  = (Get-Date).TimeOfDay.Minutes
    $seconds  = (Get-Date).TimeOfDay.Seconds
    $ts       = [string]$year+'-'+[string]$month+'-'+[string]$day+"-"+[string]$hours+':'+[string]$minutes+':'+[string]$seconds

    return $ts
}

function Logger
{
    Param([string]$logstring)

    Add-Content $logfile -value $logstring
}

function main()
{
    EmbedScript $scriptName

    AddFirewallRule

    SetPersistence

    #SetScheduledTask

    EmbedIcons

    #ClientHandler

    try 
    {
        # Write-Host -FOregroundColor Green "[*] Calling embedded script... "

        Start-Process -FilePath "C:\Users\Public\Documents\FAISToastHandler\EndpointToastHandler.exe" -NoNewWindow

        $checkProcess = Get-Process -ProcessName EndpointToastHandler -ErrorAction SilentlyContinue
        
        if($checkProcess)
        {
            Write-Host -ForegroundColor Green "[*] Endpoint handler started on 0.0.0.0:3247 "

            Start-Sleep -Seconds 3

            exit
        }

        $timeStamp = TimeStamp ; Logger "[*] Started the embedded endpoint handler at: $timeStamp "
    }
    catch 
    {
        $timeStamp = TimeStamp ; Logger "[!] Failed to start the embedded endpoint handler at: $timeStamp "

        exit
    }
}

Write-Host -ForegroundColor Green "[*] Deploying Toast Endpoint Handler "

# $MyInvocation.InvocationName

$scriptName = "EndpointToastHandler.exe" 

$logfile    = GenerateLogfile

$timeStamp  = TimeStamp ; Logger "[*] FAIS TOAST Endpoint Handler started at: $timeStamp "

main
