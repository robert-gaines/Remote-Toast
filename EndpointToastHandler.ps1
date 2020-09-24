<# Toast Endpoint Script #>

<# Import the Required Assemblies to Support Toast Messages via XML #>

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]        | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]          | Out-Null

<# Begin Primary Script #>

$ErrorActionPreference = 'SilentlyContinue'

function GenerateWarningNotification($message)
{
    [xml]$ToastTemplate = @"
    <toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text> WSU FAIS - Warning! </text>
            <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\Public\Documents\FAISToastHandler\warning.ico"/>
            <text placement="attribution">WSU FAIS</text>
            <text> Warning! </text>
            <group>
             <subgroup>     
                <text hint-style="body" hint-wrap="true">
                 $message
                </text> 
             </subgroup>
            </group>
        </binding>
    </visual>
    <actions>
        <action activationType="background" content="Snooze" arguments="later"/>
        <action activationType="background" content="Dismiss" arguments="dismiss"/>
    </actions>
    </toast>
"@

    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($ToastTemplate.OuterXML)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)
}
function GenerateAlertNotification($message)
{
    [xml]$ToastTemplate = @"
    <toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text> WSU FAIS - Alert! </text>
            <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\Public\Documents\FAISToastHandler\alert.ico"/>
            <text placement="attribution">WSU FAIS</text>
            <text>WSU FAIS Alert!</text>
            <group>
             <subgroup>     
                <text hint-style="body" hint-wrap="true">
                 $message
                </text> 
             </subgroup>
            </group>
        </binding>
    </visual>
    <actions>
        <action activationType="background" content="Snooze" arguments="later"/>
        <action activationType="background" content="Dismiss" arguments="dismiss"/>
    </actions>
    </toast>
"@

    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($ToastTemplate.OuterXML)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)
}
function GenerateInformationNotification($message)
{
    [xml]$ToastTemplate = @"
    <toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text> FAIS Alert! </text>
            <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\Public\Documents\FAISToastHandler\info.ico"/>
            <text placement="attribution">WSU FAIS</text>
            <text>General Information Notification</text>
            <group>
             <subgroup>     
                <text hint-style="body" hint-wrap="true">
                 $message
                </text> 
             </subgroup>
            </group>
        </binding>
    </visual>
    <actions>
        <action activationType="background" content="Snooze" arguments="later"/>
        <action activationType="background" content="Dismiss" arguments="dismiss"/>
    </actions>
    </toast>
"@

    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($ToastTemplate.OuterXML)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)
}

