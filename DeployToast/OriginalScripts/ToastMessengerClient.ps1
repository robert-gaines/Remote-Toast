<# Toast Messenger Client #>

$ErrorActionPreference = 'SilentlyContinue'

<# Gather Top Level OUs  from Specific Top Level OU #>

function GatherTopLevelOUS()
{
    $organizational_units = @() <# Probably not necessary #>

    $toplevel_ous = Get-ADOrganizationalUnit -SearchBase "OU=Finance and Administration,OU=WSU,DC=ad,DC=wsu,DC=edu" `
                    -Filter * `
                    -SearchScope OneLevel | Select-Object Name,DistinguishedName

    return $toplevel_ous
}

<# 
   Basic TCP Transmission Function 
   -> This function sends a message over a TCP socket for both the Mass Notification and Single Notification 
      tranmission subroutines
   -> Message is sent over the socket established with the remote address and port 3247  
 #>

function TCPSendMessage($recipient,$message)
{
    $timeStamp  = TimeStamp ; Logger "[*] TCP Client message transmission function invoked at: $timeStamp "

    $port = 3247 

    try
    {
        $timeStamp  = TimeStamp ; Logger "[*] Socket object instantiated at: $timeStamp "

        $s = New-Object Net.Sockets.TcpClient($recipient,$port)

        if($s)
        {
            Write-Host -ForegroundColor Green "[*] Connected to: <$recipient|$port>"

            $timeStamp  = TimeStamp ; Logger "[*] Successful client connection to <$recipient|$port> at: $timeStamp "
        }
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to establish a connection to the host "

        $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to <$recipient|$port> at: $timeStamp "

        return 0
    }

    try 
    {
        $stream = $s.GetStream()

        $transmitter = New-Object System.IO.StreamWriter($stream)
    }
    catch 
    {
        Write-Host -ForegroundColor Red "[!] Failed to establish IO writer instance "

        return 0
    }

    Foreach($m in $message)
    {
        $transmitter.WriteLine($m)
        $transmitter.Flush()
    }

    $transmitter.Close()
    $stream.Close()

    return 1
}

<# 
   Single TCP Transmission Function 
   -> This
      tranmission subroutines
   -> Message is sent over the socket established with the remote address and port 3247  
 #>

