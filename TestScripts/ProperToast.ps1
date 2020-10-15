[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]        | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]          | Out-Null

try
{
    Import-Module -Name BurntToast
}
catch
{
    exit
}

$BasicTemplate = @"
<toast>
    <visual>
        <binding template="ToastText02">
            <text id="1">$('Title')</text>
            <text id="2">$(Get-Date -Format 'HH:mm:ss')</text>
        </binding>
    </visual>
</toast>
"@

[xml]$ToastTemplate = @"
<toast launch="app-defined-string">
  <visual>
    <binding template="ToastGeneric">
      <text>DNS Alert...</text>
      <text>Sample Text</text>
    </binding>
  </visual>
  <actions>
    <action activationType="background" content="Snooze" arguments="later"/>
    <action activationType="background" content="Dismiss" arguments="dismiss"/>
  </actions>
</toast>
"@

[xml]$HeroToast = @"
<toast scenario="$Scenario">
    <visual>
    <binding template="ToastGeneric">
        <image placement="hero" src="http://support.mme.wsu.edu/useful%20bits/Logos/WSU-Logo_Vert-CMYK.png"/>
        <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\robert.gaines\Desktop\Main\InProgress\wsu_dark.jpg"/>
        <text placement="attribution">'Sample'</text>
        <text>Header</text>
        <group>
            <subgroup>
                <text hint-style="title" hint-wrap="true" >Title</text>
            </subgroup>
        </group>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" >Body</text>
            </subgroup>
        </group>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" >Body - Two</text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <actions>
        <action activationType="protocol" arguments="snooze" content="Snooze" />
        <action activationType="system" arguments="dismiss" content="Dismiss"/>
    </actions>
</toast>
"@

function ConfigureRegistryReboot()
{
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    
    $ProtocolHandler = Get-Item 'HKCR:\ToastRebootCallback' -ErrorAction 'SilentlyContinue'

    if (!$ProtocolHandler) 
    {
        try
        {
            New-Item 'HKCR:\ToastRebootCallback' -force
            Set-Itemproperty 'HKCR:\ToastRebootCallback' -name '(DEFAULT)' -value 'url:ToastRebootCallback' -force
            Set-Itemproperty 'HKCR:\ToastRebootCallback' -name 'URL Protocol' -value '' -force
            New-Itemproperty -Path 'HKCR:\ToastRebootCallback' -propertytype DWORD -name 'EditFlags' -value 2162688
            New-Item 'HKCR:\ToastRebootCallback\Shell\Open\command' -force
            Set-Itemproperty 'HKCR:\ToastRebootCallback\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe \r \t 0' -Force
        }
        catch
        {
            return
        }
    }
    else
    {
        return
    }
}

function PromptReboot()
{
    $text1 = New-BTText -Content  "FAIS Notification"
    $text2 = New-BTText -Content "Updates were installed on your computer"
    $text3 = New-BTText -Content "A restart is required"
    $Button = New-BTButton -Content "Snooze" -snooze -id 'snooze'
    $Button2 = New-BTButton -Content "Dismiss" -snooze -id 'dismiss'
    $Button3 = New-BTButton -Content "Reboot" -Arguments "ToastRebootCallback:" -ActivationType Protocol
    $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
    $action = New-BTAction -Buttons $Button, $Button2,$Button3
    $Binding = New-BTBinding -Children $text1,$text2,$text3
    $Visual = New-BTVisual -BindingGeneric $Binding
    $Content = New-BTContent -Visual $Visual -Actions $action
    Submit-BTNotification -Content $Content
}

function ConfigureRegistrySCClient()
{
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    
    $ProtocolHandler = Get-Item 'HKCR:\ToastSCCallback' -ErrorAction 'SilentlyContinue'

    if (!$ProtocolHandler) 
    {
        try
        {
            New-Item 'HKCR:\ToastSCCallback' -Force
            Set-Itemproperty 'HKCR:\ToastSCCallback' -Name '(DEFAULT)' -value 'url:ToastSCCallback' -force
            Set-Itemproperty 'HKCR:\ToastSCCallback' -Name 'URL Protocol' -Value '' -Force
            New-Itemproperty -Path 'HKCR:\ToastSCCallback' -Propertytype DWORD -name 'EditFlags' -value 2162688
            New-Item 'HKCR:\ToastSCCallback\Shell\Open\command' -Force
            Set-Itemproperty 'HKCR:\ToastSCCallback\Shell\Open\command' -Name '(DEFAULT)' -value 'C:\Windows\CCM\SCClient.exe' -Force
        }
        catch
        {
            return
        }
    }
    else
    {
        return
    }
}

function PromptUpdate()
{
    $text1 = New-BTText -Content  "FAIS Notification"
    $text2 = New-BTText -Content "Updates are available!"
    $Button = New-BTButton -Content "Snooze" -snooze -id 'snooze'
    $Button2 = New-BTButton -Content "Dismiss" -snooze -id 'dismiss'
    $Button3 = New-BTButton -Content "Install" -Arguments "ToastSCCallback:" -ActivationType Protocol
    $action = New-BTAction -Buttons $Button, $Button2,$Button3
    $Binding = New-BTBinding -Children $text1,$text2
    $Visual = New-BTVisual -BindingGeneric $Binding
    $Content = New-BTContent -Visual $Visual -Actions $action
    Submit-BTNotification -Content $Content
}

