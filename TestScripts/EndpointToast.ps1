
function DisplayHero()
{
    $text_content = New-BTText -Content "Warning"

    $alt_content  = New-BTText -Content "Another Warning"

    $image = New-BTImage -Source wsu-dark.jpg -Hero -AddImageQuery

    $binding = New-BTBinding -Children $text_content,$alt_content -HeroImage $image 

    $visual = New-BTVisual -BindingGeneric $binding

    $audio = New-BTAUdio -Source ms-winsoundevent:Notification.SMS 

    $content = New-BTContent -Audio $audio -Visual $visual -Duration Long
    
    Submit-BTNotification -Content $content -AppId 
}

function SnoozeOrDismiss()
{
    $dismiss_args = @{
                    Content = 'Dismiss'
                    Arguments = 'notepad.exe'
                 }

    $snooze_button  = New-BTButton -Snooze 
    $dismiss_button = New-BTButton -Arguments 'C:\Windows\system32\cmd.exe' -Content 'Dismiss'

    $text = 'Test Message'

    New-BurntToastNotification -Text $text -Button $snooze_button,$dismiss_button -AppLogo C:\Users\robert.gaines\Desktop\Main\InProgress\alert.ico
}

function LaunchProgram()
{
    $text = New-BTText -Content 'Launch'

    $binding = New-BTBinding -Children $text

    $visual = New-BTVisual -BindingGeneric $binding

    $content = New-BTContent -Visual $visual -Launch '' -ActivationType Protocol

    Submit-BTNotification -Content $content
}

function GetPendingUpdates()
{
    Get-CIMInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" | Where-Object { $_.ApplicabilityState -eq 'Applicable' -and $_.AllowedActions -eq 'Install' } | Select-Object FullName
}

function main()
{
    <# Endpoint Toast Notification #>
    #DisplayHero 
    SnoozeOrDismiss
    #LaunchProgram
    #GetPendingUpdates
}

main