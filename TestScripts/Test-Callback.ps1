<# Test Custom Callback via Burnt Toast #>

<#

Import-Module -Name BurntToast
Import-Module -Name RunAsUser

function RegistryModification()
{
    try
    {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

        $CustomProtocol = Get-Item "HKCR:\CustomProtocol" 

        if(!$CustomProtocol)
        {
            New-Item 'HKCR:\CustomProtocol' -Force
            Set-ItemProperty 'HKCR:\CustomProtocol' -Name '(DEFAULT)' -Value 'URL:CustomProtocol' -Force
            Set-ItemProperty 'HKCR:\CustomProtocol' -Name 'URL Protocol' -Value '' -Force 
            New-ItemProperty -Path 'HKCR:\CustomProtocol' -PropertyType DWORD -Name 'EditFlags' -Value 2162688
            New-Item "HKCR:\CustomProtocol\Shell\Open\command" -Force 
            Set-ItemProperty 'HKCR:\CustomProtocol\Shell\Open\command' -Name "C:\Windows\System32\cmd.exe" -Force
        }
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to interact with the Registry "
    }
}

function main()
{
    RegistryModification


    $text    = New-BTText -Content 'FAIS CMD Invocation'
    $text2   = New-BTText -Content 'Additional Text'
    $button  = New-BTButton -Content 'Command Shell' -Arguments "CustomProtocol:" -ActivationType Protocol
    $button  = New-BTButton -Content 'Dismiss' -Dismiss -Id 'Dismiss'
    $action  = New-BTAction -Buttons $button,$button2
    $binding = New-BTBinding -Children $text,$text2 
    $visual  = New-BTVisual -BindingGeneric $binding
    $content = New-BTContent -Visual $visual -Actions $action 
    Submit-BTNotification -Content $content 

    
}

main
 
#>

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
$ProtocolHandler = get-item 'HKCR:\ToastCCM' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    #create handler for reboot
    New-item 'HKCR:\ToastCCM' -force
    set-itemproperty 'HKCR:\ToastCCM' -name '(DEFAULT)' -value 'url:ToastCCM' -force
    set-itemproperty 'HKCR:\ToastCCM' -name 'URL Protocol' -value '' -force
    new-itemproperty -path 'HKCR:\ToastCCM' -propertytype dword -name 'EditFlags' -value 2162688
    New-item 'HKCR:\ToastCCM\Shell\Open\command' -force
    set-itemproperty 'HKCR:\ToastCCM\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\CCM\SCClient.exe' -force
}

<#
#Checking if ToastReboot:// protocol handler is present
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
$ProtocolHandler = get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    #create handler for reboot
    New-item 'HKCR:\ToastReboot' -force
    set-itemproperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force
    set-itemproperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force
    new-itemproperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688
    New-item 'HKCR:\ToastReboot\Shell\Open\command' -force
    set-itemproperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe -r -t 00' -force
}
 
#Install-Module -Name BurntToast
#Install-module -Name RunAsUser
#>
invoke-ascurrentuser -scriptblock {
 
    $heroimage = New-BTImage -Source ..\Images\WSU-Large.png -HeroImage
    $Text1 = New-BTText -Content  "Message from IT"
    $Text2 = New-BTText -Content "Your IT provider has installed updates on your computer at $(get-date). Please select if you'd like to reboot now, or snooze this message."
    $Button = New-BTButton -Content "Snooze" -snooze -id 'SnoozeTime'
    $Button2 = New-BTButton -Content "Reboot now" -Arguments "ToastCCM:" -ActivationType Protocol
    $5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
    $10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
    $1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
    $4Hour = New-BTSelectionBoxItem -Id 240 -Content '4 hours'
    $1Day = New-BTSelectionBoxItem -Id 1440 -Content '1 day'
    $Items = $5Min, $10Min, $1Hour, $4Hour, $1Day
    $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
    $action = New-BTAction -Buttons $Button, $Button2 -inputs $SelectionBox
    $Binding = New-BTBinding -Children $text1, $text2 -HeroImage $heroimage 
    $Visual = New-BTVisual -BindingGeneric $Binding
    $Content = New-BTContent -Visual $Visual -Actions $action
    Submit-BTNotification -Content $Content
}