function DualButton()
{
    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
    $ToastXml.LoadXml($ToastTemplate.OuterXml)

    $notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)

    #$notify.Show($ToastXml)
}

function BasicAlert()
{
    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($BasicTemplate)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)
}

function HeroImage()
{
    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($HeroToast.OuterXML)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)
}

function UptimeAlert($days,$hours,$minutes,$seconds)
{
    [xml]$ToastTemplate = @"
    <toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text>System Uptime Warning</text>
            <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\robert.gaines\Desktop\Powershell\Toast\alert.ico"/>
            <group>
             <subgroup>     
                <text hint-style="body" hint-wrap="true">
Uptime Data:
Days: $days 
Hours: $hours 
Minuntes: $minutes 
Seconds: $seconds
                </text> 
             </subgroup>
            </group>
        </binding>
    </visual>
    <actions>
        <action activationType="background" content="Snooze" arguments="later"/>
        <action activationType="background" content="Dismiss" arguments="dismiss"/>
        <action arguments=":ToastRebootCCM" content="Click Me!" activationType="protocol"/>
    </actions>
    </toast>
"@

    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($ToastTemplate.OuterXML)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($toast)
}

function PasswordWarning($password_expires)
{
 [xml]$ToastTemplate = 
 @"
    <toast launch="app-defined-string">
    <visual>
     <binding template="ToastGeneric">
      <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\robert.gaines\Desktop\Powershell\Toast\alert.ico"/>
      <text>Password Will Expire Soon</text>
      <text>Password Expires in: $password_expires Days</text>
     </binding>
    </visual>
   <actions>
    <action activationType="background" content="Snooze" arguments="later"/>
    <action activationType="background" content="Dismiss" arguments="dismiss"/>
   </actions>
 </toast>
"@

    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
    
    $ToastXml.LoadXml($ToastTemplate.OuterXml)

    $notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)
}

function GetPasswordExp()
{
    $user_data = net user $env:USERNAME /domain

    $user_data = @($user_data)

    #$user_data | Foreach-Object{Write-Host $_ ; Start-Sleep -Seconds 1}

    $password_expires = $user_data[11].split('')[14]

    return $password_expires
}

function PasswordExpCheck($password_expiration)
{
    if($password_expiration -eq 'Never')
    {
        $password_expiration = 365
        PasswordWarning($password_expiration)
    }
}

function CheckUpTime()
{
    $last_known_boot = (Get-CimInstance -Class Win32_OperatingSystem).LastBootUpTime
    
    $current_date_time = Get-Date 
    
    $uptime = $current_date_time.Subtract($last_known_boot) 

    $days    = $uptime.Days
    $hours   = $uptime.Hours
    $minutes = $uptime.Minutes
    $seconds = $uptime.Seconds

    UptimeAlert $days $hours $minutes $seconds
} 

function EndpointAlert($message)
{
 [xml]$ToastTemplate = 
 @"
   <toast launch="app-defined-string">
    <visual>
     <binding template="ToastGeneric">
      <image id="1" placement="appLogoOverride" hint-crop="circle" src="C:\Users\robert.gaines\Desktop\Powershell\Toast\alert.ico"/>
      <text>FAIS Alert</text>
      <text>$message</text>
     </binding>
    </visual>
   <actions>
    <action activationType="background" content="Snooze" arguments="later"/>
    <action activationType="background" content="Dismiss" arguments="dismiss"/>
   </actions>
 </toast>
"@

$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
    
$ToastXml.LoadXml($ToastTemplate.OuterXml)

$notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)

}

function EndpointListener
{
        try{ 
            $port = 3247
            $endpoint = New-Object System.Net.IPEndPoint([ipaddress]::any,$port) 
            $listener = New-Object System.Net.Sockets.TcpListener $endpoint
            $listener.start() 
            Write-Host "[*] Listening on: $port"
            $data = $listener.AcceptTcpClient() 
            if($data){Write-Host $data}
            $stream = $data.GetStream() 
            $bytes = New-Object System.Byte[] 1024

           
            while (($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){
                $EncodedText = New-Object System.Text.ASCIIEncoding
                $data = $EncodedText.GetString($bytes,0, $i)
                if($data)
                {
                    EndpointAlert($data)
                }
                Write-Output "Received: $data"
            }
            
            #$stream.close()
            #$listener.stop()
        }
        Catch {
            "Receive Message failed with: `n" + $Error[0]
        }
}

function main()
{
    HeroImage

    #EndPointListener

    #$password_expiration = GetPasswordExp

    #PasswordExpCheck $password_expiration

    #CheckUptime

    #ConfigureRegistryReboot

    #PromptReboot
}

main