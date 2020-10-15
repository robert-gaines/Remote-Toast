

function ConfirmationDialogue()
{
    $ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel

    $MessageIcon = [System.Windows.MessageBoxImage]::Warning

    $MessageBody = "Some hosts could not be contacted, try again?"

    $MessageTitle = "Confirm Retransmit"

    $result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

    return $result
}

$test = ConfirmationDialogue ; $test = $test.ToString() ; Write-Host -ForegroundColor Yellow $test

<#
$retransmit = ConfirmationDialogue

$retransmit = $retransmit.ToString()

while($retransmit -ne 'No' -or $retransmit -ne 'Cancel')
{
    Write-Host -ForegroundColor Magenta $retransmit

    $failedToNotify | Foreach-Object { $computer = $_ ; Write-Host -ForegroundColor Yellow $computer }

    $retransmit = ConfirmationDialogue

    $retransmit = $retransmit.ToString()

    if($retransmit -ne 'Yes')
    {
        break
    }

}
#>