function TCPClientTransmit($recipient,$message)
{
    $timeStamp  = TimeStamp ; Logger "[*] Single host notification function called at: $timeStamp "

    $segment             = $recipient.split(':')[1]
    $recipientAddress    = $segment.trim('.Text')
    $recipientAddress    = $recipientAddress.trim(' ')

    $message_options = @(
                            'Standard',
                            'Information',
                            'Alert',
                            'Warning'
                        )

    $typeIndex           = $MessageOptionListing.SelectedIndex
    $messageType         = $message_options[$typeIndex]

    $toastMessage        =  $messageType
    $messageSegment      =  $message.split(':')[1]
    $secondSegment       =  $messageSegment.split('.')[0]
    $thirdSegment        =  $secondSegment.trim(' ')
    $toastMessage        += ' '+$thirdSegment

    Write-Host -ForegroundColor Green "[*] Recipient Host: $recipientAddress"
    Write-Host -ForegroundColor Green "[*] Toast Message Content: $toastMessage"
    
    try 
    {
        $recipientResolution = [System.Net.Dns]::GetHostAddresses($recipientAddress).IPAddressToString
    }
    catch 
    {
        $recipientResolution = '0.0.0.0'   
    }

    if($recipientResolution.count -gt 1)
    {
        $recipientAddress = $recipientResolution[0]
    }
    else 
    {
        $recipientAddress = $recipientResolution    
    }

    Write-Host -ForegroundColor Yellow "[*] Attempting to send: $toastMessage to $recipientAddress "

    $timeStamp   = TimeStamp ; Logger "[*] Attempted to send: $toastMessage to $recipientAddress at: $timeStamp "

    try 
    {
        $result = TCPSendMessage $recipientAddress $toastMessage
        
        if($result -eq 1)
        {
            Write-Host -ForegroundColor Green "[*] Connected to: $recipientAddress "

            Write-Host -ForegroundColor Green "[*] Successful client connection and message transmission to $recipientAddress "

            $timeStamp  = TimeStamp ; Logger "[*] Successful client connection and message transmission to $recipientAddress at: $timeStamp "
        }
    }
    catch 
    {
        Write-Host -ForegroundColor Red "[!] Connection failed: $recipientAddress "

        $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $recipientAddress at: $timeStamp "
    }

    if($result -eq 0)
    {
        Logger "[!] Failed to notify <$recipientAddress> during single host transmission sequence "

        $retransmit = ConfirmationDialogue

        $retransmit = $retransmit.ToString()

        if($retransmit -eq 'Yes')
        {
            while($retransmit -ne 'No' -or $retransmit -ne 'Cancel')
            {  
                                                    
                try 
                {
                    $recipientResolution = [System.Net.Dns]::GetHostAddresses($recipientAddress).IPAddressToString
                }
                catch 
                {
                    $recipientResolution = '0.0.0.0'

                    $timeStamp  = TimeStamp ; Logger "[!] Failed to resolve <$recipientAddress> during single host re-transmission sequence "
                }

                if($recipientResolution.count -gt 1)
                {
                    $recipientAddress = $recipientResolution[0]
                }
                else 
                {
                    $recipientAddress = $recipientResolution  
                }

                Write-Host -ForegroundColor Yellow "[*] Attempting to send: $toastMessage to $recipientAddress "

                $timeStamp  = TimeStamp ; Logger "[*] Toast message: $toastMessage sent to $recipientAddress at: $timeStamp "

                try 
                {
                    $result = TCPSendMessage $recipientAddress $toastMessage
                    
                    if($result -eq 1)
                    {
                        Write-Host -ForegroundColor Green "[*] Connected to: $recipientAddress "

                        Write-Host -ForegroundColor Green "[*] Successful client connection and message transmission to $recipientAddress "

                        $timeStamp  = TimeStamp ; Logger "[*] Successful client connection and message transmission to $recipientAddress at: $timeStamp "

                        return
                    }
                }
                catch 
                {
                    Write-Host -ForegroundColor Red "[!] Connection failed: $recipientAddress "

                    $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $recipientAddress at: $timeStamp "
                }

                $retransmit = ConfirmationDialogue

                $retransmit = $retransmit.ToString()

                if($retransmit -ne 'Yes')
                {
                    return
                } 
            }
        }
        }
        else 
        {
            return    
        }
}