function GenerateStandardNotification($message)
{
[xml]$HeroToastTemplate = @"
<toast scenario="None">
    <visual>
    <binding template="ToastGeneric">
        <image placement="hero" src="C:\Temp\wsu.ico"/>
        <image id="1" placement="appLogoOverride" src="C:\Users\Public\Documents\FAISToastHandler\Standard.ico"/>
        <text placement="attribution">WSU FAIS</text>
        <text>WSU F.A.I.S.</text>
        <group>
            <subgroup>
                <text hint-style="title" hint-wrap="true" >Routine Notification </text>
            </subgroup>
        </group>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" > Notification content follows: </text>
            </subgroup>
        </group>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" > $message </text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <actions>
        <action activationType="system" arguments="snooze" content="Snooze"/>
        <action activationType="system" arguments="dismiss" content="Dismiss"/>
    </actions>
</toast>
"@

$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($HeroToastTemplate.OuterXML)
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)

}
function ClientHandler()
{
    $timeStamp = TimeStamp ; Logger "[*] Endpoint handler function called at -> $timeStamp "

    $socket = New-Object System.Net.IPEndPoint([IPAddress]::Any,3247)

    $timeStamp = TimeStamp ; Logger "[*] Socket object instantiated at -> $timeStamp "

    $handler = New-Object System.Net.Sockets.TCPListener $socket 

    $timeStamp = TimeStamp ; Logger "[*] Socket object bound at -> $timeStamp "

    $handler.Start()

    $timeStamp = TimeStamp ; Logger "[*] Server loop initiated at -> $timeStamp "

    Write-Host -ForegroundColor Green "[*] Listening on: 0.0.0.0:3247 "

    while($true)
    {
        $client = $handler.AcceptTCPClient()

        if($client)
        {
            $remoteAddress = $client.Client.RemoteEndPoint.Address
            $remotePort    = $client.Client.RemoteEndPoint.Port 
            $timeStamp     = Get-Date

            Write-Host -ForegroundColor Green "[*] $timeStamp - Connection from: <$remoteAddress|$remotePort>  "

            $timeStamp = TimeStamp ; Logger "[*] Client connection from: <$remoteAddress|$remotePort> at -> $timeStamp "

            $stream = $client.GetStream()

            $bytes = New-Object System.Byte[] 1024

            $encodingScheme = New-Object System.Text.ASCIIEncoding

            while(($var = $stream.Read($bytes,0,$bytes.Length)) -ne 0)
            {
                $plaintext    = $encodingScheme.GetString($bytes,0,$var)

                $segments     = $plaintext.Split(' ')

                $message_type = $segments[0]
                
                $message      = ''

                if($segments)
                {
                    for($i = 1; $i -lt $segments.length; $i++)
                    {
                        $message = $message + $segments[$i] + ' '
                    }
                }

                switch($message_type)
                {
                    "Standard"    { Write-Host -ForegroundColor Green "[*] Message received from <$remoteAddress|$remotePort> | Toast Format: $message_type " ; GenerateStandardNotification($message)    ; $timeStamp = TimeStamp ; Logger "[*] Remote user at: <$remoteAddress|$remotePort> sent $message   at -> $timeStamp "    }
                    "Information" { Write-Host -ForegroundColor Green "[*] Message received from <$remoteAddress|$remotePort> | Toast Format: $message_type " ; GenerateInformationNotification($message) ; $timeStamp = TimeStamp ; Logger "[*] Remote user at: <$remoteAddress|$remotePort> sent $message   at -> $timeStamp "    }
                    "Alert"       { Write-Host -ForegroundColor Green "[*] Message received from <$remoteAddress|$remotePort> | Toast Format: $message_type " ; GenerateAlertNotification($message)       ; $timeStamp = TimeStamp ; Logger "[*] Remote user at: <$remoteAddress|$remotePort> sent $message   at -> $timeStamp "    }
                    "Warning"     { Write-Host -ForegroundColor Green "[*] Message received from <$remoteAddress|$remotePort> | Toast Format: $message_type " ; GenerateWarningNotification($message)     ; $timeStamp = TimeStamp ; Logger "[*] Remote user at: <$remoteAddress|$remotePort> sent $message   at -> $timeStamp "    }
                    default       { Write-Host -ForegroundColor Green "[*] Message received from <$remoteAddress|$remotePort> | Toast Format: $message_type " ; GenerateStandardNotification($message)    ; $timeStamp = TimeStamp ; Logger "[*] Remote user at: <$remoteAddress|$remotePort> sent $message   at -> $timeStamp " ; break  }
                }
            }
            $stream.Close()
            $client.Close()

            $timeStamp = TimeStamp ; Logger "[*] Closed client connection from: <$remoteAddress|$remotePort> at -> $timeStamp "
        }
    }
}

function KillSwitch()
{
    try 
    {
        reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v FAISToastHandler | Out-Null

        return
    }
    catch 
    {
        return    
    }
}

function EmbedIcons()
{
    $timeStamp = TimeStamp ; Logger "[*] Icon embedding function called at -> $timeStamp "

    Write-Host -ForegroundColor Green "[*] Embedding Icons... "

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
    Write-Host -ForegroundColor Green "[*] Embedding the script "

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
    Write-Host -ForegroundColor Green "[*] Registering the scheduled task "

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
   Write-Host -ForegroundColor Green "[*] Setting Persistence "

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

    Write-Host -ForegroundColor Green "[*] Adding Firewall Rule for Endpoint Handler... "

    try
    {
        New-NetFirewallRule -DisplayName "FAIS-Toast-Endpoint" -Action Allow -Direction Inbound -LocalPort 3247 -Enabled True -Protocol TCP | Out-Null

        Write-Host -ForegroundColor Green "[*] New Firewall Rule: 'FAIS-Toast-Endpoint' Successfully Added "

        $timeStamp = TimeStamp ; Logger "[*] Host firewall rule: 'FAIS-Toast-Endpoint' successfully added at: $timeStamp "
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to add host firewall rule for the endpoint handler " ; Start-Sleep -Seconds 1

        $timeStamp = TimeStamp ; Logger "[!] Failed to add host firewall rule at: $timeStamp "
    }
}

function GenerateLogfile
{
    Write-Host -ForegroundColor Green "[*] Generating log file..."

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

    ClientHandler
}

Write-Host -ForegroundColor Green "[*] Starting Toast Endpoint Handler "

# $MyInvocation.InvocationName

$scriptName = "EndpointToastHandler.exe" 

$logfile    = GenerateLogfile

$timeStamp  = TimeStamp ; Logger "[*] FAIS TOAST Endpoint Handler started at: $timeStamp "

main

<#

    XML Templates

#>

[xml]$ToastTemplate = @"
    <toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text>System Uptime Warning</text>
            <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\robert.gaines\Desktop\Powershell\Toast\Prototype\alert.ico"/>
            <group>
             <subgroup>     
                <text hint-style="body" hint-wrap="true">

                </text> 
             </subgroup>
            </group>
        </binding>
    </visual>
    <actions>
        <action activationType="background" content="Snooze" arguments="later"/>
        <action activationType="background" content="Dismiss" arguments="dismiss"/>
    </actions>
  </toast>
"@