function TCPMassTransmit($message)
{
    $timeStamp  = TimeStamp ; Logger "[*] Mass transmission function called at: $timeStamp "

    $ous                 = GatherTopLevelOUS

    $failedToNotify      = @()

    if($OrganizationalUnitListing.SelectedIndex -eq 18)
    {
        $message_options = @(
                                'Standard',
                                'Information',
                                'Alert',
                                'Warning'
                            )

        $typeIndex           =  $MassMessageOptionListing.SelectedIndex 
        $messageType         =  $message_options[$typeIndex]

        $toastMessage        =  $messageType
        $messageSegment      =  $message.split(':')[1]
        $secondSegment       =  $messageSegment.split('.')[0]
        $thirdSegment        =  $secondSegment.trim(' ')
        $toastMessage        += ' '+$thirdSegment

        <# Index 18 equates to the All OU Option in the GUI - RWG - 10/06/2020 #>

        $timeStamp   = TimeStamp ; Logger "[*] All OU Notification Option Triggered at: $timeStamp "

        $ous | Foreach-Object {
                                    $OUDName = $_.DistinguishedName                      

                                    Get-ADComputer -SearchBase $OUDName -Filter * | Foreach-Object {  
                                                                                                        $computer = $_.Name 
                                                                                                        
                                                                                                        try 
                                                                                                        {
                                                                                                            $recipientResolution = [System.Net.Dns]::GetHostAddresses($computer).IPAddressToString
                                                                                                        }
                                                                                                        catch
                                                                                                        {
                                                                                                            $recipientResolution = '0.0.0.0'
                                                                                                        }

                                                                                                        if($recipientResolution.count -gt 1)
                                                                                                        {
                                                                                                            $recipientAddress = $recipientResolution[0]
                                                                                                        }
                                                                                                        else 
                                                                                                        {
                                                                                                            $recipientAddress = $recipientResolution  
                                                                                                        }

                                                                                                        Write-Host -ForegroundColor Green "[*] Toast message $toastMessage sent to -> $OUName : $computer : $recipientAddress "

                                                                                                        $timeStamp  = TimeStamp ; Logger "[*] Toast message: $toastmessage sent to $computer at: $timeStamp "

                                                                                                        try 
                                                                                                        {
                                                                                                            $result = TCPSendMessage $recipientAddress $toastMessage

                                                                                                            if($result -eq 0)
                                                                                                            {
                                                                                                                Write-Host -ForegroundColor Red "[!] Connection failed: $OUName : $computer "

                                                                                                                $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $computer at: $timeStamp "

                                                                                                                $failedToNotify += $computer
                                                                                                            }
                                                                                                            if($result -eq 1)
                                                                                                            {
                                                                                                                Write-Host -ForegroundColor Green "[*] Connected to: $OUName : $computer "

                                                                                                                Write-Host -ForegroundColor Green "[*] Successful client connection and message transmission to $recipientAddress "

                                                                                                                $timeStamp  = TimeStamp ; Logger "[*] Successful client connection and message transmission to $computer at: $timeStamp "
                                                                                                            }
                                                                                                        }
                                                                                                        catch 
                                                                                                        {
                                                                                                            Write-Host -ForegroundColor Red "[!] Connection failed: $OUName : $computer "

                                                                                                            $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $computer at: $timeStamp "
                                                                                                        }
                                                                                                } 
                              }
    }
    else 
    {
        $subjectOU           = $ous[$OrganizationalUnitListing.SelectedIndex] 
        $OUName              = $subjectOU.Name 
        $OUDName             = $subjectOU.DistinguishedName

        $timeStamp  = TimeStamp ; Logger "[*] Selected: $OUName as target organizational unit at: $timeStamp "

        $message_options = @(
                                'Standard',
                                'Information',
                                'Alert',
                                'Warning'
                            )

        $typeIndex           =  $MassMessageOptionListing.SelectedIndex 
        $messageType         =  $message_options[$typeIndex]

        $toastMessage        =  $messageType
        $messageSegment      =  $message.split(':')[1]
        $secondSegment       =  $messageSegment.split('.')[0]
        $thirdSegment        =  $secondSegment.trim(' ')
        $toastMessage        += ' '+$thirdSegment

        <#

            Write-Host "[*] Subject Organizational Unit: $OUName"
            Write-Host "[*] Subject Organizational Unit Distinguished Name: $OUDName"
            Write-Host "[*] Toast Message Content: $toastMessage"

        #>

        Get-ADComputer -SearchBase $OUDName -Filter * | Foreach-Object {  
                                                                            $computer = $_.Name
                                                            
                                                                            try 
                                                                            {
                                                                                $recipientResolution = [System.Net.Dns]::GetHostAddresses($computer).IPAddressToString
                                                                            }
                                                                            catch 
                                                                            {
                                                                                $recipientResolution = '0.0.0.0'
                                                                            }

                                                                            if($recipientResolution.count -gt 1)
                                                                            {
                                                                                $recipientAddress = $recipientResolution[0]
                                                                            }
                                                                            else 
                                                                            {
                                                                                $recipientAddress = $recipientResolution  
                                                                            }

                                                                            Write-Host -ForegroundColor Green "[*] $toastMessage sent to -> $OUName : $computer : $recipientAddress "

                                                                            $timeStamp  = TimeStamp ; Logger "[*] Toast message: $toastMessage sent to $computer at: $timeStamp "

                                                                            try 
                                                                            {
                                                                                $result = TCPSendMessage $recipientAddress $toastMessage

                                                                                if($result -eq 0)
                                                                                {
                                                                                    Write-Host -ForegroundColor Red "[!] Connection failed: $OUName : $computer "

                                                                                    $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $computer at: $timeStamp "

                                                                                    $failedToNotify += $computer
                                                                                }
                                                                                if($result -eq 1)
                                                                                {
                                                                                    Write-Host -ForegroundColor Green "[*] Connected to: $OUName : $computer "

                                                                                    Write-Host -ForegroundColor Green "[*] Successful client connection and message transmission to $recipientAddress "

                                                                                    $timeStamp  = TimeStamp ; Logger "[*] Successful client connection and message transmission to $computer at: $timeStamp "
                                                                                }
                                                                            }
                                                                            catch 
                                                                            {
                                                                                Write-Host -ForegroundColor Red "[!] Connection failed: $OUName : $computer "

                                                                                $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $computer at: $timeStamp "
                                                                            }
                                                                       } 
    }

    if($failedToNotify.length -gt 0)
    {
        $timeStamp  = TimeStamp ; Logger "[~] Entered re-transmit sequence for mass notify at: $timeStamp "

        $failedToNotify | Foreach-Object {  
                                            $computer = $_ ; Logger "[!] Failed to notify <$computer> during mass transmission sequence "
                                         }

        $retransmit = ConfirmationDialogue

        $retransmit = $retransmit.ToString()

        if($retransmit -eq 'Yes')
        {
            while($retransmit -ne 'No' -or $retransmit -ne 'Cancel')
            {
                $failedToNotify | Foreach-Object { 
                    
                                                    $computer = $_ 
                                                    
                                                    try 
                                                    {
                                                        $recipientResolution = [System.Net.Dns]::GetHostAddresses($computer).IPAddressToString
                                                    }
                                                    catch 
                                                    {
                                                        $recipientResolution = '0.0.0.0'
                                                    }

                                                    if($recipientResolution.count -gt 1)
                                                    {
                                                        $recipientAddress = $recipientResolution[0]
                                                    }
                                                    else 
                                                    {
                                                        $recipientAddress = $recipientResolution  
                                                    }

                                                    Write-Host -ForegroundColor Green "[*] $toastMessage sent to -> $OUName : $computer : $recipientAddress "

                                                    $timeStamp  = TimeStamp ; Logger "[*] Toast message: $toastMessage sent to $computer at: $timeStamp "

                                                    try 
                                                    {
                                                        $result = TCPSendMessage $recipientAddress $toastMessage
                                                        
                                                        if($result -eq 1)
                                                        {
                                                            <# If retransmission is successful, repopulate the array, excluding the contacted host #>

                                                            $failedToNotify = $failedToNotify | Where-Object { $_ -ne $computer }

                                                            Write-Host -ForegroundColor Green "[*] Connected to: $OUName : $computer "

                                                            $timeStamp  = TimeStamp ; Logger "[*] Successful client connection and message transmission to $computer at: $timeStamp "
                                                        }
                                                    }
                                                    catch 
                                                    {
                                                        Write-Host -ForegroundColor Red "[!] Connection failed: $OUName : $computer "

                                                        $timeStamp  = TimeStamp ; Logger "[!] Failed to connect to $computer at: $timeStamp "
                                                    }
                                                }

                $retransmit = ConfirmationDialogue

                $retransmit = $retransmit.ToString()

                if($retransmit -ne 'Yes')
                {
                    return
                } 
                if($failedToNotify.length -eq 0)
                {
                    return
                }
            }
        }
        else 
        {
            return    
        }
    }

}

<# Mass Transmit - Retransmit Confirmation Dialogue #>

function ConfirmationDialogue()
{
    $ButtonType = [System.Windows.Forms.MessageBoxButtons]::YesNoCancel

    $MessageIcon = [System.Windows.Forms.MessageBoxIcon]::Warning

    $MessageBody = "Some hosts could not be contacted, try again?"

    $MessageTitle = "Confirm Retransmit"

    $result = [System.Windows.Forms.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

    return $result
}

<# Create the Main Window #>

function DisplayClient()
{
    Add-Type -Assembly System.Windows.Forms

    $FormObject = New-Object System.Windows.Forms.Form 

    $FormObject.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D

    $FormObject.Text = "Toast Notification Client"

    $FormObject.Width = 300

    $FormObject.Height = 600

    $FormObject.AutoSize = $true 

    <# End Main Form Configuration #>

    <# Form Component Configuration #>

    <# Recipient Identification #>

    <# Mass Notification Label #>

    $OrganizationalUnitEntryLabel = New-Object System.Windows.Forms.Label

    $OrganizationalUnitEntryLabel.Text = "Select an Organizational Unit for Mass Notification"

    $OrganizationalUnitEntryLabel.Location = New-Object System.Drawing.Point(5,20)

    $OrganizationalUnitEntryLabel.AutoSize = $true

    $FormObject.Controls.Add($OrganizationalUnitEntryLabel)

    <# End Mass Notification Label #>

    <# Begin Mass Notification Drop Down Menu #>

    $organizational_units = GatherTopLevelOUS

    $OrganizationalUnitListing = New-Object System.Windows.Forms.ComboBox

    $OrganizationalUnitListing.Width = 300

    $organizational_units | Foreach-Object {

                                                $OU = $_.Name 

                                                $OrganizationalUnitListing.Items.Add($OU) | Out-Null

                                           }

    $OrganizationalUnitListing.Items.Add("All Organizational Units") | Out-Null

    $OrganizationalUnitListing.Location = New-Object System.Drawing.Point(5,40)

    $FormObject.Controls.Add($OrganizationalUnitListing)

    <# End Mass Notification Drop Down Menu #>

    <# Begin Mass Notification Message Type Drop Down Menu Label #>

    $MassMessageOptionLabel = New-Object System.Windows.Forms.Label

    $MassMessageOptionLabel.Text = "Select a Message Format"

    $MassMessageOptionLabel.Location = New-Object System.Drawing.Point(5,70)

    $MassMessageOptionLabel.AutoSize = $true

    $FormObject.Controls.Add($MassMessageOptionLabel)

    <# End Mass Notification Message Type Drop Down Menu Label #>

    <# Begin Mass Notification Message Type Drop Down Menu #>                                       

    $message_options = @(
                           'Standard',
                           'Information',
                           'Alert',
                           'Warning'
                        )

    $MassMessageOptionListing = New-Object System.Windows.Forms.ComboBox 

    $MassMessageOptionListing.Width = 300

    $message_options | Foreach-Object {
                                        $format = $_

                                        $MassMessageOptionListing.Items.Add($format) | Out-Null
                                      }

    $MassMessageOptionListing.Location = New-Object System.Drawing.Point(5,90)

    $FormObject.Controls.Add($MassMessageOptionListing)

    <# End Mass Notification Message Type Drop Down Menu #>

    <# Mass Notification Text Box Label #>

    $MassNotificationTextLabel = New-Object System.Windows.Forms.Label

    $MassNotificationTextLabel.Text = "Enter the message for mass notification"

    $MassNotificationTextLabel.Location = New-Object System.Drawing.Point(5,120)

    $MassNotificationTextLabel.AutoSize = $true

    $FormObject.Controls.Add($MassNotificationTextLabel)

    <# End Mass Notification Text Box Label #>

    <# Begin Message Text Box for Mass Notification #>

    $MassNotifyInputField = New-Object System.Windows.Forms.TextBox

    $MassNotifyInputField.Location = New-Object System.Drawing.Point(5,140)

    $MassNotifyInputField.Size = '300,100'

    $MassNotifyInputField.AutoSize = $true

    $FormObject.Controls.Add($MassNotifyInputField)

    <# End the message text box for mass notification #>

    <# Begin Mass Notification Submit Button #>

    $MassNotifyButton = New-Object System.Windows.Forms.Button

    $MassNotifyButton.Location = New-Object System.Drawing.Point(5,170)

    $MassNotifyButton.Text = "Mass Notify!"

    $MassNotifyButton.Size = '300,10'

    $MassNotifyButton.AutoSize = $true
    
    $MassNotifyButton.Add_Click({TCPMassTransmit $global:messageContent=$MassNotifyInputField.Text})

    $FormObject.Controls.Add($MassNotifyButton)

    <# End Mass Notification Submit Button #>

    <# Begin Single Recipient Label Field #>

    $RecipientHostLabel = New-Object System.Windows.Forms.Label 

    $RecipientHostLabel.Text = "Toast Message Recipient (IP or Host Name)"

    $RecipientHostLabel.Location = New-Object System.Drawing.Point(5,220)

    $RecipientHostLabel.AutoSize = $true 

    $FormObject.Controls.Add($RecipientHostLabel)

    <# End Single Recipient Label Field #>

    <# Begin Recipient Input Field #>

    $RecipientInputField = New-Object System.Windows.Forms.TextBox

    $RecipientInputField.Location = New-Object System.Drawing.Point(5,240)

    $RecipientInputField.Size = '300,100'

    $RecipientInputField.AutoSize = $true

    $FormObject.Controls.Add($RecipientInputField)

    <# End Recipient Input Field #>

    <# Begin Notification Message Type Drop Down Menu Label #>

    $MessageOptionLabel = New-Object System.Windows.Forms.Label

    $MessageOptionLabel.Text = "Select a Message Format"

    $MessageOptionLabel.Location = New-Object System.Drawing.Point(5,270)

    $MessageOptionLabel.AutoSize = $true

    $FormObject.Controls.Add($MessageOptionLabel)

    <# End Notification Message Type Drop Down Menu Label #>

    <# Begin Notification Message Type Drop Down Menu #>                                       

    $message_options = @(
                           'Standard',
                           'Information',
                           'Alert',
                           'Warning'
                        )

    $MessageOptionListing = New-Object System.Windows.Forms.ComboBox 

    $MessageOptionListing.Width = 300

    $message_options | Foreach-Object {
                                        $format = $_

                                        $MessageOptionListing.Items.Add($format) | Out-Null
                                      }

    $MessageOptionListing.Location = New-Object System.Drawing.Point(5,290)

    $FormObject.Controls.Add($MessageOptionListing)

    <# End Notification Message Type Drop Down Menu #>

    <# Toast Message Label #>

    $MessageInputLabel = New-Object System.Windows.Forms.Label

    $MessageInputLabel.Text = "Toast Notification Message"

    $MessageInputLabel.Location = New-Object System.Drawing.Point(5,320)

    $MessageInputLabel.AutoSize = $true 

    $FormObject.Controls.Add($MessageInputLabel)

    <# Add the message text box #>

    $MessageInputField = New-Object System.Windows.Forms.TextBox

    $MessageInputField.Location = New-Object System.Drawing.Point(5,340)

    $MessageInputField.Size = '300,100'

    $MessageInputField.AutoSize = $true

    $FormObject.Controls.Add($MessageInputField)

    <# End the message text box #>

    <# Add the transmission button #>

    $MessageTransmitButton = New-Object System.Windows.Forms.Button

    $MessageTransmitButton.Location = New-Object System.Drawing.Point(5,370)

    $MessageTransmitButton.Text = "Transmit"

    $MessageTransmitButton.Size = '300,10'

    $MessageTransmitButton.AutoSize = $true 

    <# Store variable data for transmission #>

    $MessageTransmitButton.Add_Click({TCPClientTransmit $global:recipientAddress=$RecipientInputField.Text $global:messageContent=$MessageInputField.Text})

    $FormObject.Controls.Add($MessageTransmitButton)

    <# Initiate the main GUI presentation sequence #>

    $FormObject.ShowDialog()
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
    $fileName = "toast_client_log"+$tod

    <# Create the Log Directory & File #>

    $logPath = "C:\Users\Public\Documents\FAISToastClient_Log"

    $logFilePath = "C:\Users\Public\Documents\FAISToastClient_Log\$fileName"

    $testLogPath = Test-Path -Path $logPath

    if(-not $testLogPath)
    {
        try
        {
           New-Item -ItemType Directory -Path "C:\Users\Public\Documents\" -Name "FAISToastClient_Log" | Out-Null

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

Write-Host -ForegroundColor Green "[*] Starting Toast Messenger Client "

$logfile = GenerateLogfile 

$timeStamp  = TimeStamp ; Logger "[*] FAIS TOAST Client log created at: $timeStamp "

$timeStamp  = TimeStamp ; Logger "[*] FAIS TOAST Client started at: $timeStamp "

DisplayClient

